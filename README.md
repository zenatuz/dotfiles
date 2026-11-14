# Zenatuz Dotfiles 🚀

Personal dotfiles for **DevOps Engineer** — macOS (primary), Linux (secondary).  
Terminal: **Ghostty** + **Starship** prompt with Kubernetes, Azure, Terraform modules.

## Quick Install (fresh machine)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zenatuz/dotfiles/main/.install.sh)"
```

This will install:
- **Homebrew** + packages from `.brewfile`
- **Ghostty** terminal (GPU-accelerated)
- **Starship** prompt with DevOps modules
- **ZSH plugins** (autosuggestions, syntax-highlighting)
- **Helm plugins** (diff, secrets, git)
- **Docker** + **Colima** (lightweight container runtime)
- Clone dotfiles with **yadm**

## Machine-Specific Configuration

Some tools set environment variables that are specific to a single machine (e.g., corporate EDR certificates, proxy settings, internal CA bundles). These **should not** be committed to the shared dotfiles repo.

The `.zshrc` automatically sources `~/.zshrc.local` (listed in `.gitignore`) — use it for anything that only belongs on one machine:

```zsh
# ~/.zshrc.local — created only on machines that need these exports
# (never committed to dotfiles repo)

# Example: corporate EDR certificates (Aikido Security, CrowdStrike, etc.)
export CURL_CA_BUNDLE="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-openssl-combined-ca.pem"
export NODE_EXTRA_CA_CERTS="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-combined-ca.pem"
export PIP_CERT="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
export REQUESTS_CA_BUNDLE="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
export BUNDLE_SSL_CA_CERT="/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-ruby-combined-ca.pem"
```

Other local override files (also gitignored):
- `~/.gitconfig.local` — machine-specific git config
- `~/.vimrc.local` — machine-specific vim settings

## Git Clean/Smudge Filter: Corporate Certificate Stripping

Some corporate tools (e.g., Aikido Security EDR) inject CA bundle variables directly into `~/.zshrc` on every shell spawn. These lines **must not** be committed, but they also cannot be moved to `.zshrc.local` because the tool re-adds them automatically.

The repo uses a **git clean/smudge filter** to strip these lines on the fly:

```
[filter "aikido"]
    clean = ~/.config/yadm/filters/aikido.zsh   # runs on add/commit/push
    smudge = cat                                  # pass-through on checkout
```

**How it works:**

```
You edit .zshrc (EDR tool adds CA exports)
         │
         ▼
yadm add .zshrc → git runs clean → aikido.zsh → removes EDR certificate lines
         │                                          ↓
         └──── staged content is CLEAN ──────────────┘
         │
         ▼
yadm commit/push → no EDR lines ever reach the remote
```

The filter is defined in `.gitconfig` (tracked) and mapped by `.gitattributes`:
- `.gitattributes` → `.zshrc filter=aikido`
- `.gitconfig` → `filter.aikido.clean` + `filter.aikido.smudge`

The working copy on disk is **never touched** — the filter only transforms content entering the index. This means `yadm status` will show `.zshrc` as modified (` M`) because the working copy has EDR lines while the staged copy doesn't. This is expected and harmless.

**Per-machine setup:**

```bash
# The script must exist at ~/.config/yadm/filters/aikido.zsh
mkdir -p ~/.config/yadm/filters
curl -fsSL https://raw.githubusercontent.com/zenatuz/dotfiles/main/.config/yadm/filters/aikido.zsh \
  -o ~/.config/yadm/filters/aikido.zsh
