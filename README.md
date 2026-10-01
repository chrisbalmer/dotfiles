# dotfiles

zsh, starship, git and 1Password SSH agent configuration for macOS, and for
[Coder](https://coder.com) workspaces (Linux).

## Install

```bash
git clone git@github.com:chrisbalmer/dotfiles.git ~/code/dotfiles
~/code/dotfiles/setup.sh
```

`setup.sh` links the files into your home directory. A real file it would replace is kept once
as `<name>.old`; existing links are just re-pointed, so it's safe to run again. In a Coder
workspace, set this repository as the dotfiles URL: Coder clones it and runs `setup.sh` on every
start.

## Machine-specific settings: `~/.zshrc.local`

Anything that belongs to one environment rather than to this public repo (internal hostnames,
code-signing identities and so on) goes in `~/.zshrc.local`, which `.zshrc` sources last if it
exists. It's never committed.

On macOS its master copy is a 1Password Document, so every Mac gets the same file:

- `setup.sh` runs `scripts/zshrc-local-sync.sh` when the 1Password CLI is installed. It writes
  the Document to `~/.zshrc.local` (mode 600) and prints a diff when something changed.
- After editing the Document, run `zshrc_local_sync` in each Mac's shell.
- The Document defaults to `zshrc.local` in the vault `Private`; set `ZSHRC_LOCAL_DOCUMENT` and
  `ZSHRC_LOCAL_VAULT` to use another.

Coder workspaces don't get `~/.zshrc.local`. Give them what they need as
[Coder user secrets](https://coder.com/docs) injected as environment variables, for example
`printf %s 'git.example.com' | coder secret create goprivate --env GOPRIVATE`.

## Commit guard

`setup.sh` sets `core.hooksPath` to `hooks/`, whose `pre-commit` refuses a commit that would
publish a macOS home path, a `.local` host name or address, or any value exported in
`~/.zshrc.local`, in either the staged changes or the author identity. More strings can go in
`~/.config/dotfiles/denylist`, one per line. Installers that append to `~/.zshrc` (a link into
this repo) are the usual way such values get in.

## Known Issues

- **MinIO mc zsh autocompletion**: S3 path autocompletion does not work in zsh. [Tracking issue](https://github.com/minio/mc/issues/5075)
