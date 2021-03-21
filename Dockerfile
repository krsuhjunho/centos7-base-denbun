#########################################################################
#	Centos7-Base-Denbunmail Container Image				#
#	https://github.com/krsuhjunho/centos7-base-denbunmail		#
#	BASE IMAGE: ghcr.io/krsuhjunho/centos7-base-systemd		#
#########################################################################

FROM ghcr.io/krsuhjunho/centos7-base-systemd

#########################################################################
#	Install && Update 						#
#########################################################################

RUN yum install -y -q httpd \
	ld-linux.so.2 \
	libstdc++.i686  \
	gcc-c++ \
	gnu-make \
	readline-devel \
	zlib-devel \
	make && \
	systemctl enable httpd; \
	yum clean all

#########################################################################
#	POSTGRESQL 9.2.24 Source File Copy				#
#########################################################################

ADD postgresql-9.2.24.tar.gz /usr/local/src

#########################################################################
#	Postgresql 9.2.24 Init-Shell Copy && Run			#
#########################################################################

COPY RUN-POSTGRESQL-INIT.sh /usr/local/src/RUN-POSTGRESQL-INIT.sh
RUN /usr/local/src/RUN-POSTGRESQL-INIT.sh &&\
    rm -rf /usr/local/src/RUN-POSTGRESQL-INIT.sh

#########################################################################
#	Denbunmail Install-Shell Copy && Run				#
#########################################################################

COPY RUN-DENBUN-INSTALL.sh /usr/local/src/RUN-DENBUN-INSTALL.sh
RUN /usr/local/src/RUN-DENBUN-INSTALL.sh &&\
    rm -rf /usr/local/src/* && \
    rm -rf /var/www/cgi-bin/*.tar.gz

#########################################################################
#	HEALTHCHECK 							#
#########################################################################

HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 CMD curl -f http://127.0.0.1/cgi-bin/dnpwml/dnpwmlconfig.cgi? || exit 1

#########################################################################
#	WORKDIR SETUP 							#
#########################################################################

WORKDIR /var/www

#########################################################################
#	PORT OPEN							#
#	SSH PORT 22 							#
#  	HTTP PORT 80 							#
#########################################################################

EXPOSE 22
EXPOSE 80

#########################################################################
#       Systemd		 	                                        #
#########################################################################

CMD ["/usr/sbin/init"]
