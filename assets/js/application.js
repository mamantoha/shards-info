$(function () {
  if (!('theme' in localStorage)) {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      localStorage.theme = 'dark'
      document.documentElement.classList.add('dark')
    } else {
      localStorage.theme = 'light'
      document.documentElement.classList.remove('dark')
    }
  }

  if (localStorage.theme === 'dark') {
    document.getElementById('switchTheme').checked = true
  } else {
    document.getElementById('switchTheme').checked = false
  }

  $('#switchTheme').on('change', function (e) {
    if (e.currentTarget.checked) {
      localStorage.theme = 'dark'
      document.documentElement.classList.add('dark')
    } else {
      localStorage.theme = 'light'
      document.documentElement.classList.remove('dark')
    }
  })

  // navigate to a tab when the history changes
  window.addEventListener('popstate', function (e) {
    const hash = window.location.hash
    const activeTab = $('.nav a[href="' + hash + '"]')

    if (activeTab.length) {
      activeTab.tab('show')
    } else {
      $('.nav-tabs a:first').tab('show')
    }
  })

  $('form#search').on('submit', function (e) {
    e.preventDefault()
    const query = $(e.target).find("input[name='query']").val().replace(/\s/g, '+')
    window.location.href = '/search?query=' + encodeURIComponent(query)
  })

  $('.js-action').on('click', function (e) {
    e.preventDefault()
    const url = e.currentTarget.dataset.href
    const method = e.currentTarget.dataset.method

    $.ajax({
      url,
      method,
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url
      }
    })
  })

  $(function () {
    const hash = window.location.hash
    hash && $('.nav a[href="' + hash + '"]').tab('show')

    // add a hash to the URL when the user clicks on a tab
    $('.home_repositories__container .nav-tabs a').on('click', function (e) {
      history.pushState(null, null, $(this).attr('href'))
      const scrollmem = $('body').scrollTop()
      $('html,body').scrollTop(scrollmem)
    })

    $('.shard__readme a.anchor').on('click', function (e) {
      e.preventDefault()
      window.location.replace(this.hash)
    })

    // Back To Top Button
    if ($('#back-to-top').length) {
      const scrollTrigger = 100 // px
      const backToTop = function () {
        const scrollTop = $(window).scrollTop()
        if (scrollTop > scrollTrigger) {
          $('#back-to-top').addClass('show')
        } else {
          $('#back-to-top').removeClass('show')
        }
      }
      backToTop()
      $(window).on('scroll', function () {
        backToTop()
      })
    }

    $('.shard__readme li:has(input)').addClass('checklist-item')
  })

  const moveTo = new window.MoveTo()
  const trigger = $('#back-to-top')
  moveTo.registerTrigger(trigger[0])

  const pagesCount = $('#pagination').data('pagesCount')
  const currentPage = $('#pagination').data('currentPage')
  const $pagination = $('#pagination')

  $pagination.twbsPagination({
    totalPages: pagesCount,
    startPage: currentPage,
    visiblePages: 7,
    href: true,
    pageVariable: 'page',
    prev: '&laquo;',
    next: '&raquo;',
    first: '',
    last: '',
    onPageClick: function (event, page) {}
  })

  // initialize all tooltips on a page
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new window.bootstrap.Tooltip(tooltipTriggerEl)
  })

  // initialize all popovers on a page
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new window.bootstrap.Popover(popoverTriggerEl)
  })
})
