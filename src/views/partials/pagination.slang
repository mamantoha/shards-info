- pages_count = ((repos.total_count + 10 -1) / 10).to_i

nav aria-label="Search result pages"
  ul class="pagination justify-content-center flex-wrap"
    li class="page-item #{page == 1 ? "disabled" : ""}"
      a class="page-link" href="/repos?query=#{query}&page=#{page - 1}" Previous
    - pages_count.times do |p|
      - p += 1
      li class="page-item #{page == p ? "disabled" : ""}"
        a class="page-link" href="/repos?query=#{query}&page=#{p}" = p
    li class="page-item #{page == pages_count ? "disabled" : "no"}"
      a class="page-link" href="/repos?query=#{query}&page=#{page + 1}" Next
