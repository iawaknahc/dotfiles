{
  tailscaleIPv4,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ dig ];
  services.blocky.enable = true;
  services.blocky.settings = {
    minTlsServeVersion = "1.3";
    connectIPVersion = "v4";

    ports = {
      dns = [
        "${tailscaleIPv4}:53"
      ];
      tls = [ ];
      http = [ ];
      https = [ ];
    };

    http3 = {
      enable = false;
    };

    log = {
      level = "info";
      format = "text";
      timestamp = true;
      privacy = true;
    };

    upstreams = {
      init = {
        strategy = "fast";
      };
      strategy = "parallel_best";
      timeout = "2s";
      groups = {
        default = [
          "tcp-tls:1.1.1.1:853"
          "tcp-tls:8.8.8.8:853"
          "tcp-tls:9.9.9.10:853"
        ];
      };
    };

    rebindingProtection = {
      enable = true;
    };

    statistics = {
      enable = false;
    };

    ede = {
      enable = false;
    };

    specialUseDomains = {
      enable = true;
      rfc6762-appendixG = true;
    };

    dnssec = {
      validate = true;
      maxChainDepth = 10;
      cacheExpirationHours = 1;
      maxUpstreamQueries = 30;
      maxNSEC3Iterations = 150;
      clockSkewToleranceSec = 300;
    };

    dns64 = {
      enable = false;
    };

    blocking = {
      denylists = {
        hagezi = [
          "https://github.com/hagezi/dns-blocklists/raw/refs/heads/main/wildcard/multi.txt"
        ];
      };
      clientGroupsBlock = {
        default = [
          "hagezi"
        ];
      };
      blockType = "zeroIp";
      blockTTL = "1m";
      loading = {
        strategy = "fast";
        concurrency = 4;
        maxErrorsPerSource = 5;
        refreshPeriod = "4h";
        downloads = {
          timeout = "30s";
          writeTimeout = "5s";
          readTimeout = "10s";
          readHeaderTimeout = "10s";
          attempts = 3;
          cooldown = "10s";
        };
      };
    };

    caching = {
      minTime = "5m";
      maxTime = "10m";
      maxItemsCount = 10000;
      prefetching = false;
      cacheTimeNegative = "3m";
    };
  };
}
