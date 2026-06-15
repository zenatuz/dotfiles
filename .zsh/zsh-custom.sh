# ═══════════════════════════════════════════════════════════════════
# ALIASES
# ═══════════════════════════════════════════════════════════════════

# ─── Navigation ───────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias aliases="cat ~/.zsh/zsh-custom.sh"

# ─── ls (eza) ─────────────────────────────────────────────────────
alias ls="eza --icons --group-directories-first"
alias ll="ls -l"
alias la="ls -la"
alias lla="ls -la"

# ─── Modern tool replacements ──────────────────────────────────────
alias cat="bat"
alias grep="rg"
alias find="fd"

# ─── Git ──────────────────────────────────────────────────────────
alias g="git"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph"
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gm="git merge"
alias gr="git rebase"
alias gst="git stash"

# ─── Kubernetes ───────────────────────────────────────────────────
alias k="kubectl"
alias kctx="kubectx"
alias kns="kubens"
alias k9s="k9s -A"
alias k9s-all="k9s -A"
alias stern="stern --tail 50"

# ─── Local clusters ───────────────────────────────────────────────
alias k9s-rch="k9s --context rancher-desktop"
alias kctx-rch="kubectx rancher-desktop"

# ─── Docker / Containers ──────────────────────────────────────────
alias d-up="docker compose up --remove-orphans"
alias d-down="docker compose down"
alias d-ps="docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"
alias dive="dive --ci"

# ─── nvim ─────────────────────────────────────────────────────────
alias vi="nvim"
alias vim="nvim"

# ─── httpie ───────────────────────────────────────────────────────
alias http="http --follow --all"

# ─── System ───────────────────────────────────────────────────────
alias c="clear"
alias h="history"
alias hg="history | grep"
alias path='echo "${PATH//:/\n}"'
alias fixhistory="cd ~;mv .zsh_history .zsh_history_bad;strings -eS .zsh_history_bad > .zsh_history;fc -R .zsh_history"
alias update="brew update && brew upgrade && brew cleanup"
alias ip="curl -s https://checkip.amazonaws.com 2>/dev/null || echo 'checkip unavailable'"
alias localip="ipconfig getifaddr en0 2>/dev/null || hostname -I 2>/dev/null | awk '{print \$1}'"
alias ports="lsof -i -P -n | grep LISTEN"

# ═══════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

# ─── Git: pull all repos in current directory ─────────────────────
git_pull_current() {
    R='\033[0;31m'
    G='\033[0;32m'
    NOCOLOR='\033[0m'

    CURRENT_DIR=$(pwd)
    echo "----------------------------------------"
    for DIR in $(find $CURRENT_DIR -maxdepth 2 -name .git -type d | sort | rev | cut -d "/" -f2 | rev); do
        cd "$CURRENT_DIR/$DIR"
        CURRENT_BRANCH=$(git branch --show-current)
        echo "Updating '$DIR'"

        if [[ $CURRENT_BRANCH != "master" ]]; then
            echo "Current branch:$R $CURRENT_BRANCH $NOCOLOR"
        else
            echo "Current branch:$G $CURRENT_BRANCH $NOCOLOR"
        fi

        git fetch origin && git pull && cd ..
        echo "----------------------------------------"
    done
    cd $CURRENT_DIR
}

# ─── Git: show repo details ──────────────────────────────────────
git_details() {
    R='\033[0;31m'
    G='\033[0;32m'
    O='\033[0;33m'
    Y='\033[1;33m'
    NOCOLOR='\033[0m'

    for i in $(find . -maxdepth 2 -name .git -type d | sort); do
        REPOSITORY=$(echo $i | cut -d '/' -f2)
        URL=$(git --git-dir=$i --work-tree $i config --get remote.origin.url)
        CURRENT_BRANCH=$(git --git-dir=$i --work-tree $i branch --show-current)

        echo "Repo Name:$Y $REPOSITORY $NOCOLOR"

        if [[ $CURRENT_BRANCH != "master" ]]; then
            echo "Current branch:$R $CURRENT_BRANCH $NOCOLOR"
        else
            echo "Current branch:$G $CURRENT_BRANCH $NOCOLOR"
        fi

        echo "Repo URL:$O $URL $NOCOLOR"
        echo "------------------------------"
    done
}

# ─── Git: remove merged branches ─────────────────────────────────
git_remove_merged() {
    git branch --merged >/tmp/merged-branches &&
        vi /tmp/merged-branches &&
        xargs git branch -d </tmp/merged-branches
}

# ─── Docker: clean all containers ────────────────────────────────
docker_clean_containers() {
    docker container stop $(docker container ls -aq)
    docker container rm $(docker container ls -aq)
}

# ─── Docker: prune images ────────────────────────────────────────
docker_clean_images() {
    docker image prune -a
}

# ─── K8s: clean old jobs and error pods ──────────────────────────
k8s_clean_jobs() {
    echo "deleting Error pods"
    kubectl get pods | awk 'IF $3 == "Error" { print $1}' | while read pod; do
        echo $pod
        kubectl delete pod $pod
    done
    echo "deleting ContainerCannotRun pods"
    kubectl get pods | awk 'IF $3 == "ContainerCannotRun" { print $1}' | while read pod; do
        echo $pod
        kubectl delete pod $pod
    done
    echo "deleting incomplete jobs older then 1h"
    kubectl get jobs | awk 'IF $2 == "0/1"  && $4 ~ /h|d/ {print $1}' | while read job; do
        echo $job
        kubectl delete job $job
    done
    echo "deleting complete jobs older then 1d"
    kubectl get jobs | awk 'IF $2 == "1/1"  && $4 ~ /d/ {print $1}' | while read job; do
        echo $job
        kubectl delete job $job
    done
}

# ─── K8s: get pods with readiness gates (ALB ingress) ────────────
k8s_get_pods_alb() {
    kubectl get pods -o wide -A | awk '{if ($10 != "<none>") print $0}'
}

# ─── Utils: curl status code ─────────────────────────────────────
curl_sc() {
    URL=$1
    curl -L --max-redirs 5 -I $URL 2>/dev/null | head -n 1 | cut -d$' ' -f2
}

# ─── Utils: extract any archive ──────────────────────────────────
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ─── Utils: create a directory and cd into it ────────────────────
mkcd() {
    mkdir -p "$1" && cd "$1"
}
