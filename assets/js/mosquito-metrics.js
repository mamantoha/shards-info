import $ from "jquery";

let metricsChart = null;
let metricsChartCanvas = null;
let metricsHistoryDays = 7;
let metricsHistoryRequest = null;

export const formatMetricNumber = function (value) {
  return new Intl.NumberFormat().format(Number(value) || 0);
};

export const formatRuntime = function (milliseconds) {
  const value = Number(milliseconds) || 0;

  if (value >= 1000) {
    return `${(value / 1000).toFixed(2)} s`;
  }

  return `${value.toFixed(2)} ms`;
};

const formatMetrics = function () {
  $(".js-mosquito-metric-number").each(function () {
    $(this).text(formatMetricNumber(this.dataset.value));
  });

  $(".js-mosquito-runtime").each(function () {
    $(this).text(formatRuntime(this.dataset.milliseconds));
  });
};

export const refreshMosquitoSummary = function (metrics, queues) {
  if (!metrics) {
    return;
  }

  $(".js-mosquito-metric-processed").text(formatMetricNumber(metrics.processed));
  $(".js-mosquito-metric-succeeded").text(formatMetricNumber(metrics.succeeded));
  $(".js-mosquito-metric-failed").text(formatMetricNumber(metrics.failed));
  $(".js-mosquito-metric-preempted").text(formatMetricNumber(metrics.preempted));
  $(".js-mosquito-metric-aborted").text(formatMetricNumber(metrics.aborted));
  $(".js-mosquito-metric-average-runtime").text(formatRuntime(metrics.average_runtime_ms));

  const live = queues.reduce(
    function (totals, queue) {
      totals.waiting += queue.sizes.waiting;
      totals.scheduled += queue.sizes.scheduled;
      totals.pending += queue.sizes.pending;
      totals.dead += queue.sizes.dead;
      return totals;
    },
    { waiting: 0, scheduled: 0, pending: 0, dead: 0 },
  );

  $(".js-mosquito-live-waiting").text(formatMetricNumber(live.waiting));
  $(".js-mosquito-live-scheduled").text(formatMetricNumber(live.scheduled));
  $(".js-mosquito-live-pending").text(formatMetricNumber(live.pending));
  $(".js-mosquito-live-dead").text(formatMetricNumber(live.dead));
};

export const refreshMosquitoMetricsChart = function () {
  if (!metricsChart || !metricsChartCanvas) {
    return;
  }

  metricsHistoryRequest?.abort();
  metricsHistoryRequest = new AbortController();

  const request = metricsHistoryRequest;
  const url = new URL(metricsChartCanvas.dataset.url, window.location.origin);
  url.searchParams.set("days", metricsHistoryDays);

  fetch(url, {
    cache: "no-store",
    headers: {
      "X-Requested-With": "XMLHttpRequest",
    },
    signal: request.signal,
  })
    .then((response) => response.json())
    .then((data) => {
      metricsChart.data.labels = data.history.map((point) => point.day);
      metricsChart.data.datasets[0].data = data.history.map((point) => point.processed);
      metricsChart.data.datasets[1].data = data.history.map((point) => point.failed);
      metricsChart.update();
    })
    .catch((error) => {
      if (error.name !== "AbortError") {
        console.error("Error fetching Mosquito metrics history:", error);
      }
    })
    .finally(() => {
      if (metricsHistoryRequest === request) {
        metricsHistoryRequest = null;
      }
    });
};

const initializeChart = function () {
  metricsChartCanvas = document.querySelector(".js-mosquito-metrics-chart");

  if (!metricsChartCanvas) {
    return;
  }

  const styles = getComputedStyle(document.documentElement);
  const textColor = styles.getPropertyValue("--font-color").trim();
  const gridColor = styles.getPropertyValue("--border-color").trim();
  metricsChart = new window.Chart(metricsChartCanvas, {
    type: "line",
    data: {
      labels: [],
      datasets: [
        {
          label: "Processed",
          data: [],
          borderColor: "#008b8b",
          backgroundColor: "rgba(0, 139, 139, 0.15)",
          borderWidth: 2,
          pointRadius: 2,
          tension: 0.15,
        },
        {
          label: "Failed",
          data: [],
          borderColor: "#dc3545",
          backgroundColor: "rgba(220, 53, 69, 0.12)",
          borderWidth: 2,
          pointRadius: 2,
          tension: 0.15,
        },
      ],
    },
    options: {
      maintainAspectRatio: false,
      responsive: true,
      interaction: {
        intersect: false,
        mode: "index",
      },
      plugins: {
        legend: {
          labels: {
            color: textColor,
          },
        },
      },
      scales: {
        x: {
          grid: {
            color: gridColor,
          },
          ticks: {
            color: textColor,
            maxTicksLimit: 12,
          },
        },
        y: {
          beginAtZero: true,
          grid: {
            color: gridColor,
          },
          ticks: {
            color: textColor,
            precision: 0,
          },
        },
      },
    },
  });

  document.querySelectorAll(".js-mosquito-history-range").forEach(function (button) {
    button.addEventListener("click", function () {
      document.querySelectorAll(".js-mosquito-history-range").forEach(function (item) {
        item.classList.toggle("btn-secondary", item === button);
        item.classList.toggle("btn-outline-secondary", item !== button);
      });

      metricsHistoryDays = button.dataset.days;
      refreshMosquitoMetricsChart();
    });
  });

  refreshMosquitoMetricsChart();
};

export const initializeMosquitoMetricsDashboard = function () {
  formatMetrics();
  initializeChart();
};
