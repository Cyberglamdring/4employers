mkdir -p /home/vagrant/nginx/html/
tee /home/vagrant/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>HTML Document</title>
  </head>
  <body>
    <p>Simple web-page</p>
  </body>
</html>
EOF
docker run -v /home/vagrant/nginx/html/:/usr/share/nginx/html -d -p 80:80 nginx