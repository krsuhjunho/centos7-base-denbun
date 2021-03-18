FROM wnwnsgh/centos7-base-systemd
RUN set -x  yum update -y && yum upgrade -y  && \
yum install -y epel-release && \
yum install -y wget htop httpd openssl vim unzip zip \
ld-linux.so.2 openssh-server openssh-clients git \
libstdc++.i686 ncdu tree cronie gcc-c++ gnu-make \
readline-devel zlib-devel &&\
systemctl enable httpd; yum clean all

ADD postgresql-9.2.24.tar.gz /usr/local/src
ADD dnpwmlV33PR80lR9pg92.tar.gz /usr/local/src
COPY RUN-POSTGRESQL-INIT.sh /usr/local/src/RUN-POSTGRESQL-INIT.sh
RUN /usr/local/src/RUN-POSTGRESQL-INIT.sh


EXPOSE 22
EXPOSE 80
CMD ["/usr/sbin/init"]