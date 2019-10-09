docker run --name appserver -d -p 8080:8080 tomcat
mkdir -p /home/vagrant/nginx/conf.d/
tee /home/vagrant/nginx/conf.d/tomcat.conf <<EOF
server {
  listen 80;
  server_name localhost;

  location / {
    proxy_pass http://tomcat:8080;
  }
}
EOF
docker run -v /home/vagrant/nginx/conf.d/:/etc/nginx/conf.d/ -d -p 80:80 nginx