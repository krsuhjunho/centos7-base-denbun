#!/bin/bash
#VAR
SRC_PATH="/usr/local/src/"
DENBUN_PATH="dnpwml"
CGI_PATH="/var/www/cgi-bin"
HTML_PATH="/var/www/html"
POSTGRESQL="postgresql-9.2.24"
SYSTEMD_PGSQL="/etc/rc.d/init.d/postgresql"
PGSQL_PATH="/var/pgsql"
USER_POSTGRES="postgres"
USER_APACHE="apache"



#POSTGRESQL INSTALL
cd ${SRC_PATH}${POSTGRESQL}
./configure
gmake
gmake install
gmake clean


#POSTGRESQL INIT
useradd ${USER_POSTGRES}
sleep 3
mkdir -p ${PGSQL_PATH}/data
chown -R ${USER_POSTGRES}:${USER_POSTGRES} ${PGSQL_PATH}
echo
sleep 1
echo
su - ${USER_POSTGRES} -c 'PATH=$PATH:/usr/local/pgsql/bin;initdb --encoding=utf8 --no-locale -D /var/pgsql/data'
su - ${USER_POSTGRES} -c 'PATH=$PATH:/usr/local/pgsql/bin;pg_ctl -D /var/pgsql/data -l logfile start'
sleep 3

#POSTGRESQL AUTO RESTART ON
cp ${SRC_PATH}${POSTGRESQL}/contrib/start-scripts/linux ${SYSTEMD_PGSQL}
chmod 755 ${SYSTEMD_PGSQL}
sed -i '30,40s#/usr/local/pgsql/data#/var/pgsql/data#g' /etc/init.d/postgresql

sleep 2
echo
cat /etc/init.d/postgresql
sleep 2
chkconfig --add postgresql
chkconfig --list | grep postgresql

#DENBUN MAIL INSTALL
sleep 3
chown -R ${USER_APACHE}:${USER_APACHE} ${SRC_PATH}${DENBUN_PATH}
mv ${SRC_PATH}${DENBUN_PATH}/dnpwmlroot ${HTML_PATH}
mv ${SRC_PATH}${DENBUN_PATH}/ ${CGI_PATH}
sleep 3

#POSTGRESQL CREATE DENBUN ACCOUNT
su - ${USER_POSTGRES} -c "PATH=$PATH:/usr/local/pgsql/bin;psql template1"<<EOF
CREATE ROLE dnpwml LOGIN PASSWORD 'dnpwml' NOINHERIT VALID UNTIL 'infinity';
EOF
sleep 3

#DENBUN MAIL POSTGRESQL INIT
chmod 777 ${CGI_PATH}/${DENBUN_PATH}/admintools/dbfile/dnpwmldb.pgdmp
su - ${USER_POSTGRES} -c 'PATH=$PATH:/usr/local/pgsql/bin;pg_restore -C -Fc -d template1 /var/www/cgi-bin/dnpwml/admintools/dbfile/dnpwmldb.pgdmp'

#DENBUN HTTPD SETUP
sleep 3
echo "#############HTTPD SETENV LIBRARY_PATH################"
echo "SetEnv LD_LIBRARY_PATH ${CGI_PATH}/${DENBUN_PATH}/lib" >> /etc/httpd/conf/httpd.conf

