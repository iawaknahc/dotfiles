{
  clipboard = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j019v0fzhamgr1ik08xb17z5kfrmkryrlw2qd8n8l4p43ylil48";
      type = "gem";
    };
    version = "2.0.0";
  };
  paint = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1r9vx3wcx0x2xqlh6zqc81wcsn9qjw3xprcsv5drsq9q80z64z9j";
      type = "gem";
    };
    version = "2.3.0";
  };
  rationalist = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zydr81pc63m7i5f5s51ryksv3g2qya5pd42s09v9ixk3fddpxgi";
      type = "gem";
    };
    version = "2.0.1";
  };
  unicopy = {
    dependencies = [
      "clipboard"
      "paint"
      "rationalist"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "056p3r570jhqnglncczb5b975wgva0xs7aalzwmgrqvpvgj2qpqi";
      type = "gem";
    };
    version = "1.0.3";
  };
}
