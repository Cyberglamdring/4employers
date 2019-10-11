Create configuration:
```bash
docker-compose -f nginx_tomcat_network.yaml up
```

Result:
```bash
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                                      NAMES
7d43c1938c15        nginx               "nginx -g 'daemon of…"   About a minute ago   Up 4 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx-tomcat_nginx_1
24788b42490f        tomcat              "catalina.sh run"        About a minute ago   Up 4 seconds        8080/tcp                                   nginx-tomcat_tomcat_1
```