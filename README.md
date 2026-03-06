# dotfiles

Terminal-centric development environment for macOS and Linux.

## Quick Start

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
exec zsh
```

Then in tmux: `prefix + I` to install tmux plugins.

---

## What's Included

### Zsh

Lean config without Oh-My-Zsh. Plugins loaded directly from system packages.

| Plugin | Purpose |
|--------|---------|
| zsh-vi-mode | Vi keybindings with proper mode switching |
| zsh-autosuggestions | Fish-like inline suggestions from history |
| zsh-syntax-highlighting | Command coloring as you type |
| zsh-history-substring-search | Up/Down arrows filter history by current input |

Shell tools:
- **starship** -- async prompt (minimal: dir + exit code + vi mode + cmd duration)
- **zoxide** -- `z` for smart directory jumping
- **eza** -- `ls` replacement with git status and icons
- **fzf** -- `Ctrl-R` fuzzy history, `Ctrl-T` file finder, `Alt-C` dir jumper

Tool init output is cached in `~/.cache/zsh/` for fast startup (~150ms).
Run `zsh-recache` after upgrading starship/zoxide/fzf.

### tmux

Vi copy-mode, mouse support, vim-style pane navigation.

| Binding | Action |
|---------|--------|
| `prefix + \|` | Split horizontal |
| `prefix + -` | Split vertical |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + H/J/K/L` | Resize panes |
| `v` (copy mode) | Begin selection |
| `y` (copy mode) | Yank to system clipboard |

Status bar shows session name, window tabs, git status (via gitmux), and time.
Clipboard uses `pbcopy` on macOS, `xclip` on Linux (auto-detected).

Plugins (via TPM):
- tmux-sensible, tmux-yank, tmux-resurrect, tmux-open, tmux-thumbs

### Neovim

Single-file config (`nvim/init.lua`) using lazy.nvim. Plugins auto-install on first launch.

Core plugins:
- **nvim-tree** -- file explorer (`\e`)
- **fzf-lua** -- fuzzy finder (`\ff` files, `\fg` grep, `\fb` buffers, `\fr` recent)
- **nvim-lspconfig + Mason** -- LSP (clangd, pyright auto-installed)
- **blink.cmp** -- autocompletion (LSP, path, buffer sources)
- **treesitter** -- syntax highlighting (C, C++, Python, Bash, Lua, etc.)
- **gitsigns** -- git diff markers in the gutter
- **trouble.nvim** -- diagnostics list (`\xx`)
- **vim-airline** -- status line with buffer tabs (`\1`-`\9` to switch)
- **undotree** -- visual undo history
- **nvim-autopairs** -- auto-close brackets/quotes

Colorscheme: solarized dark.

## File Layout

```
~/dotfiles/
  bootstrap.sh          # install deps + symlink everything
  zshrc                 # -> ~/.zshrc
  zshenv                # -> ~/.zshenv
  tmux.conf             # -> ~/.tmux.conf
  gitmux.conf           # -> ~/.gitmux.conf
  config/
    starship.toml       # -> ~/.config/starship.toml
  nvim/
    init.lua            # -> ~/.config/nvim/init.lua
```

## Platform Support

| | macOS (Intel) | macOS (Apple Silicon) | Linux (Debian/Ubuntu) | Linux (Arch) | Linux (Fedora) |
|---|---|---|---|---|---|
| Package install | Homebrew | Homebrew | apt + binary installs | pacman + yay | dnf + binary installs |
| Clipboard | pbcopy | pbcopy | xclip | xclip | xclip |
| Zsh plugins | Homebrew | Homebrew | git clone to ~/.local | pacman | git clone to ~/.local |

## Dependencies

Installed automatically by `bootstrap.sh`:

- zsh, tmux, neovim, git
- fzf, ripgrep
- starship, zoxide, eza, gitmux
- zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search, zsh-vi-mode
- xclip (Linux only)
- A Nerd Font (install manually -- e.g. Hack Nerd Font) for file icons in eza and nvim-tree
