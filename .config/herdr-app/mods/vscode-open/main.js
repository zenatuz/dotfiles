// A button for the status bar: opens the focused terminal's folder in VS Code.
// Local folders use the `code` CLI; folders on another machine use VS Code
// Remote-SSH. Herdr does not dock new mods into shipped layouts, so
// layouts/main-vscode.json places this block itself.
//
// Remote-SSH connects with the Herdr machine name as the ssh Host, so User,
// Port, IdentityFile and ProxyJump come from ~/.ssh/config. The convention is
// "machine name == ssh config Host alias" (Herdr names a machine after its ssh
// target by default, so this holds unless it was renamed). machines.json
// beside this file lists shared exceptions (renamed machines, --via machines
// whose custom command Remote-SSH can't reproduce, or a raw user@host
// destination); machines.local.json overrides it per machine.

import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, readTextFile, appHome, spaces, panes, focused, theme, window, notify } from "herdr";

const CONFIG = "mods/vscode-open/machines.json";
const LOCAL = "mods/vscode-open/machines.local.json";

// Where the window is now: the focused terminal's live folder and the machine
// of its space (null for this computer).
function target() {
  const f = focused();
  const space = spaces().find((s) => s.id === f?.space) ?? spaces().find((s) => s.active) ?? null;
  const pane = panes().find((p) => p.pane === f?.pane) ?? panes().find((p) => p.tab === f?.tab) ?? null;
  return {
    cwd: (f?.cwd || pane?.cwd || space?.folder || "").trim(),
    machine: space?.machine ?? null,
  };
}

function text(v) {
  return typeof v === "string" ? v.trim() : "";
}

export default class OpenInVSCode extends View {
  init() {
    this.busy = false;
  }

  // The ssh Host for a machine: its name by default, else machines.json, and
  // machines.local.json wins (per-machine, gitignored, like .zshrc.local).
  async host(machine) {
    const read = async (file) => {
      try {
        const raw = await readTextFile(`${appHome()}/${file}`);
        const parsed = raw ? JSON.parse(raw) : {};
        return parsed && typeof parsed === "object" ? parsed : {};
      } catch {
        return {};
      }
    };
    const local = await read(LOCAL);
    const shared = await read(CONFIG);
    return text(local[machine]) || text(shared[machine]) || machine;
  }

  open(cx) {
    if (this.busy) return;
    const { cwd, machine } = target();
    if (!cwd) {
      notify({ title: "VS Code", body: "The focused pane has no folder.", level: "warning", timeout: 6000 });
      return;
    }
    const where = machine ?? "this computer";
    const cli = window()?.platform === "windows" ? "code.cmd" : "code";
    // Windows paths on a remote host use forward slashes in a remote URI.
    const path = machine && /^[A-Za-z]:\\/.test(cwd) ? cwd.replace(/\\/g, "/") : cwd;
    this.busy = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        let host = null;
        if (machine) {
          host = await this.host(machine);
          if (!host || /\s/.test(host)) {
            throw new Error(`No usable ssh Host for “${machine}”. Fix the name or set it in ${CONFIG}.`);
          }
        }
        const args = [];
        if (host) args.push("--remote", `ssh-remote+${host}`);
        args.push(path);
        const r = await exec(cli, args, { timeout: 60000 });
        if (r.code !== 0) throw new Error((r.stderr || r.stdout || `code exited with ${r.code}`).trim());
      } catch (e) {
        notify({ title: `VS Code (${where})`, body: String(e?.message ?? e), level: "error", timeout: 9000 });
      } finally {
        this.busy = false;
        cx.notify();
      }
    });
  }

  render() {
    const t = theme();
    const { cwd, machine } = target();
    const tip = cwd ? `Open ${cwd} in VS Code${machine ? ` on ${machine}` : ""}` : "No folder in the focused pane";
    return h_flex()
      .size_full()
      .items_center()
      .justify_center()
      .bg(t.chrome)
      .border_t(1)
      .border_l(1)
      .border_color(t.border)
      .child(
        h_flex()
          .id("open-vscode")
          .h(22)
          .px(8)
          .gap(5)
          .items_center()
          .rounded(5)
          .text_size(11.8)
          .text_color(this.busy ? t.dim : t.muted)
          .cursor_pointer()
          .tooltip(tip)
          .hover((s) => s.bg(t.hover).text_color(t.foreground))
          .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
          .on_click((_e, cx) => this.open(cx))
          .child(
            this.busy
              ? svg("mods/workspace-chrome/spinner.svg").size(13).flex_none().text_color(t.working).spin(900)
              : svg("mods/vscode-open/vscode.svg").size(13).flex_none(),
          )
          .child(div().flex_none().child("VS Code")),
      );
  }
}
