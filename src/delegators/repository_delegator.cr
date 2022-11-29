class RepositoryDelegator < Delegator(Repository)
  def provider_path : String
    "#{user.path || user.login}/#{name}"
  end

  def full_name : String
    "#{user.login}/#{name}"
  end

  def show_path : String
    "/#{provider}/#{user.login}/#{name}"
  end

  def readme_path : String
    "/#{provider}/#{user.login}/#{name}/readme"
  end

  def latest_release : String
    releases.published.order_by(published_at: :desc).first.try(&.tag_name) || ""
  end

  def last_activity_ago
    "#{HumanizeTime.distance_of_time_in_words(last_activity_at, Time.local)} ago"
  end

  def description_with_emoji : String?
    description.try do |_description|
      Emoji.emojize(
        HTML.escape(_description)
      )
    end
  end

  def description_html : String?
    description.try do |_description|
      Emoji.emojize(
        Autolink.auto_link(
          HTML.escape(_description)
        )
      )
    end
  end

  def provider_url
    case provider
    when "gitlab"
      "https://gitlab.com/#{provider_path}"
    when "github"
      "https://github.com/#{provider_path}"
    else
      ""
    end
  end

  def provider_icon
    case provider
    when "gitlab"
      "fab fa-gitlab"
    when "github"
      "fab fa-github"
    else
      ""
    end
  end

  def fork_icon
    fork ? "fas fa-code-fork" : "fas fa-code"
  end
end
