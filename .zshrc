SYSINFO="$(uname -s)"
case "${SYSINFO}" in
    Linux*)     export CORE_OS=Linux;;
    Darwin*)    export CORE_OS=MacOS;;
    *)          export CORE_OS="UNKNOWN:${SYSINFO}"
esac

unsetopt inc_append_history
unsetopt share_history
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/opt/homebrew/bin:$HOME/.local/bin
export TERRAGRUNT_PARALLELISM=1
export KUBECONFIG=~/.kube/config:~/.kube/bootstrap.conf:~/.kube/xsoar8.conf
export ZSH_DISABLE_COMPFIX=true
export TERRAGRUNT_PROVIDER_CACHE=1

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
    chmod 0700 ~/.config/op/
    chmod 0600 ~/.config/op/config
fi

plugins=(
  git
  terraform
  ansible
  kube-ps1
)

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

# Legacy items to remove
alias ztheme='(){ export ZSH_THEME="$@" && source $ZSH/oh-my-zsh.sh }'
alias ss='eval "$(starship init zsh)"'
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"

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
    export DEMISTO_BASE_URL=$(op read op://private/$1/hostname)
    export DEMISTO_API_KEY=$(op read op://private/$1/credential)
    TEMP_AUTH_ID=$(op read op://private/$1/username)
    if [ -z "${TEMP_AUTH_ID}" ]; then
        unset XSIAM_AUTH_ID
        echo "Loaded $1 environment for XSOAR 6."
    else
        export XSIAM_AUTH_ID=$TEMP_AUTH_ID
        echo "Loaded $1 environment for XSIAM or XSOAR 8."
    fi
}

function coder_cloudflared_setup() {
    cloudflared access login https://coder.labgophers.com
    export CODER_HEADER=cf-access-token=$(cloudflared access token -app=http://coder.labgophers.com)
    coder login
    coder config-ssh
}

autoload -Uz compinit
compinit

autoload -U +X bashcompinit && bashcompinit
#complete -o nospace -C /usr/local/bin/mc mc

#Auto complete for kubectl
if command -v kubectl &> /dev/null
then
    source <(kubectl completion zsh)
fi

complete -o nospace -C /usr/local/bin/mc mc
eval "$(starship init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/chrisbalmer/.lmstudio/bin"
