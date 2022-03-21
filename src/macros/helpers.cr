macro assets_version
  {{ `git rev-parse --short HEAD || echo -n "unknown"`.chomp.stringify }}
end
