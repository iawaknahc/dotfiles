## Setting up a new machine

```sh
git clone git@github.com:iawaknahc/dotfiles.git ~/.config/home-manager
sudo vim /etc/nix/nix.conf
# Add the following line to /etc/nix/nix.conf
#
# extra-experimental-features = nix-command flakes
#
# We need that because passing it to nix does not propagate to home-manager.
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
