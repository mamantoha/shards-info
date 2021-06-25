document.addEventListener("turbolinks:load", function () {
  if (!("theme" in localStorage)) {
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      document.documentElement.classList.add("dark");
      document.getElementById("switchTheme").checked = true;
    } else {
      document.documentElement.classList.remove("dark");
      document.getElementById("switchTheme").checked = false;
    }
  } else {
    if (localStorage.theme === "dark") {
      document.documentElement.classList.add("dark");
      document.getElementById("switchTheme").checked = true;
    } else {
      document.documentElement.classList.remove("dark");
      document.getElementById("switchTheme").checked = false;
    }
  }

  $("#switchTheme").on("change", function (e) {
    if (e.currentTarget.checked) {
      document.documentElement.classList.add("dark");
      localStorage.theme = "dark";
    } else {
      document.documentElement.classList.remove("dark");
      localStorage.theme = "light";
    }
  });

  if (typeof ga === "function") {
    ga("set", "location", event.data.url);
    ga("send", "pageview");
  }

  $("form#search").on("submit", function (e) {
    e.preventDefault();
    query = $(e.target).find("input[name='query']").val();
    query = query.replace(/\s/g, "+");
    Turbolinks.visit("/search?query=" + query);
  });

  $("#syncRepository").on("click", function (e) {
    e.preventDefault();
    url = e.currentTarget.dataset["href"];

    $.ajax({
      url: url,
      method: "POST",
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url;
      },
    });
  });

  $("#showRepository").on("click", function (e) {
    e.preventDefault();
    url = e.currentTarget.dataset["href"];

    $.ajax({
      url: url,
      method: "POST",
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url;
      },
    });
  });

  $("#hideRepository").on("click", function (e) {
    e.preventDefault();
    url = e.currentTarget.dataset["href"];

    $.ajax({
      url: url,
      method: "POST",
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url;
      },
    });
  });

  $("#destroyRepository").on("click", function (e) {
    e.preventDefault();
    url = e.currentTarget.dataset["href"];

    $.ajax({
      url: url,
      method: "DELETE",
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url;
      },
    });
  });

  hljs.initHighlighting.called = false;
  hljs.highlightAll();

  $(function () {
    var hash = window.location.hash;
    hash && $('.nav a[href="' + hash + '"]').tab("show");

    $(".nav-tabs a").on("click", function (e) {
      $(this).tab("show");
      var scrollmem = $("body").scrollTop();
      window.location.replace(this.hash);
      history.replaceState({ turbolinks: {} }, "");
      $("html,body").scrollTop(scrollmem);
    });

    // Back To Top Button
    if ($("#back-to-top").length) {
      var scrollTrigger = 100, // px
        backToTop = function () {
          var scrollTop = $(window).scrollTop();
          if (scrollTop > scrollTrigger) {
            $("#back-to-top").addClass("show");
          } else {
            $("#back-to-top").removeClass("show");
          }
        };
      backToTop();
      $(window).on("scroll", function () {
        backToTop();
      });
    }

    Turbolinks.setProgressBarDelay(200);
  });

  var moveTo = new MoveTo();
  var trigger = $("#back-to-top");
  moveTo.registerTrigger(trigger[0]);

  pagesCount = $("#pagination").data("pagesCount");
  currentPage = $("#pagination").data("currentPage");
  var $pagination = $("#pagination");

  $pagination.twbsPagination({
    totalPages: pagesCount,
    startPage: currentPage,
    visiblePages: 7,
    href: true,
    pageVariable: "page",
    prev: "&laquo;",
    next: "&raquo;",
    first: "",
    last: "",
    onPageClick: function (event, page) {},
  });
});
