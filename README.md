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
