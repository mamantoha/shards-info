# Deployment

* <https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04>
* <https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-with-http-2-support-on-ubuntu-18-04>
* <https://www.digitalocean.com/community/tutorials/how-to-manage-logfiles-with-logrotate-on-ubuntu-16-04>

## Localhost

```console
pg_dump "postgres://postgres@localhost/shards_info_development" -Fc > dumps/shards_info_development-$(date +%y-%m-%d_%H:%m:%S).sql

scp dumps/shards_info_development-20-02-02_14:02:49.sql sammy@shards.info:/home/sammy
```

## Production

```console
sudo apt install nginx postgresql postgresql-contrib redis-server libpq-dev
```

```console
psql -c 'CREATE DATABASE shards_info_production;' -U postgres
psql -c 'CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;' -U postgres

pg_restore -d shards_info_production shards_info_development.sql
```

```console
psql -c 'DROP DATABASE shards_info_development;' -U postgres
psql -c 'CREATE DATABASE shards_info_development;' -U postgres
```

### Build project

```console
shards build
```

Build assests if needed:

```console
npm run build
````

Migrate database if needed:

```console
./bin/db migrate
```

Restart application:

```console
sudo systemctl restart shards.info_worker.service
sudo systemctl restart shards.info_web.service
```

### nginx

`/etc/nginx/sites-available/default`

```text
server {
  listen       80  default_server;
  server_name  _; # some invalid name that won't match anything
  return       444;
}

server {
  listen       80;
  server_name  shards.info;
  return 301 https://$host$request_uri;
}

server {
  listen 443 http2 ssl;
  server_name  shards.info;

  server_tokens off;

  # https://github.com/twitter/secure_headers
  #
  add_header Content-Security-Policy "default-src 'self'; media-src 'self' https: data:; font-src 'self' https: data:; img-src 'self' https: data:; object-src 'none'; script-src 'unsafe-inline' https:; style-src 'self' https: 'unsafe-inline'";
  add_header Strict-Transport-Security "max-age=631138519";
  add_header X-Content-Type-Options "nosniff";
  add_header X-Download-Options "noopen";
  add_header X-Frame-Options "sameorigin";
  add_header X-Permitted-Cross-Domain-Policies "none";
  add_header X-Xss-Protection "1; mode=block";

  ssl on;
  ssl_certificate /etc/letsencrypt/live/shards.info/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/shards.info/privkey.pem;

  include /etc/letsencrypt/options-ssl-nginx.conf;

  location / {
    proxy_pass          http://localhost:3000;
    proxy_set_header    Host             $host;
    proxy_set_header    X-Real-IP        $remote_addr;
    proxy_set_header    X-Forwarded-For  $proxy_add_x_forwarded_for;
    proxy_set_header    X-Client-Verify  SUCCESS;
    proxy_set_header    X-Client-DN      $ssl_client_s_dn;
    proxy_set_header    X-SSL-Subject    $ssl_client_s_dn;
    proxy_set_header    X-SSL-Issuer     $ssl_client_i_dn;
    proxy_read_timeout 1800;
    proxy_connect_timeout 1800;
  }
}
```

### systemd

#### web service

`/etc/systemd/system/shards.info_web.service`

```text
[Unit]
Description=shards.info web service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
WatchdogSec=8640
User=sammy
WorkingDirectory=/home/sammy/projects/shards-info
ExecStart=/home/sammy/projects/shards-info/bin/web &>/dev/null &
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
```

```console
sudo systemctl enable shards.info_web
sudo systemctl start shards.info_web
```

#### worker service

`/etc/systemd/system/shards.info_worker.service`

```text
[Unit]
Description=shards.info worker service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=sammy
WorkingDirectory=/home/sammy/projects/shards-info
ExecStart=/home/sammy/projects/shards-info/bin/worker &>/dev/null &
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
```

```console
sudo systemctl daemon-reload
```

```console
sudo systemctl enable shards.info_worker
sudo systemctl start shards.info_worker
```

### Logs

`/etc/logrotate.d/shards.info`

```text
/home/sammy/projects/shards-info/log/*.log {
  su sammy sammy
  weekly
  missingok
  rotate 4
  compress
  notifempty
  create 0640 sammy sammy
  sharedscripts
  postrotate
    systemctl restart shards.info_web.service
    systemctl restart shards.info_worker.service
  endscript
}
```
