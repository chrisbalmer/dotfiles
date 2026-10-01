SYSINFO="$(uname -s)"
case "${SYSINFO}" in
    Linux*)     export CORE_OS=Linux;;
    Darwin*)    export CORE_OS=MacOS;;
    *)          export CORE_OS="UNKNOWN:${SYSINFO}"
esac

# Where this repo lives (resolved through the ~/.zshrc symlink)
DOTFILES_DIR=${${(%):-%x}:A:h}

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
    [ -d $HOME/.config/op ] && chmod 0700 $HOME/.config/op/
    [ -f $HOME/.config/op/config ] && chmod 0600 $HOME/.config/op/config
    export OP_ACCOUNT=$(op account ls | sed -n 2p | awk '{ print $3}')
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

function opencode_env() {
    export GITEA_ACCESS_TOKEN=$(op read op://homelab/opencode-gitea-mcp/password)
    export OPENCODE_SERVER_PASSWORD=$(op read op://homelab/opencode-web-password/password)
}

# Log in to a Coder deployment behind Cloudflare Access. CODER_URL comes from
# ~/.zshrc.local.
function coder_cloudflared_setup() {
    local url=${CODER_URL:?set CODER_URL in ~/.zshrc.local}
    cloudflared access login "$url"
    export CODER_HEADER=cf-access-token=$(cloudflared access token -app="${url/https:/http:}")
    coder login
    coder config-ssh
}

function btw() {
    claude -p "$*" --model haiku \
        --system-prompt "You are a quick Q&A assistant running in a terminal. Answer the user's question as quickly and concisely as possible. If you don't know the answer, say you don't know." \
        --append-system-prompt "Format output for a terminal: use plain text, short lists, and code blocks where appropriate. Be concise, aim for a few sentences unless the question demands more."
}

# Refresh ~/.zshrc.local from 1Password (macOS; see README)
alias zshrc_local_sync="$DOTFILES_DIR/scripts/zshrc-local-sync.sh"

# Completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
compinit

if command -v kubectl &> /dev/null
then
    source <(kubectl completion zsh)
fi

if command -v starship &> /dev/null
then
    eval "$(starship init zsh)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

# Machine-specific settings, not in this repo (see README). Last, so it can
# override anything above.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
