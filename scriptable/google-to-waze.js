const path = args.shortcutParameter;
const parts = path.split("/");
for (const p of parts) {
  if (p.startsWith("@")) {
    const withoutAt = p.slice(1);
    const latlng = withoutAt.split(",");
    const lat = latlng[0];
    const lng = latlng[1];
    let url = "https://waze.com/ul";
    url += "?ll=" + encodeURIComponent(lat + "," + lng);
    url += "&navigate=yes";
    return url;
  }
}
