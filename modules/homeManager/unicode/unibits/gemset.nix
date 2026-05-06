{
  characteristics = {
    dependencies = [ "unicode-categories" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xqqdfpmnsx9q866y4wjf64giz0lr7dm8sqfbdqq3vmjkzlvsgzc";
      type = "gem";
    };
    version = "1.8.0";
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
  symbolify = {
    dependencies = [ "characteristics" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l99q8ahdkzc5z6lfn0gfann7s9gqgc8i1bzh371dmg00hbypbk0";
      type = "gem";
    };
    version = "1.4.1";
  };
  unibits = {
    dependencies = [
      "characteristics"
      "paint"
      "rationalist"
      "symbolify"
      "unicode-display_width"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09z29dn3rzc4snpi2rbcw9pk3qa9hbj4v63093xzvdhm1h0vgiaf";
      type = "gem";
    };
    version = "2.14.0";
  };
  unicode-categories = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "134zc7bzxyy26l4pqsvxrmldcazh11ya1q6fjxnlv4rd2r1v8czz";
      type = "gem";
    };
    version = "1.11.0";
  };
  unicode-display_width = {
    dependencies = [ "unicode-emoji" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hiwhnqpq271xqari6mg996fgjps42sffm9cpk6ljn8sd2srdp8c";
      type = "gem";
    };
    version = "3.2.0";
  };
  unicode-emoji = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1995yfjbvjlwrslq48gzzc9j0blkdzlbda9h90pjbm0yvzax55s9";
      type = "gem";
    };
    version = "4.1.0";
  };
}
