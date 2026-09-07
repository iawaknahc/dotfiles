{
  fetchurl,
}:
fetchurl {
  url = "https://www.1823.gov.hk/common/ical/tc.ics";
  pname = "ics-hong-kong-public-holidays-zh-hant";
  version = "2025-2026-2027";
  hash = "sha256-YPeZOpuh47zvlbchHN0/28AFrQS+n7zfwQSOCNRs8hY=";
  recursiveHash = true;
  downloadToTemp = true;
  postFetch = ''
    mkdir -p $out/share/ics
    mv $downloadedFile $out/share/ics/hong-kong-public-holidays-zh-hant.ics
  '';
}
