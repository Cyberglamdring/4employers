FROM centos
LABEL key="hleb_kanonik@epam.com"

RUN yum update -y && \
    yum install -y httpd && \
    yum clean all

COPY index.html /var/www/html

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND" ]
EXPOSE 80