# Neovim Config

Personal Neovim config, based on kickstart-modular, with a split module layout.

## Requirements

- Neovim stable (0.10+ recommended)
- `git`, `make`, `gcc`, `unzip`
- `ripgrep` and `fd` (or `fd-find`)
- Clipboard tool (`xclip`, `xsel`, or platform equivalent)

## New Machine Setup

1. Install the requirements above.
2. Back up any existing config:

```sh
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
mv ~/.local/share/nvim ~/.local/share/nvim.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
```

3. Clone this repo:

```sh
git clone https://github.com/sethchart/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
```

4. Start Neovim once to install plugins:

```sh
nvim
```

Optional verification:

```sh
./tests/test.sh
```

## Updating This Config

From `~/.config/nvim`:

```sh
git pull --ff-only
nvim --headless "+Lazy! sync" +qa
```

If you changed local files and `git pull --ff-only` fails:

```sh
git status
```

Then either commit your changes or stash them before pulling.

## Layout

- `init.lua`: entrypoint
- `lua/config/options.lua`: options and globals
- `lua/config/keymaps.lua`: keymaps/autocmds
- `lua/config/plugins.lua`: plugin setup
- `lua/config/plugins/*.lua`: plugin groups
- `tests/`: headless validation tests
