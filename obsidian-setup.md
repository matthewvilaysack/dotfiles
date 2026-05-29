# Obsidian setup

My personal note-taking system. Documented here so others can take inspiration — copy the parts that fit, ignore the rest. Maintained by Matt V.

## Architecture

Four layers, ordered fastest → most durable:

| Layer | Where | Purpose | Lifecycle |
|---|---|---|---|
| 1. Quick capture | `~/notes/<topic>.md` | Free-form scratch when a thought needs to land now | Triaged into the vault within a week, or deleted |
| 2. Daily note | `<vault>/Daily Notes/YYYY-MM-DD.md` | Chronological log auto-filled from git, GitHub, iMessage activity | One per day, kept forever |
| 3. Zettelkasten vault | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/zettelkasten/` | Permanent atomic notes linked by `[[wikilinks]]`, grouped by topic folder | Permanent; cleaned weekly |
| 4. Index MOCs | `<Topic Folder>/<Topic> — Index.md` | Map-of-content pages linking the atomic notes in a folder | Updated when new notes are added |

Vault syncs through iCloud (treat it as personal — never put work secrets there).

## How it works

- **Capture first, classify later.** When a thought lands, write it where it's fastest. Don't try to file it perfectly the first time.
- **The vault is the source of truth.** Anything kept longer than a week lives in the zettelkasten vault with YAML frontmatter (`tags`, `created`) and at least one `[[wikilink]]`.
- **Folders are coarse, links are fine-grained.** Each note lives in exactly one folder but links freely across the vault. Trust the link graph over the folder tree for navigation.
- **Daily notes are an index, not content.** Long-form content gets extracted into a standalone vault note and `[[wikilinked]]` from the daily.
- **Cleanup is scheduled, not constant.** A weekly audit (move stray files, add frontmatter, find orphans, report broken links, update indexes) keeps things sane without per-note overhead.

## Why this design

- **Friction kills capture.** Quick-capture exists because opening Obsidian, picking a folder, and naming a note is too much overhead when an idea is fresh. `~/notes/` accepts anything; triage happens later.
- **Daily notes solve the "where did the day go" problem.** Pulled automatically from real activity (git, PRs, messages), they double as input for monthly hours tracking.
- **Zettelkasten linking compounds over time.** Folders alone don't surface unexpected connections; the `[[wikilink]]` graph does. An unlinked note is a note that won't be found again.
- **Tooling beats discipline.** Three of the four layers are driven by tooling. The system doesn't depend on remembering to file things — it depends on running two commands (daily-note builder in the morning, vault organizer weekly).

## Vault folder map

| Folder | What goes there |
|---|---|
| `Daily Notes/` | `YYYY-MM-DD.md` files |
| `Apple Work/` | Apple team notes, work status docs |
| `Career & Work/` | Job prep, interviews, non-Apple work |
| `CS & Technical/` | Algorithms, courses, tools, systems |
| `Projects/` | Side projects, app ideas, research |
| `Health & Fitness/` | Muay Thai, running, habits, sleep |
| `Music & Creative/` | Guitar, music production, writing |
| `Travel/` | Trips, flights, errands |
| `Finance/` | Budgeting, money, planning |
| `Personal/` | Reflection, journal, mantras |
| `Goals/` | Goals, plans, intentions |
| `Meeting Notes/` | Notes from specific meetings |
| `Attachments/` | Images, PDFs, non-markdown |
| `Archive/` | Untitled notes, stubs, obsolete content |

## Tooling

### Shell helpers (this repo)

In [`obsidian.zsh`](./obsidian.zsh):

| command | does |
| --- | --- |
| `obs` | fzf any `*.md` in vault → opens in Obsidian app |
| `obsg <query>` | rg + fzf across vault → opens hit in Obsidian |
| `obs-grep <query>` | same, but opens in `$EDITOR` (nvim) |
| `obsd` | opens today's daily note |
| `obs-recent` | fzf notes touched in last 14 days |
| `obs-urls [file]` | extract `http(s)://` links → fzf → `open` in browser |

### Claude Code skills (separate repo)

Lives in [`skills-documentation`](https://github.com/matthewvilaysack/skills-documentation). Each skill is installed independently with `make install` and shows up as a `/<name>` slash command.

| skill | does |
|---|---|
| `/daily` | Creates today's daily note. Pulls git commits, GitHub PR activity, and (macOS) iMessage threads into structured sections under your area MOCs |
| `/obsidian-organize` | Five-phase audit: moves stray root files into the right folder, adds YAML frontmatter, finds orphan notes, reports broken `[[wikilinks]]`, updates index MOCs |
| `/note-taking` | Prints this architecture overview — used to onboard a new Claude Code session into the system so it knows where notes belong |
| `/hours`, `/audit-timesheet` | Consume daily notes to build monthly hours |

## Tips for adopting

- **Start with daily notes.** Even without the vault structure, just having `YYYY-MM-DD.md` files you write into is a 10x improvement over nothing.
- **Don't pre-build all the folders.** Add a folder when you have three notes that want to live in it. Folders without contents are clutter.
- **One concept per atomic note.** If a note splits naturally into two ideas, split it and link them. Big notes are hard to link to.
- **Always add at least one link.** Orphan notes get lost. A `/obsidian-organize`-style audit only works if it has a link graph to traverse.
- **Index MOCs live next to their content.** `Music & Creative/Guitar — Index.md`, not `Guitar — Index.md` at vault root.
- **Match the folder names to your actual life, not a generic template.** "Muay Thai" is more useful than "Hobbies".
- **iCloud is fine, Git is also fine, but pick one.** The vault wants a single source of truth across machines.
