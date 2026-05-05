{
  # FIXME: `nix flake check` failed due to nix-unit.
  # Maybe related to https://github.com/nix-community/nix-unit/issues/270
  # Since we still rely on invoking `nix-unit` directly to run tests,
  # we disable copying to avoid the same test being run twice.
  perSystem.nix-unit.enableSystemAgnostic = false;
  flake.tests = {
    md5toUUID = import ../../lib/md5toUUID.test.nix;
    userscript_metadata_block = import ../../lib/userscript_metadata_block/default.test.nix;
  };
}