```

The filter configuration ships with `.gitconfig` — no manual git config needed after cloning.

## OpenCode MCP Servers

The global OpenCode configuration is stored at `~/.config/opencode/opencode.json`.
It enables MCP access to:

- Atlassian: Jira and Confluence via OAuth 2.1
- Azure: Azure resources via Azure CLI credentials and RBAC
- Azure DevOps: repositories, pipelines, search, and wiki for `keesingtech`
- Terraform: public Terraform Registry documentation and modules

Authenticate after installing the configuration:

```bash
az login
opencode mcp auth atlassian
```

Azure DevOps uses interactive Microsoft authentication on first use. Terraform
Registry access is public. HCP Terraform private registry access additionally
requires `TFE_ADDRESS` and `TFE_TOKEN`; keep those values in the shell
environment or a secret manager, never in tracked configuration.

## Herdr (agents app)

The Herdr app keeps its whole interface as files in `~/.config/herdr-app`.
Only our own pieces are versioned here:

- `settings.json` - zoom, sounds, fonts, theme.
- `layouts/main-vscode.json` - a clone of the shipped `main` layout with a
  **VS Code** button in the status bar.
- `mods/vscode-open/` - the button: opens the focused terminal's folder in
  VS Code, locally or over VS Code Remote-SSH (`--remote ssh-remote+<machine>`).

The rest (`AGENTS.md`, `*.d.ts`, `frame/`, `icons/`, the shipped layouts and
mods, and state files) is generated or replaced by Herdr on every start and is
listed in `.config/herdr-app/.gitignore`.

**Convention:** the Herdr machine name is the `Host` alias in that machine's
`~/.ssh/config`. Exceptions (renamed machines, `--via` machines, `user@host`
targets) go in `mods/vscode-open/machines.local.json`, which is ignored like
`.zshrc.local`.

On macOS/Linux the `code` CLI must be on `PATH` and
`ms-vscode-remote.remote-ssh` installed. After cloning, pick the
`main-vscode` layout once (`ctrl-shift-l`).

## SwiftBar Plugins

SwiftBar plugins are stored in `~/.swiftbar`:

- `check-network.3s.sh` — monitors gateway, internet, and DNS connectivity
- `deepseek_balance.5m.sh` — displays DeepSeek balance
- `ration.5m.sh` — tracks Copilot, Codex, and Antigravity quotas

For the DeepSeek plugin, create a local environment file:

```bash
cp ~/.swiftbar/.env.example ~/.swiftbar/.env
# Edit ~/.swiftbar/.env and set DEEPSEEK_API_KEY
```

`.env`, `.env.*`, and local credential files must never be committed. Commit
only sanitized templates such as `.env.example`.

## What's Included

### Shell & Terminal

| Tool | What | Why |
|------|------|-----|
| [Ghostty](https://ghostty.org/) | Terminal emulator | GPU-accelerated, native macOS |
| [Starship](https://starship.rs/) | Prompt | Kubernetes, Azure, Terraform modules |
| [eza](https://eza.rocks/) | `ls` replacement | Icons, colors, tree view |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` | Learn your habits, jump anywhere |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement | Syntax highlighting, line numbers |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` replacement | Blazing fast, recursive by default |
| [fd](https://github.com/sharkdp/fd) | `find` replacement | Fast, intuitive |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | Ctrl+R, Ctrl+T, fuzzy everything |
| [mcfly](https://github.com/cantino/mcfly) | Shell history | Smart suggestions with AI |
| [git-delta](https://github.com/dandavison/delta) | Git diff | Syntax-highlighted, side-by-side |

### Kubernetes & Cloud (Azure)

| Tool | What | Why |
|------|------|-----|
| [krew](https://krew.sigs.k8s.io/) | kubectl plugin manager | Discover and install k8s plugins |
| [k9s](https://k9scli.io/) | Kubernetes TUI | Cluster management from terminal |
| [kubectx](https://github.com/ahmetb/kubectx) | Context/namespace switcher | Fast cluster hopping |
| [stern](https://github.com/stern/stern) | Multi-pod log tailing | Aggregate logs across pods |
| [popeye](https://popeyecli.io/) | Cluster sanitizer | Best practices & security checks |
| [kube-linter](https://github.com/stackrox/kube-linter) | Manifest linting | Catch misconfigs before deploy |
| [kubeconform](https://github.com/yannh/kubeconform) | Schema validation | Validate against K8s schemas |
| [nova](https://github.com/FairwindsOps/nova) | Outdated Helm charts | Detect stale charts in clusters |
| [pluto](https://github.com/FairwindsOps/pluto) | Deprecated K8s APIs | Find removed API versions |
| [kubent](https://github.com/doitintl/kube-no-trouble) | K8s API deprecations | Prevent upgrade breakage |
| [helm](https://helm.sh/) | Package manager | Deploy and manage charts |
| [trivy](https://github.com/aquasecurity/trivy) | Container/vuln scanner | Scan images, IaC, repos |
| [dive](https://github.com/wagoodman/dive) | Docker image layers | Inspect layer efficiency |
| [kind](https://kind.sigs.k8s.io/) | K8s in Docker | Local clusters for testing |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) | Azure resource management | CLI for Azure + resource export |

### Infrastructure as Code

| Tool | What | Why |
|------|------|-----|
| [tenv](https://github.com/tofuutils/tenv) | Terraform/OpenTofu version manager | Switch TF versions per project |
| [terraform-docs](https://terraform-docs.io/) | Auto-generate Terraform docs | Always-updated module docs |
| [terraform-ls](https://github.com/hashicorp/terraform-ls) | Terraform Language Server | Autocomplete + validation in editor |
| [checkov](https://www.checkov.io/) | IaC security scanning | Catch misconfigs in TF/K8s/YAML |
| [aztfexport](https://github.com/Azure/aztfexport) | Export Azure resources | Import existing infra to Terraform |

### macOS Apps (via Brew Bundle)

| App | What | Why |
|-----|------|-----|
| [Ghostty](https://ghostty.org/) | GPU-accelerated terminal emulator | Blazing fast, native macOS feel |
| [Colima](https://github.com/abiosoft/colima) | Lightweight container runtime | Docker Desktop alternative, no license needed |
| [Raycast](https://raycast.com/) | Spotlight replacement | Quick launcher + extensions |
| [Rectangle](https://rectangleapp.com/) | Window management | Snap windows with keyboard |
| [AltTab](https://alt-tab-macos.netlify.app/) | Windows-style window switcher | Alt+Tab with app previews |
| [Stats](https://github.com/exelban/Stats) | System monitor menu bar | CPU, RAM, disk, network at a glance |
| [1Password](https://1password.com/) | Password manager | Secrets, SSH keys, tokens |
| [Thaw](https://github.com/matthewlawson/thaw) | Menu bar manager | Organize menu bar icons (Ice alternative) |
| [MonitorControl](https://github.com/MonitorControl/MonitorControl) | External monitor controls | Brightness/volume for non-Apple displays |
| [Amphetamine](https://apps.apple.com/app/id937984704) | Keep Mac awake | Prevent sleep during long runs |
| [Azure VPN Client](https://apps.apple.com/app/id1553936137) | Azure VPN | Connect to Azure VPN gateways |
| [Microsoft Remote Desktop](https://apps.microsoft.com/detail/9WZDNCRFJ3PS) | RDP client | Remote desktop to Windows VMs |

> Full cask and Mac App Store list in [.brewfile](.brewfile) (browserosaurus, meetingbar, deepl, shottr, vipinator, Unsplash Wallpapers, and more).

### Container Runtime

On macOS, container runtime is split into two layers:

| Layer | Project | Role |
|-------|---------|------|
| **Daemon** | [Colima](https://github.com/abiosoft/colima) | Runs the Docker engine inside a lightweight Lima VM — no Docker Desktop license needed |
| **CLI** | [Docker CLI](https://github.com/docker/cli) / [Compose](https://github.com/docker/compose) | Client tools that connect to Colima's socket (`colima` manages the `docker` context automatically) |

On Linux, the Docker daemon runs natively and both packages serve their standard roles.

#### Colima Automation

To avoid wasting 8 GB of RAM when no containers are running, two automations are in place:

**Auto-start** (in `.zshrc`): a shell function wraps the `docker` command. If Colima is stopped, it starts the VM automatically before running the docker command. Use `command docker` to bypass.

**Auto-stop** (`~/.config/colima/autostop.sh` + LaunchAgent): runs every 5 minutes via a macOS LaunchAgent. If no containers are running for 3 consecutive checks (~15 min), Colima is stopped. The plist uses `$HOME` expansion (via `bash -c`) so it's portable across machines.

```bash
# First-time setup (on a new Mac):
ln -s ~/.config/colima/com.user.colima-autostop.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.colima-autostop.plist

