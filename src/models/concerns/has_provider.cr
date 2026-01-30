module HasProvider
  extend self

  def provider_icon : String
    case provider
    when "github"
      "fab fa-github"
    when "gitlab"
      "fab fa-gitlab"
    when "codeberg"
      "fa-brands fa-square-git"
    else
      "fas fa-code"
    end
  end
end
