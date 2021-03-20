#BASE IMAGE
FROM ghcr.io/krsuhjunho/centos7-base-systemd

#Utils Install 
RUN yum install -y httpd ld-linux.so.2 \
libstdc++.i686  gcc-c++ gnu-make \
readline-devel zlib-devel make &&\
systemctl enable httpd; yum clean all

#Copy Source File && Source Install
ADD postgresql-9.2.24.tar.gz /usr/local/src

COPY RUN-POSTGRESQL-INIT.sh /usr/local/src/RUN-POSTGRESQL-INIT.sh
RUN /usr/local/src/RUN-POSTGRESQL-INIT.sh &&\
    rm -rf /usr/local/src/RUN-POSTGRESQL-INIT.sh

COPY RUN-DENBUN-INSTALL.sh /usr/local/src/RUN-DENBUN-INSTALL.sh
RUN /usr/local/src/RUN-DENBUN-INSTALL.sh &&\
    rm -rf /usr/local/src/* && \
    rm -rf /var/www/cgi-bin/*.tar.gz

##HEALTHCHECK 
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 CMD curl -f http://127.0.0.1/cgi-bin/dnpwml/dnpwmlconfig.cgi? || exit 1


#Workdir Setup
WORKDIR /var/www

#Portopen
EXPOSE 22
EXPOSE 80

CMD ["/usr/sbin/init"]
