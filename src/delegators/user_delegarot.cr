class UserDelegator < Delegator(User)
  def provider_path : String
    path || login
  end

  def full_name : String
    name || login
  end

  def avatar(size : Int32? = nil)
    return "/images/avatar.png" unless avatar_url

    if provider == "gitlab" && avatar_url.to_s.starts_with?('/')
      "https://gitlab.com#{avatar_url}"
    else
      if size
        avatar_url_with_size(avatar_url.to_s, size)
      else
        avatar_url
      end
    end
  end

  def avatar_url_with_size(avatar_url : String, size : Int32 = 64) : String
    uri = URI.parse(avatar_url)
    params = uri.query_params
    params["s"] = size.to_s
    uri.query = params.to_s

    uri.to_s
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

  def website_url : String?
    website.try do |_website|
      return if _website.empty?

      _website.starts_with?(/http(s)?:/i) ? _website : "https://" + _website
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

  def kind_icon
    case kind
    when "user"
      "fas fa-user"
    when "group"
      "fas fa-user-friends"
    else
      ""
    end
  end
end
