# ── History ────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY          # share across sessions
setopt HIST_IGNORE_ALL_DUPS   # no duplicates
setopt HIST_REDUCE_BLANKS     # trim whitespace
setopt HIST_VERIFY            # show expanded history before executing

# ── Completion ────────────────────────────────────────────────────
autoload -Uz compinit
# Only regenerate compinit dump once a day
if [[ -f ~/.zcompdump && ! -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
fi

zstyle ':completion:*' menu select                    # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # colored completions

# ── Options ───────────────────────────────────────────────────────
setopt AUTO_CD                # cd by typing directory name
setopt INTERACTIVE_COMMENTS   # allow # comments in interactive shell
setopt NO_BEEP
setopt COMPLETE_ALIASES       # complete aliases as their expansion (fixes eza aliases)

# ── Platform detection ────────────────────────────────────────────
_user_plugin_dir="$HOME/.local/share/zsh/plugins"

if [[ "$OSTYPE" == darwin* ]]; then
  # Homebrew prefix: /opt/homebrew (Apple Silicon) or /usr/local (Intel)
  _brew_prefix="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}"
  _plugin_dir="$_brew_prefix/share"
  _zvm_path="$_brew_prefix/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
else
  # Linux: check system locations, then user-local (git-cloned) fallback
  if [[ -d /usr/share/zsh/plugins ]]; then
    _plugin_dir="/usr/share/zsh/plugins"  # Arch
  else
    _plugin_dir="/usr/share"              # Debian/Ubuntu
  fi
  _zvm_path="$_plugin_dir/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  [[ -f "$_zvm_path" ]] || _zvm_path="$_user_plugin_dir/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
fi

# ── Vi mode (zsh-vi-mode) ────────────────────────────────────────
[[ -f "$_zvm_path" ]] && source "$_zvm_path"

# Edit command line in $EDITOR with v in normal mode
autoload -Uz edit-command-line; zle -N edit-command-line

# zsh-vi-mode overrides keybindings on init, so we hook into its callback
function zvm_after_init() {
  zvm_bindkey vicmd 'v' edit-command-line

  # fzf keybindings (must be loaded after zsh-vi-mode)
  [[ -f "$_fzf_cache" ]] && source "$_fzf_cache"

  # History substring search keybindings
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
}

# ── Plugins ───────────────────────────────────────────────────────
# Searches system dir, then user-local dir for each plugin
_source_plugin() {
  local name="$1" file="$2"
  for _dir in "$_plugin_dir" "$_user_plugin_dir"; do
    [[ -f "$_dir/$name/$file" ]] && source "$_dir/$name/$file" && return
  done
  # Some distros put the file directly in the share dir
  [[ -f "$_plugin_dir/$file" ]] && source "$_plugin_dir/$file"
}

_source_plugin zsh-autosuggestions zsh-autosuggestions.zsh
_source_plugin zsh-history-substring-search zsh-history-substring-search.zsh
# Syntax highlighting must be sourced last
_source_plugin zsh-syntax-highlighting zsh-syntax-highlighting.zsh

unset _plugin_dir _user_plugin_dir _zvm_path _dir
unfunction _source_plugin

# ── Aliases ───────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -l --icons --git --color-scale'
alias la='eza -la --icons --git --color-scale'
alias lt='eza --tree --icons --level=2'
alias vim=nvim
alias vi=nvim

alias claude-bb='CLAUDE_CONFIG_DIR="$HOME/.claude-bb" claude'

# ── Cached tool init (regenerate with: zsh-recache) ──────────────
_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_zsh_cache_dir" ]] || mkdir -p "$_zsh_cache_dir"

_starship_cache="$_zsh_cache_dir/starship-init.zsh"
_zoxide_cache="$_zsh_cache_dir/zoxide-init.zsh"
_fzf_cache="$_zsh_cache_dir/fzf-init.zsh"

# Generate caches if missing
(( $+commands[starship] )) && [[ ! -f "$_starship_cache" ]] && starship init zsh > "$_starship_cache"
(( $+commands[zoxide] ))   && [[ ! -f "$_zoxide_cache" ]]   && zoxide init zsh > "$_zoxide_cache"
(( $+commands[fzf] ))      && [[ ! -f "$_fzf_cache" ]]      && fzf --zsh > "$_fzf_cache"

[[ -f "$_zoxide_cache" ]]  && source "$_zoxide_cache"
[[ -f "$_starship_cache" ]] && source "$_starship_cache"

# Helper to regenerate all caches
zsh-recache() {
  rm -f "$_zsh_cache_dir"/*.zsh
  echo "Caches cleared. Restart your shell to regenerate."
}
