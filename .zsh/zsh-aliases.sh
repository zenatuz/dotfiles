# ALIASES COMMANDS
###################################################

# Alias: Show aliases
alias aliases="cat ~/.zsh/zsh-aliases.sh"

# Alias: Show Functions
alias functions="grep '()' ~/.zsh/zsh-functions.sh"

# Alias: Use exa to show icons when ls
alias ls="exa --icons --group-directories-first"

# Alias: Short for 'ls -l'
alias ll="ls -l"

# Alias: Short for 'ls -la'
alias la="ls -la"

# Alias: Export variables on .env files on current directory
# alias setdotenv="if [ -f .env ]; then;export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst);fi"

# Alias: Fix corrupted history file
alias fixhistory="cd ~;mv .zsh_history .zsh_history_bad;strings -eS .zsh_history_bad > .zsh_history;fc -R .zsh_history" 

# Alias: Short for update repositories
alias update="brew update > /dev/null"

# Alias: Use Nvim as default text-editor
alias vi="nvim"
alias vim="nvim"

# Alias: Httpie default parameters
alias http="http --follow --all"

# Alias: kubectl
alias k="kubectl"

# Alias: kubectx
alias kctx="kubectx"

# Alias: k9s
alias k9s="k9s -A"

# Alias: docker
alias d-up="docker-compose up --remove-orphans"

# Alias: CD Alviere code directory
alias cd-a="cd ~/code/mezu/repos/"
alias cd-i="cd ~/code/mezu/repos/infra"
alias cd-it="cd ~/code/mezu/repos/infra/terraform"
alias cd-itm="cd ~/code/mezu/repos/infra/terraform/modules"
alias cd-itd="cd ~/code/mezu/repos/infra/terraform/deploy"
alias cd-itda="cd ~/code/mezu/repos/infra/terraform/deploy/alviere"
alias cd-itaps="cd ~/code/mezu/repos/infra/terraform/aps"
alias cd-itask="cd ~/code/mezu/repos/infra/tasks"
alias cd-ih="cd ~/code/mezu/repos/infra/helm/"
alias cd-ihc="cd ~/code/mezu/repos/infra/helm/core"
alias cd-ihp="cd ~/code/mezu/repos/infra/helm/platform"
alias cd-d="cd ~/code/mezu/repos/docker"

# Alias: kctx-env
alias kctx-dev-core="kubectx arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-core-001"
alias kctx-dev-data="kubectx arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-data-001"
alias kctx-dev-platform="kubectx arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-platform-001"
alias kctx-stg-core="kubectx arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-core-001"
alias kctx-stg-data="kubectx arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-data-001"
alias kctx-snd-core="kubectx arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-core-001"
alias kctx-snd-data="kubectx arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-data-001"
alias kctx-prd-core="kubectx arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-core-001"
alias kctx-prd-data="kubectx arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-data-001"
alias kctx-dr="kubectx arn:aws:eks:us-east-1:486983068138:cluster/alv-prd002s-core-001"
alias kctx-gitlab="kubectx arn:aws:eks:us-east-1:730860714720:cluster/gitlab-eks001"
alias kctx-rancher="kubectx rancher-desktop"

# Alias: k9s
alias k9s-dev-core="k9s --context arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-core-001 -A"
alias k9s-dev-data="k9s --context arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-data-001 -A"
alias k9s-dev-platform="k9s --context arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-platform-001 -A"
alias k9s-stg-core="k9s --context arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-core-001 -A"
alias k9s-stg-data="k9s --context arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-data-001 -A"
alias k9s-snd-core="k9s --context arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-core-001 -A"
alias k9s-snd-data="k9s --context arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-data-001 -A"
alias k9s-prd-core="k9s --context arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-core-001 -A"
alias k9s-prd-data="k9s --context arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-data-001 -A"
alias k9s-dr="k9s --context arn:aws:eks:us-east-1:486983068138:cluster/alv-prd002s-core-001 -A"
alias k9s-gitlab="k9s --context arn:aws:eks:us-east-1:730860714720:cluster/gitlab-eks001 -A"
alias k9s-rancher="k9s --context rancher-desktop"