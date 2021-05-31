class AdminDelegator < Delegator(Admin)
  def role_name
    Admin::ROLES[role]
  end

  def provider_url
    "https://gitlab.com/#{nickname}"
  end

  def provider_icon
    "fab fa-github"
  end
end
