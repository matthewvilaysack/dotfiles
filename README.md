# dotfiles

Personal shell config for macOS. Symlinked into `$HOME` by `install.sh`.

## What's here

- `zshrc` — main shell rc. Loads oh-my-zsh + powerlevel10k, fzf/zoxide/eza/bat, iTerm2 per-tab auto-coloring, and the Obsidian helpers.
- `zprofile` — login shell init (`brew shellenv`).
- `obsidian.zsh` — `obs`, `obsg`, `obsd`, `obs-recent`, `obs-urls`, `obs-grep`. See below.
- `install.sh` — idempotent symlinker. Backs up any existing `~/.zshrc` / `~/.zprofile`, then symlinks. Also handles `p10k.zsh` once it's been tracked (see below).

## Bootstrap a new machine

```sh
brew install zoxide fzf fd ripgrep bat eza powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
git clone git@github.com:matthewvilaysack/dotfiles.git ~/code/config/dotfiles
~/code/config/dotfiles/install.sh
```

## Tracking a new dotfile

After running `p10k configure` (or generating any other `~/.<file>` you want versioned), import it into the repo with one command — it moves the file in and replaces the original with a symlink:

```sh
~/code/config/dotfiles/install.sh import .p10k.zsh p10k.zsh
git -C ~/code/config/dotfiles add p10k.zsh && git -C ~/code/config/dotfiles commit -m "add p10k config"
```

After that, `install.sh` will keep `~/.p10k.zsh` symlinked to the repo on every machine.

## Obsidian helpers

`OBSIDIAN_VAULT` is set in `obsidian.zsh`. Override before sourcing if your vault lives elsewhere.

| command | does |
| --- | --- |
| `obs` | fzf any `*.md` in vault → opens in Obsidian app |
| `obsg <query>` | rg + fzf across vault → opens hit in Obsidian |
| `obs-grep <query>` | same, but opens in `$EDITOR` (nvim) |
| `obsd` | opens today's daily note (`Daily Notes/YYYY-MM-DD`) |
| `obs-recent` | fzf notes touched in last 14 days |
| `obs-urls [file]` | extract `http(s)://` links → fzf → `open` in browser |

## iTerm2 prefs

iTerm2 settings live in a sibling repo: [`macosx-iterm2-settings`](https://github.com/fnichol/macosx-iterm2-settings) (cloned to `~/code/config/macosx-iterm2-settings`). Vertical tabs on the left and "new tab reuses cwd" are set in the plist there.
