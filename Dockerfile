FROM ghcr.io/krsuhjunho/centos7-base-systemd
RUN yum install -y httpd ld-linux.so.2 \
libstdc++.i686  gcc-c++ gnu-make \
readline-devel zlib-devel make &&\
systemctl enable httpd; yum clean all

ADD postgresql-9.2.24.tar.gz /usr/local/src

COPY RUN-POSTGRESQL-INIT.sh /usr/local/src/RUN-POSTGRESQL-INIT.sh
RUN /usr/local/src/RUN-POSTGRESQL-INIT.sh &&\
    rm -rf /usr/local/src/RUN-POSTGRESQL-INIT.sh

COPY RUN-DENBUN-INSTALL.sh /usr/local/src/RUN-DENBUN-INSTALL.sh
RUN /usr/local/src/RUN-DENBUN-INSTALL.sh &&\
    rm -rf /usr/local/src/*

EXPOSE 22
EXPOSE 80
CMD ["/usr/sbin/init"]
