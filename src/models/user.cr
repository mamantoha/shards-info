class User
  include Clear::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column login : String
  column name : String?
  column synced_at : Time
  column kind : String
  column avatar_url : String?

  has_many repositories : Repository

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
