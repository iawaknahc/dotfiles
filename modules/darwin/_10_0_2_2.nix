{
  # On Android emulators, 10.0.2.2 is the host.
  # We alias 10.0.2.2 to the loopback interface of the host.
  # Thus, 10.0.2.2 always means the host.
  launchd.daemons."android-10.0.2.2" = {
    script = ''
      /sbin/ifconfig lo0 alias 10.0.2.2 255.255.255.255
    '';
    serviceConfig = {
      RunAtLoad = true;
    };
  };
}
