export PATH="$HOME/.local/bin:$PATH"

# Powerlevel10k instant prompt — must stay near the top of .zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # using brew-installed powerlevel10k instead
plugins=(git macos brew zoxide fzf)
source $ZSH/oh-my-zsh.sh

# Powerlevel10k theme (cloned to oh-my-zsh custom themes; brew formula has init issues on Sequoia)
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

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
fi

# Modern CLI tools
eval "$(zoxide init zsh)"
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
alias ls='eza --group-directories-first'
alias ll='eza -lah --git --group-directories-first'
alias lt='eza -T --git-ignore -L 2'
alias cat='bat --paging=never'

# fzf defaults: respect .gitignore and hidden, exclude .git
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=60% --reverse --border'

# Obsidian helpers (defines OBSIDIAN_VAULT, obs, obsg, obsd, obs-recent, obs-urls, obs-grep)
[[ -f ~/code/config/dotfiles/obsidian.zsh ]] && source ~/code/config/dotfiles/obsidian.zsh

# CTRL doc previews (glow). Uses $OBSIDIAN_VAULT from obsidian.zsh.
alias ctrln='glow -p "$OBSIDIAN_VAULT/CTRL.md"'
alias ctrl-design='glow -p ~/code/CTRL/docs/reverse-ssh.md'
alias ctrl-day='glow -p "$OBSIDIAN_VAULT/Mac Mini Day 1 - 2026-05-07.md"'

# Plugins (must load after oh-my-zsh; syntax-highlighting must load LAST)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# iTerm2 shell integration (Cmd-Shift-↑/↓ jumps between prompts).
[[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh

# Machine-specific overrides (untracked).
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
