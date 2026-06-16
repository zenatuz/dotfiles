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
- Clone dotfiles with **yadm**

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

| Tool | What |
|------|------|
| [krew](https://krew.sigs.k8s.io/) | kubectl plugin manager |
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
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) | Azure resource management + export |

### Infrastructure as Code

| Tool | What |
|------|------|
| [tenv](https://github.com/tofuutils/tenv) | Terraform/OpenTofu version manager |
| [terraform-docs](https://terraform-docs.io/) | Auto-generate Terraform docs |
| [terraform-ls](https://github.com/hashicorp/terraform-ls) | Terraform Language Server |
| [checkov](https://www.checkov.io/) | IaC security scanning |

### macOS Apps (via Brew Bundle)

- [Ghostty](https://ghostty.org/) — GPU-accelerated terminal emulator
- [Rancher Desktop](https://rancherdesktop.io/) — Kubernetes + Docker Desktop alternative
- [Raycast](https://raycast.com/) — Spotlight replacement
- [Rectangle](https://rectangleapp.com/) — Window management
- [Ice](https://github.com/jordanbaird/Ice) — Menu bar manager
- [Stats](https://github.com/exelban/Stats) — System monitor menu bar
- [1Password](https://1password.com/) — Password manager
- [Amphetamine](https://apps.apple.com/app/id937984704) — Keep Mac awake
- Azure VPN Client, Microsoft Remote Desktop

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
│   └── starship.toml  # Starship prompt with k8s/azure/terraform
├── .editorconfig      # Editor settings
├── .gitconfig         # Git configuration (with delta, aliases)
├── .gitignore         # Git ignore rules
├── .helmlist          # Helm plugins
├── .install.sh        # One-shot setup script
├── .ssh/
│   └── config         # SSH hosts (GitHub, Azure DevOps)
├── .vimrc             # Vim/Neovim config (line numbers, syntax, indentation)
├── .zshrc             # Zsh configuration
├── .zsh/
│   ├── zsh-custom.sh  # Aliases & functions
│   └── plugins/       # Zsh plugins (autosuggestions, syntax-highlighting)
```
