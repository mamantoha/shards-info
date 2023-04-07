class RepositoryCountChart {
  constructor (options) {
    this.element = document.querySelector(options.element)

    if (!this.element) {
      return
    }

    this.options = options
    this.label = options.label
    this.chart = null
    this.data = null

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

    this.startDateInput.addEventListener('change', this.updateChart.bind(this))
    this.endDateInput.addEventListener('change', this.updateChart.bind(this))

    this.fetchDataAndCreateChart()
  }

  fetchDataAndCreateChart () {
    fetch(this.options.apiUrl)
      .then(response => response.json())
      .then(data => {
        this.data = data
        const chartData = this.processData(data)
        // create chart
        const canvas = document.createElement('canvas')
        this.element.appendChild(canvas)
        const chartOptions = Object.assign({}, this.options.chartOptions, {
          plugins: {
            legend: {
              display: false
            },
            title: {
              display: true,
              text: `${this.label}`
            },
            subtitle: {
              display: true,
              text: `${this.startDateInput.value} - ${this.endDateInput.value}`
            }
          }
        })
        this.chart = new Chart(canvas, {
          type: 'bar',
          data: chartData,
          options: chartOptions
        })

        this.updateChart()
      })
      .catch(error => {
        console.error('Error fetching data:', error)
      })
  }

  updateChart () {
    const startDate = new Date(this.startDateInput.value)
    const endDate = new Date(this.endDateInput.value)

    const filteredData = this.filterDataByDateRange(this.data, startDate, endDate)
    const chartData = this.processData(filteredData)
    this.chart.data = chartData

    // update chart subtitle
    this.chart.options.plugins.subtitle.text = `${this.startDateInput.value} - ${this.endDateInput.value}`

    this.chart.update()
  }

  processData (data) {
    const labels = Object.keys(data)
    const values = Object.values(data)
    const chartData = {
      labels,
      datasets: [{
        label: this.label,
        data: values,
        backgroundColor: 'rgba(54, 162, 235, 0.5)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 1
      }]
    }
    return chartData
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
    label: 'New repositories',
    chartOptions: {
      scales: {
      }
    }
  })
})
