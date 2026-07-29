{ pkgs, lib, ... }:
{
  assertions = [
    {
      assertion = (lib.versions.major pkgs.nodejs.version) == "24";
      message = "nodejs is no longer 24, which means it is at least 26.";
    }
  ];
  home.packages = with pkgs; [
    nodejs_26
    yarn
    prettier
    typescript-go
  ];
}
