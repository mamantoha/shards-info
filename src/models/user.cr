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
    if provider == "gitlab"
      "https://gitlab.com/#{login}"
    else
      "https://github.com/#{login}"
    end
  end

  def provider_icon
    if provider == "gitlab"
      "fab fa-gitlab"
    else
      "fab fa-github"
    end
  end
end
