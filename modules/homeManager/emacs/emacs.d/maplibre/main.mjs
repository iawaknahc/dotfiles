import * as maplibregl from "https://unpkg.com/maplibre-gl@^6/dist/maplibre-gl.mjs";

/// pinWithEmoji and text-offset were written by Claude Code.
const R = 14; // circle radius, in CSS pixels
const TIP = 7; // how far the tip extends below the circle
const PAD = 6; // room for the shadow on the top and sides; keep >= shadowBlur + shadowOffsetY
const RATIO = 2; // draw at 2x so it stays sharp on Retina

function pinWithEmoji(emoji) {
  const w = 2 * (R + PAD);
  const h = PAD + 2 * R + TIP; // the tip is at the very bottom edge
  const canvas = document.createElement("canvas");
  canvas.width = w * RATIO;
  canvas.height = h * RATIO;
  const ctx = canvas.getContext("2d");
  ctx.scale(RATIO, RATIO);

  const cx = w / 2;
  const cy = PAD + R;
  const gap = Math.PI / 7; // where the tip's edges leave the circle, measured from straight down

  // Go round the circle from bottom-left, over the top, to bottom-right, then down to the tip
  const shape = new Path2D();
  shape.arc(cx, cy, R, Math.PI / 2 + gap, Math.PI / 2 - gap);
  shape.lineTo(cx, h);
  shape.closePath();

  ctx.shadowColor = "rgba(0, 0, 0, 0.55)";
  ctx.shadowBlur = 4;
  ctx.shadowOffsetY = 2;
  ctx.fillStyle = "#fff";
  ctx.fill(shape);

  ctx.shadowColor = "transparent";
  ctx.font = `${R + 2}px 'Apple Color Emoji', sans-serif`;
  ctx.textAlign = "left";
  ctx.textBaseline = "alphabetic";

  // Bounding box of the pixels the emoji actually draws, relative to the draw point
  const m = ctx.measureText(emoji);
  const inkWidth = m.actualBoundingBoxLeft + m.actualBoundingBoxRight;
  const inkHeight = m.actualBoundingBoxAscent + m.actualBoundingBoxDescent;
  ctx.fillText(
    emoji,
    cx - inkWidth / 2 + m.actualBoundingBoxLeft,
    cy - inkHeight / 2 + m.actualBoundingBoxAscent,
  );

  return ctx.getImageData(0, 0, canvas.width, canvas.height);
}

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
map.on("styleimagemissing", (e) => {
  if (!e.id.startsWith("emoji:")) return;
  map.addImage(e.id, pinWithEmoji(e.id.slice("emoji:".length)), {
    pixelRatio: 2,
  });
});
map.on("load", () => {
  map.addSource("vulpea", {
    type: "geojson",
    data: "./geojson.json",
  });
  map.addLayer({
    id: "vulpea",
    type: "symbol",
    source: "vulpea",
    layout: {
      "icon-image": [
        "match",
        ["get", "kind"],
        "hospital",
        "emoji:🏥",
        "hotel",
        "emoji:🏨",
        "government",
        "emoji:🏛️",
        "commercial",
        "emoji:🏢",
        "mall",
        "emoji:🏬",
        "residential",
        "emoji:🏠",
        "university",
        "emoji:🏫",
        // fallback
        "emoji:📍",
      ],
      "icon-anchor": "bottom",
      "icon-allow-overlap": true,
      "text-field": ["get", "title"],
      "text-size": 14,
      "text-anchor": "left",
      "text-offset": [(R + 4) / 14, -(R + TIP) / 14],
      "text-optional": true,
    },
    paint: {
      "text-color": "#222",
      "text-halo-color": "#fff",
      "text-halo-width": 1.5,
    },
  });
});
