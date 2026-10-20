import { geoNaturalEarth1, geoPath, interpolateRgb, select, zoom, zoomIdentity } from "d3";

export async function initializeVisitorMap() {
  const container = document.getElementById("visitor-map");
  if (!container || container.dataset.initialized) return;
  container.dataset.initialized = "true";

  const status = document.querySelector(".js-visitor-map-status");
  const maximumLabel = document.querySelector(".js-visitor-map-maximum");
  const buttons = document.querySelectorAll(".js-visitor-map-ranges button");
  const format = new Intl.NumberFormat();
  let request;
  let counts = {};

  try {
    const response = await fetch("/maps/countries.geojson");
    if (!response.ok) throw new Error("Could not load country boundaries");
    const countries = await response.json();

    const width = 960;
    const height = 500;
    const projection = geoNaturalEarth1().fitExtent(
      [
        [12, 12],
        [width - 12, height - 12],
      ],
      { type: "Sphere" },
    );
    const svg = select(container)
      .append("svg")
      .attr("viewBox", `0 0 ${width} ${height}`)
      .attr("aria-label", "Visitor counts by country");
    const layer = svg.append("g");
    const zoomIn = document.querySelector(".js-visitor-map-zoom-in");
    const zoomOut = document.querySelector(".js-visitor-map-zoom-out");
    const reset = document.querySelector(".js-visitor-map-reset");
    const mapZoom = zoom()
      .extent([
        [0, 0],
        [width, height],
      ])
      .translateExtent([
        [0, 0],
        [width, height],
      ])
      .scaleExtent([1, 8])
      .filter((event) => event.type !== "wheel" && event.type !== "dblclick" && !event.button)
      .on("zoom", ({ transform }) => {
        layer.attr("transform", transform);
        svg.classed("is-zoomed", transform.k > 1);
        zoomIn.disabled = transform.k >= 8;
        zoomOut.disabled = transform.k <= 1;
        reset.disabled = transform.k <= 1;
      });
    svg.call(mapZoom);
    zoomIn.disabled = false;
    zoomIn.addEventListener("click", () => svg.call(mapZoom.scaleBy, 2));
    zoomOut.addEventListener("click", () => svg.call(mapZoom.scaleBy, 0.5));
    reset.addEventListener("click", () => svg.call(mapZoom.transform, zoomIdentity));

    const paths = layer
      .selectAll("path")
      .data(countries.features)
      .join("path")
      .attr("class", "visitor-map-country")
      .attr("d", geoPath(projection))
      .attr("tabindex", 0);
    paths.append("title");
    const color = interpolateRgb("#b6d9f5", "#08519c");

    const update = async (days) => {
      request?.abort();
      const current = new AbortController();
      request = current;
      status.textContent = "Loading visitor counts…";
      buttons.forEach((button) => {
        const active = Number(button.dataset.days) === days;
        button.classList.toggle("btn-secondary", active);
        button.classList.toggle("btn-outline-secondary", !active);
        button.setAttribute("aria-pressed", String(active));
      });
      try {
        const response = await fetch(`${container.dataset.url}?days=${days}`, {
          signal: current.signal,
          cache: "no-store",
        });
        if (!response.ok) throw new Error("Could not load visitor counts");
        const data = await response.json();
        if (request !== current) return;
        counts = data.countries;
        const codes = new Set(
          countries.features.map((feature) => feature.properties.code).filter(Boolean),
        );
        let unmapped = 0;
        let total = 0;
        Object.entries(counts).forEach(([code, count]) => {
          total += count;
          if (!codes.has(code)) unmapped += count;
        });
        const maximum = Math.max(
          0,
          ...countries.features.map(
            (feature) => (feature.properties.code && counts[feature.properties.code]) || 0,
          ),
        );
        paths
          .style("fill", (feature) => {
            const count = (feature.properties.code && counts[feature.properties.code]) || 0;
            return count ? color(count / Math.max(1, maximum)) : null;
          })
          .attr("aria-label", (feature) => {
            const count = (feature.properties.code && counts[feature.properties.code]) || 0;
            return `${feature.properties.name}: ${format.format(count)} visitors`;
          });
        paths.select("title").text(function () {
          return this.parentNode.getAttribute("aria-label");
        });
        maximumLabel.textContent = `${format.format(maximum)} visitors`;
        status.textContent = `${format.format(total)} visitors in the last ${days} days. ${format.format(unmapped)} with unknown or unmapped country.${total === 0 ? " No visits recorded in this period." : ""}`;
      } catch (error) {
        if (error.name !== "AbortError") {
          status.textContent = "Could not load visitor counts. Select a date range to retry.";
        }
      }
    };

    buttons.forEach((button) =>
      button.addEventListener("click", () => update(Number(button.dataset.days))),
    );
    update(90);
  } catch (error) {
    status.textContent = "Could not load the visitor map. Please reload to try again.";
  }
}
