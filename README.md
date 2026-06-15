# Zenatuz Dotfiles 🚀

Personal dotfiles for macOS (primary), Linux (secondary). Zsh + Starship.

## Quick Install (fresh machine)

**Stable (main):**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zenatuz/dotfiles/main/.install.sh)"
```

**Test a branch (e.g. `mac-migration`):**
```bash
curl -fsSL https://raw.githubusercontent.com/zenatuz/dotfiles/mac-migration/.install.sh | bash -s -- mac-migration
```

This will install:
- **Homebrew** + packages from `.brewfile`
- **Starship** prompt
- **ZSH plugins** (autosuggestions, syntax-highlighting)
- **Helm plugins** (diff, secrets, git)
- Clone dotfiles with **yadm**

## What's Included

### Shell

| Tool | What | Why |
|------|------|-----|
| [eza](https://eza.rocks/) | `ls` replacement | Icons, colors, tree view |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` | Learn your habits, jump anywhere |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement | Syntax highlighting, line numbers |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` replacement | Blazing fast, recursive by default |
| [fd](https://github.com/sharkdp/fd) | `find` replacement | Fast, intuitive |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | Ctrl+R, Ctrl+T, fuzzy everything |
| [mcfly](https://github.com/cantino/mcfly) | Shell history | Smart suggestions with AI |
| [starship](https://starship.rs/) | Prompt | Cross-shell, fast, infinitely customizable |
| [git-delta](https://github.com/dandavison/delta) | Git diff | Syntax-highlighted, side-by-side |

### Kubernetes & Cloud (Azure)

| Tool | What |
|------|------|
| `kubectl` via [krew](https://krew.sigs.k8s.io/) | Plugin manager |
| [k9s](https://k9scli.io/) | Kubernetes TUI |
| [kubectx](https://github.com/ahmetb/kubectx) | Context/namespace switcher |
| [stern](https://github.com/stern/stern) | Multi-pod log tailing |
| [popeye](https://popeyecli.io/) | Cluster sanitizer |
| [kube-linter](https://github.com/stackrox/kube-linter) | Manifest linting |
| [kubeconform](https://github.com/yannh/kubeconform) | Schema validation |
| [nova](https://github.com/FairwindsOps/nova) | Outdated Helm charts |
| [pluto](https://github.com/FairwindsOps/pluto) | Deprecated K8s APIs |
| [kubent](https://github.com/doitintl/kube-no-trouble) | K8s API deprecations |
| [helm](https://helm.sh/) | Package manager |
| [trivy](https://github.com/aquasecurity/trivy) | Container/vuln scanner |
| [dive](https://github.com/wagoodman/dive) | Docker image layers |
| [kind](https://kind.sigs.k8s.io/) | K8s in Docker (local clusters) |
| Azure CLI + `aztfexport` | Azure resource export |

### Infrastructure as Code

| Tool | What |
|------|------|
| Terraform via `tfswitch` | Version management |
| `terraform-docs` | Auto-generate docs |
| `terraform-ls` | LSP for VS Code/Neovim |
| [checkov](https://www.checkov.io/) | IaC security scanning |

### macOS Apps (via Brew Bundle)

- [Rancher Desktop](https://rancherdesktop.io/) — Kubernetes + Docker Desktop alternative
- [Raycast](https://raycast.com/) — Spotlight replacement
- [Rectangle](https://rectangleapp.com/) — Window management
- [Ice](https://github.com/jordanbaird/Ice) — Menu bar manager
- [Stats](https://github.com/exelban/Stats) — System monitor menu bar
- [iTerm2](https://iterm2.com/) — Terminal emulator
- [1Password](https://1password.com/) — Password manager
- [Amphetamine](https://apps.apple.com/app/id937984704) — Keep Mac awake
- Azure VPN Client, Microsoft Remote Desktop

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
│   └── starship.toml  # Starship prompt configuration
├── .editorconfig      # Editor settings
├── .gitconfig         # Git configuration (with delta, aliases)
├── .gitignore         # Git ignore rules
├── .helmlist          # Helm plugins
├── .install.sh        # One-shot setup script
├── .vimrc             # Neovim/Vim config
├── .zshrc             # Zsh configuration
├── .zsh/
│   ├── zsh-custom.sh  # Aliases & functions
│   └── plugins/       # Zsh plugins (autosuggestions, syntax-highlighting)
```
