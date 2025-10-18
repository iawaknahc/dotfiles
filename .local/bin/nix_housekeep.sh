#!/bin/sh

# 1. Remove home-manager old generations.
# 2. Remove nix profile old generations.
# 3. Tell nix to perform GC.
#
# `nix-env --delete-generations old` has to be run separately
# because `sudo nix-collect-garbage --delete-old` does not seem to remove the profiles.
#
# `nix-collect-garbage --delete-old` has to be invoked with sudo to clean up
# the old generations of nix-darwin.
# See https://github.com/LnL7/nix-darwin/issues/237#issuecomment-716021555

home-manager expire-generations now && nix-env --delete-generations old && sudo nix-collect-garbage --delete-old
