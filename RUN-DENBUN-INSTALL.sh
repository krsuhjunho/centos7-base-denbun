#!/bin/bash
#VAR
SRC_PATH="/usr/local/src/"
CGI_PATH="/var/www/cgi-bin"
DENBUN_PATH="${CGI_PATH}/dnpwml"
HTML_PATH="/var/www/html"
POSTGRESQL="postgresql-9.2.24"
POSTGRESQL_PATH="${SRC_PATH}${POSTGRESQL}"
SYSTEMD_PGSQL="/etc/rc.d/init.d/postgresql"
PGSQL_PATH="/var/pgsql"
USER_POSTGRES="postgres"
USER_APACHE="apache"
DENBUN_FILE_NAME="dnpwmlV33PR80lR9pg92.tar.gz"
DENBUN_FILE_URL="https://www.denbun.com/binary/Linux/RedHat9/${DENBUN_FILE_NAME}"


ECHO_MESSAGE()
{
echo ""
echo "##########  ${1}  ###########"
echo ""
}

DENBUN_MAIL_INSTALL()
{
#DENBUN MAIL INSTALL
ECHO_MESSAGE "DENBUN MAIL INSTALL"
cd ${CGI_PATH}
wget ${DENBUN_FILE_URL} --no-check-certificate
tar -zxf ${DENBUN_FILE_NAME}
chown -R ${USER_APACHE}:${USER_APACHE} ${DENBUN_PATH}
mv ${DENBUN_PATH}/dnpwmlroot ${HTML_PATH}
sleep 3
}

POSTGRESQL_DB_DENBUN_INIT()
{


#POSTGRESQL START
ECHO_MESSAGE "POSTGRESQL START"
su - ${USER_POSTGRES} -c 'pg_ctl -D /var/pgsql/data -l logfile start'
sleep 5

ECHO_MESSAGE "DENBUN MAIL POSTGRESQL INIT"
#DENBUN MAIL POSTGRESQL INIT
chmod 777 ${DENBUN_PATH}/admintools/dbfile/dnpwmldb.pgdmp
su - ${USER_POSTGRES} -c 'pg_restore -C -Fc -d template1 /var/www/cgi-bin/dnpwml/admintools/dbfile/dnpwmldb.pgdmp'
}

DENBUN_HTTPD_SETUP()
{

#DENBUN HTTPD SETUP
sleep 3
ECHO_MESSAGE "HTTPD SETENV LIBRARY_PATH"
echo "SetEnv LD_LIBRARY_PATH ${DENBUN_PATH}/lib" >> /etc/httpd/conf/httpd.conf
}

MAIN()
{
DENBUN_MAIL_INSTALL
POSTGRESQL_DB_DENBUN_INIT
DENBUN_HTTPD_SETUP
}

MAIN
