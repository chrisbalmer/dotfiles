SYSINFO="$(uname -s)"
case "${SYSINFO}" in
    Linux*)     export CORE_OS=Linux;;
    Darwin*)    export CORE_OS=MacOS;;
    *)          export CORE_OS="UNKNOWN:${SYSINFO}"
esac

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
export GOPATH=$HOME/go
export PATH=/opt/homebrew/opt/make/libexec/gnubin:$PATH:$GOPATH/bin:/opt/homebrew/bin:$HOME/.local/bin
export FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
export TERRAGRUNT_PARALLELISM=1
export KUBECONFIG=~/.kube/config:~/.kube/bootstrap.conf:~/.kube/xsoar8.conf
export TERRAGRUNT_PROVIDER_CACHE=1
export GOPRIVATE=gitea.labgophers.com

# SSH Agent for 1Password and MacOS
if [[ $CORE_OS == "MacOS" ]]; then
    AGENT="$HOME/.1password/agent.sock"
    if [ -S $AGENT ]; then
        export SSH_AUTH_SOCK=$AGENT
    fi
fi

# Set 1Password account for terraform provider
if command -v op 2>&1 >/dev/null; then
    export OP_ACCOUNT=$(op account ls | sed -n 2p | awk '{ print $3}')
    [ -d $HOME/.config/op ] && chmod 0700 $HOME/.config/op/
    [ -f $HOME/.config/op/config ] && chmod 0600 $HOME/.config/op/config
fi

# Aliases
alias k=kubectl
alias kn="kubectl config set-context --current --namespace="
alias kgns="kubectl get namespaces"
alias kgc="kubectl config get-contexts"
alias kdco="kubectl config delete-context"
alias kdcl="kubectl config delete-cluster"
alias ksc="kubectl config use-context"

alias ds="docker run --rm -i -t --entrypoint=/bin/bash"  
alias dssh="docker run --rm -i -t --entrypoint=/bin/sh"
alias xs=demisto-sdk
alias shpod="k attach -n shpod -ti shpod"
alias tc="talosctl"

# Docker bash shell here using specified image
function dsh() {  
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}

# Docker sh shell here using specified image
function dsshh() {  
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/sh -v `pwd`:/${dirname} -w /${dirname} "$@"
}

# Clear DNS cache for MacOS
function clear_cache() {
    if [[ $CORE_OS == "MacOS" ]]; then
        sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
        echo "Cache cleared."
    else
        echo "Unsupported OS for this command. Please add support for $CORE_OS."
    fi
}

function cortex_env() {
    export DEMISTO_BASE_URL=$(op read op://homelab/$1/hostname)
    export DEMISTO_API_KEY=$(op read op://homelab/$1/credential)
    TEMP_AUTH_ID=$(op read op://homelab/$1/username)
    if [ -z "${TEMP_AUTH_ID}" ]; then
        unset XSIAM_AUTH_ID
        echo "Loaded $1 environment for XSOAR 6."
    else
        export XSIAM_AUTH_ID=$TEMP_AUTH_ID
        echo "Loaded $1 environment for XSIAM or XSOAR 8."
    fi
}

function ghcr_login() {
    op read "op://Private/$(hostname) docker auth GitHub/token" | docker login ghcr.io -u $(op read "op://Private/$(hostname) docker auth GitHub/username") --password-stdin
}

function coder_cloudflared_setup() {
    cloudflared access login https://coder.labgophers.com
    export CODER_HEADER=cf-access-token=$(cloudflared access token -app=http://coder.labgophers.com)
    coder login
    coder config-ssh
}

# Completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit

if command -v kubectl &> /dev/null
then
    source <(kubectl completion zsh)
fi

eval "$(starship init zsh)"

export PATH="$PATH:$HOME/.lmstudio/bin"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/chrisbalmer/.lmstudio/bin"
# End of LM Studio CLI section

