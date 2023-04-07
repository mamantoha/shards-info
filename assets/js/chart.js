class RepositoryCountChart {
  constructor (options) {
    this.options = options
    this.element = document.querySelector(options.element)
    this.chart = null

    // set startDateInput value to current month minus 2 years
    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - 2)
    startDate.setDate(1)
    this.startDateInput = document.createElement('input')
    this.startDateInput.type = 'month'
    this.startDateInput.value = startDate.toISOString().slice(0, 7)
    this.element.appendChild(this.startDateInput)

    this.endDateInput = document.createElement('input')
    this.endDateInput.type = 'month'
    this.endDateInput.value = new Date().toISOString().slice(0, 7)
    this.element.appendChild(this.endDateInput)

    this.fetchDataAndCreateChart()
    this.updateChart()

    this.startDateInput.addEventListener('change', this.updateChart.bind(this))
    this.endDateInput.addEventListener('change', this.updateChart.bind(this))
  }

  fetchDataAndCreateChart () {
    fetch(this.options.apiUrl)
      .then(response => response.json())
      .then(data => {
        const chartData = this.processData(data)
        const canvas = document.createElement('canvas')
        this.element.appendChild(canvas)
        this.chart = new Chart(canvas, {
          type: 'bar',
          data: chartData,
          options: this.options.chartOptions
        })
      })
      .catch(error => {
        console.error('Error fetching data:', error)
      })
  }

  processData (data) {
    const labels = Object.keys(data)
    const values = Object.values(data)
    const chartData = {
      labels,
      datasets: [{
        label: 'Repository Count',
        data: values,
        backgroundColor: 'rgba(54, 162, 235, 0.5)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 1
      }]
    }
    return chartData
  }

  updateChart () {
    const startDate = new Date(this.startDateInput.value)
    const endDate = new Date(this.endDateInput.value)

    fetch(this.options.apiUrl)
      .then(response => response.json())
      .then(data => {
        const filteredData = this.filterDataByDateRange(data, startDate, endDate)
        const chartData = this.processData(filteredData)
        this.chart.data = chartData
        this.chart.update()
      })
      .catch(error => {
        console.error('Error fetching data:', error)
      })
  }

  filterDataByDateRange (data, startDate, endDate) {
    return Object.keys(data)
      .filter(date => {
        const d = new Date(date)
        return d >= startDate && d <= endDate
      })
      .reduce((obj, key) => {
        obj[key] = data[key]
        return obj
      }, {})
  }
}

document.addEventListener('DOMContentLoaded', function () {
  const chart = new RepositoryCountChart({
    apiUrl: '/stats/created_at',
    element: '#chart-container',
    chartOptions: {
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero: true
          }
        }]
      }
    }
  })
})
