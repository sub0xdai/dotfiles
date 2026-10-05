# Dotfiles
here are my dotfiles. they are lovely dotfiles. the very best dotfiles, some say the greatest dotfiles. nobody has dotfiles like these. thank you for your attention to this matter

## Setup

GNU Stow manages the links. Each top-level directory is one package, mirroring the path it installs to under `$HOME`.
A package is anything with a dot-prefixed entry at its root, so `art`, `scripts`, and `tasks` are skipped.

Bootstrap a new machine:

    git clone git@github.com:sub0xdai/dotfiles.git ~/dotfiles && ~/dotfiles/scripts/dotfiles

`dotfiles` is on `PATH` and restows every package, so run it after adding one.
If stow reports a conflict with a stock file, move that file aside and rerun.

