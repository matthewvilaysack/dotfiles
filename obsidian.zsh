# Obsidian + filesystem helpers. Sourced from ~/.zshrc.
# Requires: fzf, fd, rg, bat (brew install fzf fd ripgrep bat).

: "${OBSIDIAN_VAULT:=$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/zettelkasten 2}"
export OBSIDIAN_VAULT
OBSIDIAN_VAULT_NAME="${OBSIDIAN_VAULT:t}"

_obs_urlencode() {
  local s="$*"
  s="${s// /%20}"
  s="${s//\#/%23}"
  s="${s//\?/%3F}"
  s="${s//&/%26}"
  print -rn -- "$s"
}

_obs_open_note() {
  local rel="${1%.md}"
  local v n
  v=$(_obs_urlencode "$OBSIDIAN_VAULT_NAME")
  n=$(_obs_urlencode "$rel")
  open "obsidian://open?vault=${v}&file=${n}"
}

# obs: fuzzy-pick any note, open in Obsidian app.
obs() {
  local rel
  rel=$(cd "$OBSIDIAN_VAULT" && fd -e md --color=never . \
    | fzf --preview="bat --color=always --style=plain --line-range=:200 \"$OBSIDIAN_VAULT/{}\"") || return
  _obs_open_note "$rel"
}

# obsg <query>: ripgrep across the vault, fzf the hits, open the chosen note.
obsg() {
  [[ $# -eq 0 ]] && { echo "usage: obsg <query>"; return 1; }
  local hit file
  hit=$(rg --line-number --no-heading --color=never --smart-case "$@" "$OBSIDIAN_VAULT" \
    | fzf --delimiter=: \
          --preview='bat --color=always --style=plain --highlight-line={2} "{1}"' \
          --preview-window='right:60%') || return
  file="${hit%%:*}"
  _obs_open_note "${file#$OBSIDIAN_VAULT/}"
}

# obsd: open today's daily note (Daily Notes/YYYY-MM-DD). Obsidian creates it if missing.
obsd() {
  _obs_open_note "Daily Notes/$(date +%Y-%m-%d)"
}

# obs-recent: pick from notes touched in the last 14 days.
obs-recent() {
  local rel
  rel=$(cd "$OBSIDIAN_VAULT" && fd -e md --changed-within=14d . \
    | fzf --preview="bat --color=always --style=plain --line-range=:200 \"$OBSIDIAN_VAULT/{}\"") || return
  _obs_open_note "$rel"
}

# obs-urls [file]: extract every http(s):// link from a note, fzf, open in browser.
# With no arg, fzf-picks the note first.
obs-urls() {
  local file="$1"
  if [[ -z "$file" ]]; then
    local rel
    rel=$(cd "$OBSIDIAN_VAULT" && fd -e md . | fzf) || return
    file="$OBSIDIAN_VAULT/$rel"
  fi
  [[ -f "$file" ]] || { echo "no such file: $file" >&2; return 1; }
  local url
  url=$(rg -oN 'https?://[^[:space:])\]]+' "$file" | sort -u | fzf) || return
  open "$url"
}

# obs-grep <query>: like obsg but stays in the terminal — opens the picked file in $EDITOR (nvim).
obs-grep() {
  [[ $# -eq 0 ]] && { echo "usage: obs-grep <query>"; return 1; }
  local hit file line
  hit=$(rg --line-number --no-heading --color=never --smart-case "$@" "$OBSIDIAN_VAULT" \
    | fzf --delimiter=: \
          --preview='bat --color=always --style=plain --highlight-line={2} "{1}"' \
          --preview-window='right:60%') || return
  file="${hit%%:*}"
  line="${${hit#*:}%%:*}"
  ${EDITOR:-nvim} "+${line}" "$file"
}
