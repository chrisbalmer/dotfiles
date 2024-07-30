export KUBECONFIG=~/.kube/config:~/.kube/bootstrap.conf:~/.kube/xsoar8.conf
export ZSH_DISABLE_COMPFIX=true
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="af-magic"

plugins=(
  git
  terraform
  ansible
  kube-ps1
)

#source $ZSH/oh-my-zsh.sh
unsetopt inc_append_history
unsetopt share_history
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GO111MODULE=auto
export TERRAGRUNT_PARALLELISM=1

alias k=kubectl
alias ds="docker run --rm -i -t --entrypoint=/bin/bash"  
alias dssh="docker run --rm -i -t --entrypoint=/bin/sh"
alias xs=demisto-sdk
alias ztheme='(){ export ZSH_THEME="$@" && source $ZSH/oh-my-zsh.sh }'
alias shpod="k attach -n shpod -ti shpod"
alias ss='eval "$(starship init zsh)"'

function dsh() {  
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}

function dsshh() {  
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/sh -v `pwd`:/${dirname} -w /${dirname} "$@"
}

function clear_cache() {
    sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
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
