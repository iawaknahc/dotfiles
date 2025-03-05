## Nix and shell initialization

nix-installer installs a shell script that is expected to be sourced:

- [/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh](https://github.com/NixOS/nix/blob/master/scripts/nix-profile-daemon.sh.in) for a multi-user install.
- [/nix/var/nix/profiles/default/etc/profile.d/nix.sh](https://github.com/NixOS/nix/blob/master/scripts/nix-profile.sh.in) for a single user install.

These two scripts does not prevent being executed more than once. So we need to prevent that ourselves.

Apart from the sh version, a fish version is also available.
For other shells like nushell and elvish, we need a way to source the sh version.

## Shell initialization

- [bash](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html)
- [zsh](https://zsh.sourceforge.io/Doc/Release/Files.html#Startup_002fShutdown-Files)
- [fish](https://fishshell.com/docs/current/language.html#configuration)
  - In particular, fish reads XDG_DATA_DIRS and source the files there.
  - Some Nix packages is known to install fish snippets, such as fzf.
  - For these packages, sourcing of the snippets cannot be prevented.

## Install nix with nix-installer

Download nix-installer at https://github.com/DeterminateSystems/nix-installer/releases
and then run it.

Assume the installation IS NOT customized. So `nix-command` and `flakes` are assumed to be enabled.

nix-installer does a couple of things, some of those will be taken over by nix-darwin:

- [/etc/synthetic.conf](https://github.com/LnL7/nix-darwin/blob/master/modules/system/base.nix)
- [/etc/nix/nix.conf](https://github.com/LnL7/nix-darwin/blob/master/modules/nix/default.nix#L54)
- [/Library/LaunchDaemons/org.nixos.nix-daemon.plist](https://github.com/LnL7/nix-darwin/blob/master/modules/services/nix-daemon.nix#L46)
- [/etc/bashrc](https://github.com/LnL7/nix-darwin/blob/master/modules/programs/bash/default.nix#L56)
- [/etc/zshrc](https://github.com/LnL7/nix-darwin/blob/master/modules/programs/zsh/default.nix#L177)
- [/etc/zshenv](https://github.com/LnL7/nix-darwin/blob/master/modules/programs/zsh/default.nix#L131)

## Install nix-darwin and home-manager

```sh
git clone git@github.com:iawaknahc/dotfiles.git ~/dotfiles

ln -s ~/dotfiles ~/.config/home-manager
sudo ln -s ~/dotfiles /etc/nix-darwin

nix run nix-darwin -- switch
nix run home-manager -- switch
```

## Making changes

```
cd ~/dotfiles

# Make your changes.
# You cannot make changes directly to the managed files because
# they are symlinks to files in the nix store.

# Apply the changes.
home-manager switch

# Finally, use ordinary git commands to record the changes.
git add .
git commit
```

## Uninstall home-manager

```
# Open Terminal.app and make sure the shell is /bin/zsh
# This is to ensure we are not running something that we are going to uninstall.

nix --extra-experimental-features "nix-command flakes" run home-manager -- uninstall
```

## Uninstall nix-darwin

```
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
```
