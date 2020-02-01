class UserDelegator < Delegator(User)
  def full_name : String
    name || login
  end

  def avatar
    return "/images/avatar.png" unless avatar_url

    if provider == "gitlab" && avatar_url.not_nil!.starts_with?('/')
      "https://gitlab.com#{avatar_url}"
    else
      avatar_url
    end
  end

  def provider_url
    case provider
    when "gitlab"
      "https://gitlab.com/#{login}"
    when "github"
      "https://github.com/#{login}"
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
