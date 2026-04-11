# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles managed with [chezmoi](https://github.com/twpayne/chezmoi). Chezmoi maps files in this repo to their target locations in `$HOME` using naming conventions.

## Chezmoi file naming conventions

| Prefix/suffix | Meaning |
|---|---|
| `dot_` | Becomes `.` in `$HOME` (e.g. `dot_zshrc.tmpl` → `~/.zshrc`) |
| `.tmpl` suffix | Template file — Go template syntax, variables from `.chezmoi.toml.tmpl` |
| `private_` | File permissions set to 0600 |
| `dot_config/` | Maps to `~/.config/` |
| `dot_zsh/` | Maps to `~/.zsh/` |

## Key commands

```shell
# Apply dotfiles to $HOME
chezmoi apply

# Preview changes without applying
chezmoi diff

# Edit a managed file (opens in $EDITOR, then apply)
chezmoi edit ~/.zshrc

# Re-run after editing files directly in this repo
chezmoi apply --source-path .
```

## Bootstrap / fresh install

```shell
# Full bootstrap (installs Homebrew, git, zsh, Brewfile packages)
./install.sh

# Or manually after Homebrew + chezmoi are present
chezmoi init https://github.com/willscottuk/dotfiles.git
chezmoi apply
```

## Architecture

- **`dot_zshrc.tmpl`** — Main zsh config. Initializes Homebrew (path from `chezmoi.toml.tmpl` template var `{{ .brewbin }}`), then sources sheldon plugins, starship prompt, and the include files from `dot_zsh/includes/`.
- **`dot_zsh/includes/`** — Modular zsh config split into: `aliases.zsh`, `exports.zsh`, `functions.zsh`, `lang.zsh`, `os_switch.zsh`.
- **`dot_zsh/functions/`** — Standalone shell function scripts (`border`, `pk`).
- **`dot_config/sheldon/plugins.toml`** — Zsh plugin manager config (sheldon). Plugins are loaded deferred via `zsh-defer` for performance. Includes: zsh-syntax-highlighting, zsh-completions, ohmyzsh (ssh-agent, git-auto-fetch, asdf plugins), fzf, fzf-tab, zoxide, deco.
- **`dot_config/starship.toml`** — Starship prompt configuration.
- **`setup/Brewfile`** — All Homebrew packages and casks installed on macOS.
- **`.chezmoi.toml.tmpl`** — Chezmoi config template. Sets `brewbin` based on OS (`/opt/homebrew/bin` on macOS, `/home/linuxbrew/.linuxbrew/bin` on Linux). Uses `delta` as diff pager.
- **`private_dot_ssh/authorized_keys`** — SSH authorized keys (deployed with 0600 permissions).

## Template variables

Available in `.tmpl` files via `{{ .chezmoi.* }}` and custom data:
- `{{ .brewbin }}` — Path to Homebrew bin directory (OS-dependent)
- `{{ .chezmoi.os }}` — Operating system (`darwin` / `linux`)