# Manual control
launchctl bootout gui/$(id -u)/com.user.colima-autostop   # disable auto-stop
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.colima-autostop.plist  # re-enable

# View auto-stop logs
cat ~/.local/state/colima/autostop.log

# Adjust idle timeout: edit INTERVAL_SEC and MAX_IDLE_SEC in ~/.config/colima/autostop.sh
```

## Starship Prompt

The prompt is optimized for DevOps workflows with modules shown on demand:

- **Left side**: username, hostname, directory, git, terraform, docker context, command duration, exit status
- **Right side**: Kubernetes context (`󰥋`), Azure subscription (``), battery, time
- **Transient prompt**: full prompt replaced by `❯` after pressing Enter (cleaner output)
- **Notifications**: long-running commands (>30s) notify when terminal is unfocused

## Manual Setup

### After first install

```bash
# Once everything is installed, restart your terminal
# or source the config
source ~/.zshrc

# Set your git identity (create ~/.gitconfig.local)
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your@email.com"
```

### Machine-specific overrides

Create `~/.zshrc.local` for machine-specific settings (not tracked by yadm):

```bash
#!/bin/zsh

# Example: project-specific paths
export PATH="$HOME/projects/my-tools:$PATH"

# Example: work-specific aliases
alias kprod="kubectx prod-cluster"
```

### Font

Install **MesloLGS NF** (already in Brewfile for macOS):

```bash
brew install --cask font-meslo-lg-nerd-font
```

Configure your terminal → Font face: `MesloLGS NF`

### Updating Packages

```bash
# Update brew and all packages
brew update && brew upgrade && brew cleanup

