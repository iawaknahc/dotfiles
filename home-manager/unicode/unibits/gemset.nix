{
  characteristics = {
    dependencies = ["unicode-categories"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04dbsnkq6m342y8c42clj81zrm272gn85qq7krgv96icr59sz0id";
      type = "gem";
    };
    version = "1.7.1";
  };
  paint = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r9vx3wcx0x2xqlh6zqc81wcsn9qjw3xprcsv5drsq9q80z64z9j";
      type = "gem";
    };
    version = "2.3.0";
  };
  rationalist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zydr81pc63m7i5f5s51ryksv3g2qya5pd42s09v9ixk3fddpxgi";
      type = "gem";
    };
    version = "2.0.1";
  };
  symbolify = {
    dependencies = ["characteristics"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0l99q8ahdkzc5z6lfn0gfann7s9gqgc8i1bzh371dmg00hbypbk0";
      type = "gem";
    };
    version = "1.4.1";
  };
  unibits = {
    dependencies = ["characteristics" "paint" "rationalist" "symbolify" "unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ja19mwymdl9dlqrjclnw3v4wc7wp7kbq30ck9mhcdlaf3b6ghas";
      type = "gem";
    };
    version = "2.13.1";
  };
  unicode-categories = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09j2h5jwnh3ggjzkis95yyajx8zq2bpwjdxi8p1qy0356p0zw3qd";
      type = "gem";
    };
    version = "1.10.0";
  };
  unicode-display_width = {
    dependencies = ["unicode-emoji"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1has87asspm6m9wgqas8ghhhwyf2i1yqrqgrkv47xw7jq3qjmbwc";
      type = "gem";
    };
    version = "3.1.4";
  };
  unicode-emoji = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ajk6rngypm3chvl6r0vwv36q1931fjqaqhjjya81rakygvlwb1c";
      type = "gem";
    };
    version = "4.0.4";
  };
}
