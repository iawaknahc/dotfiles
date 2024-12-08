## Setting up a new machine

```sh
git clone git@github.com:iawaknahc/dotfiles.git ~/.local/share/chezmoi
chezmoi apply --verbose
```

## Making changes

```
# Make your change in the destination directory, that is, in $HOME.
# One big reason is that the filetype detection and syntax highlighting will just work.
# If you make change in the source directory, due to the naming convention of chezmoi,
# filetype detection will not work most of the time.

# After you have finished making changes, run this.
chezmoi re-add

# And then go to the source directory, and review the changes.
cd ~/.local/share/chezmoi
git status

# Finally, use ordinary git commands to record the changes.
git add .
git commit
```

## Fennel

To update `~/.config/nvim/lua/fennel.lua`, do

```
git clone git@github.com:bakpakin/Fennel.git
cd Fennel
git checkout TAG
make fennel.lua
cp fennel.lua ~/.config.nvim/lua/fennel.lua
```

To update `~/.config/nvim/lua/moonwalk.lua`, do

```
wget https://raw.githubusercontent.com/gpanders/nvim-moonwalk/refs/heads/master/lua/moonwalk.lua -O ~/.config/nvim/lua/moonwalk.lua
```
