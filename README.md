## Install nix

Download the installer at https://github.com/DeterminateSystems/nix-installer/releases
and then run it.

Assume the installation IS NOT customized.

## Install home-manager

```sh
git clone git@github.com:iawaknahc/dotfiles.git ~/.config/home-manager
nix run home-manager/master -- switch
```

## Making changes

```
cd ~/.config/home-manager

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

source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# Replace the actual path to nixpkgs.
NIX_PATH="nixpkgs=/nix/store/q3f93ffmyiwswycpwk9gs39lvm1c6qq2-nixpkgs/nixpkgs" nix run home-manager/master -- uninstall
```
