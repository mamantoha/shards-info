require "json"

module Github
  class Repo
    JSON.mapping({
      name: {type: String},
    })
  end

  class Repos
    JSON.mapping({
      total_count: {type: Int32},
      items:       {type: Array(Repo)},
    })
  end
end
