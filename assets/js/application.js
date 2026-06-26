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

  const themeSwitcherElement = document.getElementById("themeSwitcher");

  if (localStorage.theme === "dark") {
    themeSwitcherElement.setAttribute("data-checked", true);
    themeSwitcherElement.innerHTML = '<i class="fas fa-moon"></i>';
  } else {
    themeSwitcherElement.setAttribute("data-checked", false);
    themeSwitcherElement.innerHTML = '<i class="fas fa-sun"></i>';
  }

  themeSwitcherElement.addEventListener("click", function () {
    const isChecked = this.getAttribute("data-checked") === "true";
    this.setAttribute("data-checked", !isChecked);
    this.innerHTML = isChecked ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';

    if (!isChecked) {
      localStorage.theme = "dark";
      document.documentElement.classList.add("dark");
    } else {
      localStorage.theme = "light";
      document.documentElement.classList.remove("dark");
    }
  });

  // navigate to a tab when the history changes
  window.addEventListener("popstate", function (e) {
    const hash = window.location.hash;
    const activeTab = $('.nav a[href="' + hash + '"]');

    if (activeTab.length) {
      activeTab.tab("show");
    } else {
      $(".nav-tabs a:first").tab("show");
    }
  });

  $("form#search").on("submit", function (e) {
    e.preventDefault();
    const query = $(e.target).find("input[name='query']").val().replace(/\s/g, "+");
    window.location.href = "/search?query=" + encodeURIComponent(query);
  });

  $(".js-action").on("click", function (e) {
    e.preventDefault();
    const url = e.currentTarget.dataset.href;
    const method = e.currentTarget.dataset.method;

    $.ajax({
      url,
      method,
      data: {},
      success: function (resp) {
        window.location.href = resp.data.redirect_url;
      },
    });
  });

  $(document).on("submit", ".js-delete-dead-job", function (e) {
    e.preventDefault();

    const form = e.currentTarget;
    const button = form.querySelector("button[type='submit']");
    const row = form.closest(".js-mosquito-job-row");
    const queueName = row.dataset.queueName;

    button.disabled = true;

    $.ajax({
      url: form.action,
      method: form.method,
      data: $(form).serialize(),
      headers: {
        "X-Requested-With": "XMLHttpRequest",
      },
      success: function () {
        row.remove();

        const deadCount = $(`.js-mosquito-dead-count[data-queue-name="${queueName}"]`);
        const deadSectionCount = $(
          `.js-mosquito-dead-section-count[data-queue-name="${queueName}"]`,
        );
        const count = Math.max(parseInt(deadCount.text(), 10) - 1, 0);

        deadCount.text(count);
        deadSectionCount.text(count);
      },
      error: function () {
        button.disabled = false;
      },
    });
  });

  const livePollButton = function () {
    return document.querySelector(".js-live-poll");
  };

  const livePollStorageKey = function () {
    return `livePoll:${window.location.pathname}`;
  };

  const updateLivePollButton = function () {
    const button = livePollButton();
    if (!button) {
      return;
    }

    const enabled = localStorage.getItem(livePollStorageKey()) === "true";
    button.textContent = enabled ? "Stop Live Poll" : "Live Poll";
    button.classList.toggle("btn-secondary", enabled);
    button.classList.toggle("btn-outline-secondary", !enabled);
  };

  const mosquitoJsonUrl = function () {
    if (window.location.pathname === "/admin/mosquito") {
      return "/admin/mosquito.json";
    }

    return `${window.location.pathname}.json`;
  };

  const deleteDeadJobsForm = function (queueName) {
    return `
      <form action="/admin/mosquito/dead_jobs" method="post">
        <input type="hidden" name="queue[name]" value="${queueName}">
        <button class="btn btn-sm btn-danger" type="submit">Delete dead jobs</button>
      </form>
    `;
  };

  const pauseQueueForm = function (queue) {
    const action = queue.paused ? "resume" : "pause";
    const label = queue.paused ? "Resume" : "Pause";
    const buttonClass = queue.paused ? "btn-secondary" : "btn-warning";

    return `
      <form class="js-mosquito-queue-action" action="/admin/mosquito/queues/${queue.name}/${action}" method="post">
        <button class="btn btn-sm ${buttonClass}" type="submit">${label}</button>
      </form>
    `;
  };

  const updateQueueRow = function (row, queue) {
    row.find(".js-mosquito-waiting-count").text(queue.sizes.waiting);
    row.find(".js-mosquito-scheduled-count").text(queue.sizes.scheduled);
    row.find(".js-mosquito-pending-count").text(queue.sizes.pending);
    row.find(".js-mosquito-dead-count").text(queue.sizes.dead);
    row.find(".js-mosquito-pause").html(pauseQueueForm(queue));
    row
      .find(".js-mosquito-delete-dead")
      .html(queue.sizes.dead > 0 ? deleteDeadJobsForm(queue.name) : "");
  };

  const queueRow = function (queue) {
    return $(`
      <tr class="js-mosquito-queue-row" data-queue-name="${queue.name}">
        <td><a href="/admin/mosquito/queues/${queue.name}">${queue.name}</a></td>
        <td class="js-mosquito-waiting-count"></td>
        <td class="js-mosquito-scheduled-count"></td>
        <td class="js-mosquito-pending-count"></td>
        <td class="js-mosquito-dead-count" data-queue-name="${queue.name}"></td>
        <td class="js-mosquito-pause"></td>
        <td class="js-mosquito-delete-dead"></td>
      </tr>
    `);
  };

  const refreshMosquitoQueues = function (queues) {
    const body = $(".js-mosquito-queues");

    queues.forEach(function (queue) {
      let row = body.find(`.js-mosquito-queue-row[data-queue-name="${queue.name}"]`);

      if (!row.length) {
        row = queueRow(queue);
        body.append(row);
      }

      updateQueueRow(row, queue);
    });

    body.find(".js-mosquito-queue-row").each(function () {
      const row = $(this);
      const queueName = row.data("queueName");
      const exists = queues.some(function (queue) {
        return queue.name === queueName;
      });

      if (!exists) {
        row.remove();
      }
    });
  };

  const deadJobDeleteForm = function (queueName, jobId) {
    return `
      <form class="js-delete-dead-job" action="/admin/mosquito/dead_jobs/${jobId}" method="post">
        <input type="hidden" name="queue[name]" value="${queueName}">
        <button class="btn btn-sm btn-danger" type="submit">Delete</button>
      </form>
    `;
  };

  const jobRow = function (queueName, state, job) {
    const action = state === "dead" ? deadJobDeleteForm(queueName, job.id) : "";
    const cells = job.found
      ? `
        <td>${job.type}</td>
        <td>${job.retry_count}</td>
        <td>${job.enqueue_time}</td>
        <td>${job.started_at || ""}</td>
        <td>${job.finished_at || ""}</td>
      `
      : '<td colspan="5">Missing metadata</td>';

    return `
      <tr class="js-mosquito-job-row" data-queue-name="${queueName}" data-job-state="${state}" data-job-id="${job.id}">
        <td>${job.id}</td>
        ${cells}
        <td>${action}</td>
      </tr>
    `;
  };

  const refreshMosquitoJobs = function (queueName, state, jobs) {
    const body = $(`.js-mosquito-jobs[data-queue-name="${queueName}"][data-job-state="${state}"]`);

    if (!jobs.length) {
      body.html(
        '<tr class="js-mosquito-empty-row"><td class="text-muted" colspan="7">No jobs.</td></tr>',
      );
      return;
    }

    body.html(
      jobs
        .map(function (job) {
          return jobRow(queueName, state, job);
        })
        .join(""),
    );
  };

  const refreshMosquitoContent = function () {
    $.ajax({
      url: mosquitoJsonUrl(),
      method: "GET",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
      },
      success: function (data) {
        if (data.queues) {
          refreshMosquitoQueues(data.queues);
          return;
        }

        updateQueueRow($(".js-mosquito-queue-row"), data.queue);
        refreshMosquitoJobs(data.queue.name, "waiting", data.jobs.waiting);
        refreshMosquitoJobs(data.queue.name, "scheduled", data.jobs.scheduled);
        refreshMosquitoJobs(data.queue.name, "pending", data.jobs.pending);
        refreshMosquitoJobs(data.queue.name, "dead", data.jobs.dead);
      },
    });
  };

  let livePollTimer = null;

  const startLivePoll = function () {
    const button = livePollButton();
    if (!button || livePollTimer) {
      return;
    }

    const storageKey = `livePoll:${window.location.pathname}`;
    const interval = parseInt(button.dataset.interval, 10);
    localStorage.setItem(storageKey, "true");
    updateLivePollButton();
    livePollTimer = window.setInterval(refreshMosquitoContent, interval);
  };

  const stopLivePoll = function () {
    localStorage.setItem(livePollStorageKey(), "false");
    updateLivePollButton();
    window.clearInterval(livePollTimer);
    livePollTimer = null;
  };

  $(document).on("click", ".js-live-poll", function () {
    const enabled = localStorage.getItem(livePollStorageKey()) === "true";

    if (enabled) {
      stopLivePoll();
    } else {
      startLivePoll();
    }
  });

  updateLivePollButton();

  if (livePollButton() && localStorage.getItem(livePollStorageKey()) === "true") {
    startLivePoll();
  }

  $(document).on("submit", ".js-mosquito-queue-action", function (e) {
    e.preventDefault();

    const form = e.currentTarget;
    const button = form.querySelector("button[type='submit']");
    const row = form.closest(".js-mosquito-queue-row");

    button.disabled = true;

    $.ajax({
      url: form.action,
      method: form.method,
      headers: {
        "X-Requested-With": "XMLHttpRequest",
      },
      success: function (resp) {
        updateQueueRow($(row), resp.data.queue);
      },
      error: function () {
        button.disabled = false;
      },
    });
  });

  const sidebarModal = document.getElementById("sidebar-modal");
  const searchInput = sidebarModal.querySelector("input[name='query']");

  sidebarModal.addEventListener("show.bs.modal", () => {
    setTimeout(() => {
      searchInput.focus();
      searchInput.setSelectionRange(searchInput.value.length, searchInput.value.length);
    }, 500);
  });

  $(function () {
    const hash = window.location.hash;
    hash && $('.nav a[href="' + hash + '"]').tab("show");

    // add a hash to the URL when the user clicks on a tab
    $(".home_repositories__container .nav-tabs a").on("click", function (e) {
      history.pushState(null, null, $(this).attr("href"));
      const scrollmem = $("body").scrollTop();
      $("html,body").scrollTop(scrollmem);
    });

    $(".shard__readme a.anchor").on("click", function (e) {
      e.preventDefault();
      window.location.replace(this.hash);
    });

    // Back To Top Button
    if ($("#back-to-top").length) {
      const scrollTrigger = 100; // px
      const backToTop = function () {
        const scrollTop = $(window).scrollTop();
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

  const moveTo = new window.MoveTo();
  const trigger = $("#back-to-top");
  moveTo.registerTrigger(trigger[0]);

  const pagesCount = $("#pagination").data("pagesCount");
  const currentPage = $("#pagination").data("currentPage");
  const $pagination = $("#pagination");

  $pagination.twbsPagination({
    totalPages: pagesCount,
    startPage: currentPage,
    visiblePages: 7,
    href: true,
    pageVariable: "page",
    prev: "&larr;",
    next: "&rarr;",
    first: "&larrb;",
    last: "&rarrb;",
    onPageClick: function (event, page) {},
  });

  // initialize all tooltips on a page
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new window.bootstrap.Tooltip(tooltipTriggerEl);
  });

  // initialize all popovers on a page
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new window.bootstrap.Popover(popoverTriggerEl);
  });
});

// Executed upon page load
document.addEventListener("DOMContentLoaded", function () {
  scrollToHash();
});

// This function enables automatic page scrolling to a specific anchor in the "readme" section upon page load.
function scrollToHash() {
  const hash = window.location.hash;

  if (hash) {
    const element = document.querySelector("#readme " + hash);

    if (element) {
      // Scroll the page to bring the element into view.
      // In browsers that support it, the scroll will be smooth.
      element.scrollIntoView({ behavior: "smooth" });
    }
  }
}
