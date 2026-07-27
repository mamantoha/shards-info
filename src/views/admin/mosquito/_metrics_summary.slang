.mosquito-metrics-summary.mb-4
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-metric-processed data-value=metrics_summary.processed = metrics_summary.processed
    span Processed
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-metric-succeeded data-value=metrics_summary.succeeded = metrics_summary.succeeded
    span Succeeded
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-metric-failed data-value=metrics_summary.failed = metrics_summary.failed
    span Failed
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-metric-preempted data-value=metrics_summary.preempted = metrics_summary.preempted
    span Preempted
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-metric-aborted data-value=metrics_summary.aborted = metrics_summary.aborted
    span Aborted
  .mosquito-metric
    strong.js-mosquito-runtime.js-mosquito-metric-average-runtime data-milliseconds=metrics_summary.average_runtime_ms = "#{metrics_summary.average_runtime_ms.round(2)} ms"
    span Average runtime
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-live-pending data-value=live_counts[:pending] = live_counts[:pending]
    span Busy
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-live-waiting data-value=live_counts[:waiting] = live_counts[:waiting]
    span Waiting
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-live-scheduled data-value=live_counts[:scheduled] = live_counts[:scheduled]
    span Scheduled
  .mosquito-metric
    strong.js-mosquito-metric-number.js-mosquito-live-dead data-value=live_counts[:dead] = live_counts[:dead]
    span Dead

.mosquito-metrics-history.mb-4
  .d-flex.align-items-center.justify-content-between.flex-wrap.gap-2.mb-2
    h3.h5.mb-0 History
    .btn-group.btn-group-sm role="group" aria-label="Metrics history range"
      button.btn.btn-secondary.js-mosquito-history-range type="button" data-days="7" 1 week
      button.btn.btn-outline-secondary.js-mosquito-history-range type="button" data-days="30" 1 month
      button.btn.btn-outline-secondary.js-mosquito-history-range type="button" data-days="90" 3 months
      button.btn.btn-outline-secondary.js-mosquito-history-range type="button" data-days="180" 6 months
  .mosquito-metrics-chart
    canvas.js-mosquito-metrics-chart data-url=metrics_history_url
