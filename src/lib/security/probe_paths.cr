module Security::ProbePaths
  extend self

  # Reviewed subset of sensitive-file probes, plus CMS paths unused by this app.
  # Sources (reference lists, not imported automatically):
  # https://github.com/coreruleset/coreruleset/blob/v4.19.0/rules/restricted-files.data
  # https://github.com/crowdsecurity/hub/blob/master/scenarios/crowdsecurity/http-sensitive-files.yaml
  # Match only at the URL root: repository routes can legitimately contain these names.
  EXACT_PATHS = {
    "/wp-login.php",
    "/xmlrpc.php",
    "/.env",
    "/.env.local",
    "/.env.production",
    "/.env.development",
    "/.env.backup",
    "/.env.bak",
    "/.htaccess",
    "/.htpasswd",
    "/.gitconfig",
    "/.npmrc",
    "/.my.cnf",
    "/phpinfo.php",
  }

  DIRECTORY_PATHS = {
    "/wp-admin",
    "/wp-content",
    "/wp-includes",
    "/phpmyadmin",
    "/.git",
    "/.svn",
    "/.hg",
    "/.ssh",
    "/.aws",
    "/.kube",
    "/vendor/phpunit",
  }

  def suspicious?(path : String) : Bool
    path = path.downcase

    EXACT_PATHS.includes?(path) || DIRECTORY_PATHS.any? do |directory|
      path == directory || path.starts_with?("#{directory}/")
    end
  end
end
