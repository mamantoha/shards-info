$(function () {
  if (!("theme" in localStorage)) {
    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      localStorage.theme = "dark";
      document.documentElement.classList.add("dark");
    } else {
      localStorage.theme = "light";
      document.documentElement.classList.remove("dark");
    }
  }

  if (localStorage.theme === "dark") {
    document.getElementById("switchTheme").checked = true;
  } else {
    document.getElementById("switchTheme").checked = false;
  }

  $("#switchTheme").on("change", function (e) {
    if (e.currentTarget.checked) {
      localStorage.theme = "dark";
      document.documentElement.classList.add("dark");
    } else {
      localStorage.theme = "light";
      document.documentElement.classList.remove("dark");
    }
  });

  if (typeof ga === "function") {
    ga("set", "location", event.data.url);
    ga("send", "pageview");
  }

  window.addEventListener("popstate", function (e) {
    var hash = window.location.hash;
    var activeTab = $('.nav a[href="' + hash + '"]');

    console.log(hash);

    if (activeTab.length) {
      $(document.querySelector("#trending-tab")).tab("show");
      activeTab.tab("show");
    } else {
      $(".nav-tabs a:first").tab("show");
    }
  });

  $("form#search").on("submit", function (e) {
    e.preventDefault();
    query = $(e.target).find("input[name='query']").val();
    query = query.replace(/\s/g, "+");
    window.location.href = "/search?query=" + query;
  });

  $(".js-action").on("click", function (e) {
    e.preventDefault();
    url = e.currentTarget.dataset["href"];
    method = e.currentTarget.dataset["method"];

    $.ajax({
      url: url,
      method: method,
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url;
      },
    });
  });

  $(function () {
    var hash = window.location.hash;
    hash && $('.nav a[href="' + hash + '"]').tab("show");

    $(".home_repositories__container .nav-tabs a").on("click", function (e) {
      history.pushState(null, null, $(this).attr("href"));
      var scrollmem = $("body").scrollTop();
      $("html,body").scrollTop(scrollmem);
    });

    $(".shard__readme a.anchor").on("click", function (e) {
      e.preventDefault();
      window.location.replace(this.hash);
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

    $(".shard__readme li:has(input)").addClass("checklist-item");
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
