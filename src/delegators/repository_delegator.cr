class RepositoryDelegator < Delegator(Repository)
  def full_name : String
    "#{user.login}/#{name}"
  end

  def latest_release : String
    releases.published.order_by(published_at: :desc).first.try(&.tag_name) || ""
  end

  def description_with_emoji : String?
    description.try do |_description|
      Emoji.emojize(_description)
    end
  end

  def provider_url
    case provider
    when "gitlab"
      "https://gitlab.com/#{user.login}/#{name}"
    when "github"
      "https://github.com/#{user.login}/#{name}"
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
end
