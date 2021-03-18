#!/bin/bash
SRC_PATH="/usr/local/src/"
DENBUN_PATH="dnpwml"
#POSTGRESQL INSTALL
cd ${SRC_PATH}postgresql-9.2.24
./configure
gmake
gmake install
gmake clean
#POSTGRESQL INIT
useradd postgres
sleep 3
mkdir -p /var/pgsql/data
chown -R postgres:postgres /var/pgsql
echo
sleep 1
echo
su - postgres -c 'PATH=$PATH:/usr/local/pgsql/bin;initdb --encoding=utf8 --no-locale -D /var/pgsql/data'
su - postgres -c 'PATH=$PATH:/usr/local/pgsql/bin;pg_ctl -D /var/pgsql/data -l logfile start'
sleep 3

#POSTGRESQL AUTO RESTART ON
cp ${SRC_PATH}postgresql-9.2.24/contrib/start-scripts/linux /etc/rc.d/init.d/postgresql
chmod 755 /etc/rc.d/init.d/postgresql
sed -i '30,40s#/usr/local/pgsql/data#/var/pgsql/data#g' /etc/init.d/postgresql

sleep 2
echo
cat /etc/init.d/postgresql
sleep 2
chkconfig --add postgresql
chkconfig --list | grep postgresql

#DENBUN MAIL INSTALL
sleep 3
chown -R apache:apache ${SRC_PATH}${DENBUN_PATH}
mv ${SRC_PATH}${DENBUN_PATH}/dnpwmlroot /var/www/html
mv ${SRC_PATH}${DENBUN_PATH}/ /var/www/cgi-bin
sleep 3

#POSTGRESQL CREATE DENBUN ACCOUNT
su - postgres -c "PATH=$PATH:/usr/local/pgsql/bin;psql template1"<<EOF
CREATE ROLE dnpwml LOGIN PASSWORD 'dnpwml' NOINHERIT VALID UNTIL 'infinity';
EOF
sleep 3

#DENBUN MAIL POSTGRESQL INIT
chmod 777 /var/www/cgi-bin/${DENBUN_PATH}/admintools/dbfile/dnpwmldb.pgdmp
su - postgres -c 'PATH=$PATH:/usr/local/pgsql/bin;pg_restore -C -Fc -d template1 /var/www/cgi-bin/dnpwml/admintools/dbfile/dnpwmldb.pgdmp'

#DENBUN HTTPD SETUP
sleep 3
echo "#############HTTPD SETENV LIBRARY_PATH################"
echo "SetEnv LD_LIBRARY_PATH /var/www/cgi-bin/${DENBUN_PATH}/lib" >> /etc/httpd/conf/httpd.conf

