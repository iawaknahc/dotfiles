import * as maplibregl from "https://unpkg.com/maplibre-gl@^6/dist/maplibre-gl.mjs";

const env = await (await fetch("env.json")).json();

const map = new maplibregl.Map({
  container: "map",
  style: `https://api.maptiler.com/maps/streets-v4/style.json?key=${env.key}`,
  hash: "zoom_lat_lng_bearing_pitch",
  attributionControl: false,
  center: [env.longitude, env.latitude],
  zoom: env.zoom,
});
map.addControl(
  new maplibregl.NavigationControl({
    showCompass: true,
    showZoom: true,
    visualizePitch: true,
    visualizeRoll: true,
  }),
  "top-right",
);
map.addControl(
  new maplibregl.ScaleControl({
    unit: "metric",
    maxWidth: 100,
  }),
  "bottom-right",
);
