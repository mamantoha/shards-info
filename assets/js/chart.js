class CountBarChart {
  constructor (options) {
    this.element = document.querySelector(options.element)

    if (!this.element) {
      return
    }

    this.options = options
    this.label = options.label
    this.chart = null
    this.data = null

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
            }
          }
        })
        this.chart = new Chart(canvas, {
          type: 'bar',
          data: chartData,
          options: chartOptions
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
        label: this.label,
        data: values,
        backgroundColor: 'rgba(54, 162, 235, 0.5)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 1
      }]
    }
    return chartData
  }
}

class RepositoryCountBarChart {
  constructor (options) {
    this.element = document.querySelector(options.element)

    if (!this.element) {
      return
    }

    this.options = options
    this.label = options.label
    this.chart = null
    this.data = null

    const startDateYearsAgo = options.startDateYearsAgo || 2

    // create div for inputs
    this.inputContainer = document.createElement('div')
    this.inputContainer.style.textAlign = 'right'
    this.element.appendChild(this.inputContainer)

    const startDate = new Date()
    startDate.setFullYear(startDate.getFullYear() - startDateYearsAgo)
    startDate.setDate(1)
    this.startDateInput = document.createElement('input')
    this.startDateInput.type = 'month'
    this.startDateInput.value = startDate.toISOString().slice(0, 7)
    this.inputContainer.appendChild(this.startDateInput)

    this.endDateInput = document.createElement('input')
    this.endDateInput.type = 'month'
    this.endDateInput.value = new Date().toISOString().slice(0, 7)
    this.inputContainer.appendChild(this.endDateInput)

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

class RepositoryCountLineChart {
  constructor (options) {
    this.element = document.querySelector(options.element)

    if (!this.element) {
      return
    }

    this.options = options
    this.label = options.label
    this.chart = null
    this.data = null

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
        canvas.height = '300'
        this.element.appendChild(canvas)

        const chartOptions = Object.assign({}, this.options.chartOptions, {
          plugins: {
            legend: {
              display: false
            },
            title: {
              display: true,
              text: `${this.label}`
            }
          }
        })
        this.chart = new Chart(canvas, {
          type: 'line',
          data: chartData,
          options: chartOptions
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
        label: this.label,
        data: values,
        backgroundColor: 'rgba(54, 162, 235, 0.5)',
        borderColor: 'rgba(54, 162, 235, 1)',
        borderWidth: 1
      }]
    }
    return chartData
  }
}

document.addEventListener('DOMContentLoaded', function () {
  const chartCreatedAt = new RepositoryCountBarChart({
    apiUrl: '/stats/created_at',
    element: '#chartCreatedAt',
    label: 'New repositories',
    chartOptions: {
      scales: {
      }
    }
  })

  const chartLastActivityAt = new RepositoryCountBarChart({
    apiUrl: '/stats/last_activity_at',
    element: '#chartLastActivityAt',
    label: 'Last activity repositories',
    startDateYearsAgo: 5,
    chartOptions: {
      scales: {
      }
    }
  })

  const chartRepositoriesCount = new RepositoryCountLineChart({
    apiUrl: '/stats/repositories_growth',
    element: '#chartRepositoriesGrowth',
    label: 'Growth of repositories',
    startDateYearsAgo: 5,
    chartOptions: {
      scales: {
        x: {
          display: true
        },
        y: {
          display: true
        }
      },
      fill: true,
      maintainAspectRatio: false,
      responsive: true
    }
  })

  const chartDirectDependencies = new CountBarChart({
    apiUrl: '/stats/direct_dependencies',
    element: '#chartDirectDependencies',
    label: 'Number of direct dependencies',
    chartOptions: {
      scales: {
        x: {
          display: true
        },
        y: {
          display: true,
          type: 'logarithmic',
          ticks: {
            callback: function (value, index, ticks) {
              if (value === 10000) return '10k+'
              if (value === 1000) return '1k+'
              if (value === 100) return '100+'
              if (value === 10) return '10+'
              if (value === 1) return '1+'
              return null
            }
          }
        }
      },
      fill: true,
      maintainAspectRatio: false,
      responsive: true
    }
  })

  const chartReverseDependencies = new CountBarChart({
    apiUrl: '/stats/reverse_dependencies',
    element: '#chartReverseDependencies',
    label: 'Number of transitive reverse dependencies',
    chartOptions: {
      scales: {
        x: {
          display: true
        },
        y: {
          display: true,
          type: 'logarithmic',
          ticks: {
            callback: function (value, index, ticks) {
              if (value === 10000) return '10k+'
              if (value === 1000) return '1k+'
              if (value === 100) return '100+'
              if (value === 10) return '10+'
              if (value === 1) return '1+'
              return null
            }
          }
        }
      },
      fill: true,
      maintainAspectRatio: false,
      responsive: true
    }
  })
})