# Or use the alias
update
```

### Regenerate Brewfile

```bash
brew bundle dump --file=.brewfile --force
```

### Just the dotfiles (without setup script)

If you only want the configs without the installer:

```bash
cd ~
yadm clone https://github.com/zenatuz/dotfiles.git
# or if you already have yadm set up:
yadm pull
```

## Structure

```
.
├── .brewfile          # Homebrew packages (macOS + Linux)
├── .config/
│   ├── ghostty/
│   │   └── config     # Ghostty terminal config (theme, font, opacity)
│   ├── nvim/
│   │   └── init.vim   # Neovim config (sources .vimrc)
│   ├── opencode/
│   │   ├── opencode.json # MCP server configuration
│   │   └── skills/       # OpenCode skills
│   ├── herdr-app/
│   │   ├── settings.json
│   │   ├── layouts/main-vscode.json
│   │   └── mods/vscode-open/
│   └── starship.toml     # Starship prompt with k8s/azure/terraform
├── .editorconfig      # Editor settings
├── .env               # Environment variables (gitignored template)
├── .gitconfig         # Git configuration (with delta, aliases)
├── .gitignore         # Git ignore rules
├── .helmlist          # Helm plugins
├── .install.sh        # One-shot setup script
├── LICENSE            # MIT License
├── .ssh/
│   └── config         # SSH hosts (GitHub, Azure DevOps)
├── .swiftbar/
│   ├── .env.example    # Sanitized credential template
│   └── *.sh             # SwiftBar plugins
├── .vimrc             # Vim/Neovim config (line numbers, syntax, indentation)
├── .zshrc             # Zsh configuration
├── .zsh/
│   └── zsh-custom.sh  # Aliases & functions
```
