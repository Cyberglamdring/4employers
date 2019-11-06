#!/bin/bash
jenkins_port=8912
jenkins_cn=jenkins-master
# jenkins_volume=/var/lib/docker/volumes/jenkins_home/_data

docker run --name=$jenkins_cn -d -p $jenkins_port:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
docker exec $jenkins_cn cat /var/jenkins_home/secrets/initialAdminPassword


# reset password
# docker exec -d jenkins-master sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/'  var/jenkins_home/config.xml
# docker restart $jenkins_cn
# change password
# docker exec -d jenkins-master sed -i 's/<useSecurity>false<\/useSecurity>/<useSecurity>true<\/useSecurity>/'  var/jenkins_home/config.xml
# docker restart $jenkins_cn