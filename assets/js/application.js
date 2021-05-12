document.addEventListener("turbolinks:load", function () {
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

  hljs.initHighlighting.called = false;
  hljs.highlightAll();

  $(function () {
    var hash = window.location.hash;
    hash && $('.nav a[href="' + hash + '"]').tab("show");

    $(".nav-tabs a").click(function (e) {
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
