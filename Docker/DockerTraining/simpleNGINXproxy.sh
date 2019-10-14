#!/bin/bash
nginx_settings_folder=/home/vagrant/

# run Tomcat
docker run --name appserver -d -p 8080:8080 tomcat

# create settings folder for NGINX
mkdir -p $nginx_settings_folder/nginx/conf.d/
tee $nginx_settings_folder/nginx/conf.d/tomcat.conf <<EOF
server {
  listen 80;
  server_name localhost;

  location / {
    proxy_pass http://tomcat:8080;
  }
}
EOF

# run NGINX
docker run --name webserver -v $nginx_settings_folder/nginx/conf.d/:/etc/nginx/conf.d/ -d -p 80:80 nginx