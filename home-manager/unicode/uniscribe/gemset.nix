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
  unicode-name = {
    dependencies = ["unicode-types"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n92l6p4lvkbmb0596dzl57ysmkl33c1z7f9msl42568p1fr1dpn";
      type = "gem";
    };
    version = "1.13.5";
  };
  unicode-sequence_name = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fbya3xhb9wyhzg4f2s1yr7akz5kk3s917bpld398c3iw1zqgazs";
      type = "gem";
    };
    version = "1.15.3";
  };
  unicode-types = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mif6v3wlfpb69scikpv7i4zq9rhj19px23iym6j8m3wnnh7d2wi";
      type = "gem";
    };
    version = "1.10.0";
  };
  unicode-version = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wlf2kaik6gj7cn28qfxn4awj8b743hvcq5kqhnkyz263lf3disd";
      type = "gem";
    };
    version = "1.5.0";
  };
  uniscribe = {
    dependencies = ["characteristics" "paint" "rationalist" "symbolify" "unicode-display_width" "unicode-emoji" "unicode-name" "unicode-sequence_name" "unicode-version"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y2r05zb389jx02jgnla03yirnfxjdbsxkrm6i0a036p4pgg379w";
      type = "gem";
    };
    version = "1.11.1";
  };
}
