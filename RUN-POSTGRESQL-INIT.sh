#!/bin/bash
#VAR
SRC_PATH="/usr/local/src/"
DENBUN_PATH="dnpwml"
POSTGRESQL="postgresql-9.2.24"
POSTGRESQL_PATH="${SRC_PATH}${POSTGRESQL}"
SYSTEMD_PGSQL="/etc/rc.d/init.d/postgresql"
PGSQL_PATH="/var/pgsql"
POSTGRES_USER="postgres"
USER_APACHE="apache"

ECHO_MESSAGE()
{
echo ""
echo "##########  ${1}  ###########"
echo ""
}

POSTGRESQL_INSTALL()
{
#POSTGRESQL INSTALL
ECHO_MESSAGE "POSTGRESQL INSTALL"
ECHO_MESSAGE "POSTGRESQL VER => ${POSTGRESQL}"
ECHO_MESSAGE "POSTGRESQL PATH => ${POSTGRESQL_PATH}"
cd ${POSTGRESQL_PATH}
ECHO_MESSAGE "Postgres Configure"
./configure
ECHO_MESSAGE "Postgres Compile Start"
gmake
ECHO_MESSAGE "Postgres Install"
gmake install
ECHO_MESSAGE "Postgres Install Clean"
gmake clean
}

POSTGRESQL_INIT()
{
#POSTGRES USER CREATE
ECHO_MESSAGE "POSTGRES USER CREATE"
useradd ${POSTGRES_USER}
sleep 1
mkdir -p ${PGSQL_PATH}/data
chown -R ${POSTGRES_USER}:${POSTGRES_USER} ${PGSQL_PATH}

#SET POSTGRES USER .BASH_PROFILE
ECHO_MESSAGE "SET POSTGRES USER .BASH_PROFILE"									
#su - ${POSTGRES_USER} -c "sed -i 's/PATH=\$PATH:\$HOME\/bin/PATH=\$PATH:\$HOME\/bin:\/usr\/local\/pgsql\/bin/g' ~/.bash_profile"
su - ${POSTGRES_USER} -c "sed -i 's/PATH=\$PATH:\$HOME\/.local\/bin:\$HOME\/bin/PATH=\$PATH:\$HOME\/.local\/bin:\$HOME\/bin:\/usr\/local\/pgsql\/bin/g' ~/.bash_profile"
su - ${POSTGRES_USER} -c "source ~/.bash_profile;cat ~/.bash_profile"
sleep 3

#POSTGRESQL DB INIT START
ECHO_MESSAGE "POSTGRESQL DB INIT START"
su - ${POSTGRES_USER} -c 'initdb --encoding=utf8 --no-locale -D /var/pgsql/data'

#POSTGRESQL START
ECHO_MESSAGE "POSTGRESQL START"
su - ${POSTGRES_USER} -c 'pg_ctl -D /var/pgsql/data -l logfile start'
sleep 5

#POSTGRESQL CREATE DENBUN ACCOUNT
ECHO_MESSAGE "POSTGRESQL CREATE DENBUN ACCOUNT"
su - ${POSTGRES_USER} -c "psql template1"<<EOF
CREATE ROLE dnpwml LOGIN PASSWORD 'dnpwml' NOINHERIT VALID UNTIL 'infinity';
EOF
sleep 3

#POSTGRESQL AUTO RESTART ON
cp ${POSTGRESQL_PATH}/contrib/start-scripts/linux ${SYSTEMD_PGSQL}
chmod 755 ${SYSTEMD_PGSQL}
sed -i '30,40s#/usr/local/pgsql/data#/var/pgsql/data#g' /etc/init.d/postgresql

sleep 2
echo
cat /etc/init.d/postgresql | grep "PGDATA="
sleep 2

#DB AutoRestart SETUP
ECHO_MESSAGE "DB AutoStart SETUP"
chkconfig --add postgresql
chkconfig --list | grep postgresql

}


MAIN()
{
POSTGRESQL_INSTALL
POSTGRESQL_INIT
}

MAIN
