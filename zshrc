export PATH="$HOME/.local/bin:$PATH"
# brew on PATH even if ~/.zprofile is not linked on this machine (harmless if it is)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Powerlevel10k instant prompt — must stay near the top of .zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh (optional — guarded so a machine without it still starts cleanly)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # using powerlevel10k instead (sourced below)
plugins=(git macos brew zoxide fzf)
[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# History
export HISTSIZE=50000
export SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# Powerlevel10k theme — prefer the brew formula, fall back to the oh-my-zsh
# custom clone (the brew formula has init issues on some Sequoia setups).
if [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
fi
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Editor
export EDITOR=nvim
export VISUAL=nvim

# iTerm2 per-tab auto color: first tab orange, others rotate through a palette.
# Parses tab index from $ITERM_SESSION_ID (form: w0t0p0:UUID).
if [[ -n "$ITERM_SESSION_ID" ]]; then
  _iterm_tab_color() {
    local rgb=("$@")
    printf '\033]6;1;bg;red;brightness;%d\a'   "${rgb[1]}"
    printf '\033]6;1;bg;green;brightness;%d\a' "${rgb[2]}"
    printf '\033]6;1;bg;blue;brightness;%d\a'  "${rgb[3]}"
  }
  _iterm_auto_tab_color() {
    local tab="${ITERM_SESSION_ID#*t}"; tab="${tab%%p*}"
    local palette=(
      "255 153 0"    # 0 orange  (first tab)
      "0 153 204"    # 1 cyan
      "153 102 204"  # 2 purple
      "0 170 102"    # 3 green
      "204 51 102"   # 4 magenta
      "102 153 204"  # 5 steel blue
      "204 153 51"   # 6 amber
      "153 51 51"    # 7 brick
    )
    local idx=$(( tab % ${#palette[@]} ))
    local rgb=(${=palette[idx+1]})
    _iterm_tab_color $rgb
  }
  _iterm_auto_tab_color

  # Report the working directory to iTerm2 on every prompt so a new tab,
  # split, or window opens in the current tab's directory. Requires the
  # profile's Initial directory = "Reuse previous session's directory".
  # Self-contained: works even when ~/.iterm2_shell_integration.zsh is absent.
  autoload -Uz add-zsh-hook
  _iterm2_report_cwd() { printf '\033]1337;CurrentDir=%s\a' "$PWD"; }
  add-zsh-hook precmd _iterm2_report_cwd
fi

# Modern CLI tools
eval "$(zoxide init zsh)"
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
alias ls='eza --group-directories-first'
alias ll='eza -lah --git --group-directories-first'
alias lt='eza -T --git-ignore -L 2'
alias cat='bat --paging=never'

# Man pages with syntax highlighting
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# fzf defaults: respect .gitignore and hidden, exclude .git
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=60% --reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:100 {}'"

# Obsidian helpers (defines OBSIDIAN_VAULT, obs, obsg, obsd, obs-recent, obs-urls, obs-grep)
[[ -f ~/code/config/dotfiles/obsidian.zsh ]] && source ~/code/config/dotfiles/obsidian.zsh

# CTRL doc previews (glow). Uses $OBSIDIAN_VAULT from obsidian.zsh.
alias ctrln='glow -p "$OBSIDIAN_VAULT/CTRL.md"'
alias ctrl-design='glow -p ~/code/CTRL/docs/reverse-ssh.md'
alias ctrl-day='glow -p "$OBSIDIAN_VAULT/Mac Mini Day 1 - 2026-05-07.md"'

# Plugins (must load after oh-my-zsh; syntax-highlighting must load LAST)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# direnv — auto-load .envrc per directory
eval "$(direnv hook zsh)"

# atuin — better shell history (replaces CTRL+R)
eval "$(atuin init zsh)"

# iTerm2 shell integration (Cmd-Shift-↑/↓ jumps between prompts). Optional;
# the CurrentDir report above already handles new-tab directory inheritance.
[[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh

# Syntax highlighting must be last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$HOME/bin:$PATH"

# Apple internal CA bundle for curl (fixes share-page shortlink SSL)
export CURL_CA_BUNDLE="$HOME/.local/share/uv/tools/apple-certifi/lib/python3.13/site-packages/apple_certifi/cacert.pem"

# phone-control: drive Claude Code from the phone via tmux + SSH + Tailscale.
# PHONE_CONTROL_WRAP_CLAUDE=1 makes plain `claude` always launch inside tmux.
export PHONE_CONTROL_WRAP_CLAUDE=1
[[ -f ~/code/phone-control/shell/phone-control.zsh ]] && source ~/code/phone-control/shell/phone-control.zsh

# Personal GSD planning session for maps-cli / nucleus revamp (private repo, no remote)
alias gsd-maps='~/code/gsd/maps-cli/launch.sh'

# Rebase-pull every repo in the maps-cli project (nucleus, neutron-cli, quark, mdf-py-libs)
alias maps-update="~/code/gsd/maps-cli/update.sh"

# Machine-specific overrides and secrets (untracked, not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
