#! /bin/sh

ref_dt=`date +'%Y%m%d'`
if [ $# -ne 1 ] ; then
    echo "Usage: $0 log_file_name"
exit 1
fi

log_file_name=$1

###############
#  ENV START  #
###############

PRG="$0"
PRG_ID="${0##*/}"
PRG_NM=`echo ${PRG_ID} |cut -d. -f1`

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '.*/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRG_DIR=`dirname "$PRG"`

[ -z "$PRG_HOME" ] && PRG_HOME=`cd "$PRG_DIR/.." ; pwd`

if [ -r "$PRG_HOME"/env/shell.env ]; then
  . "$PRG_HOME"/env/shell.env
fi

if [ ! -d "$INSTALL_PACKAGE_LOG_DIR" ] ; then
    mkdir -p "$INSTALL_PACKAGE_LOG_DIR"
fi

if [ ! -d "$INSTALL_PACKAGE_LOG_DIR/$ref_dt" ] ; then
    mkdir -p "$INSTALL_PACKAGE_LOG_DIR/$ref_dt"
fi

LOG_FILE="$INSTALL_PACKAGE_LOG_DIR/$ref_dt/${log_file_name}"

if [ ! -e "$LOG_FILE" ] ; then
    echo "#logtime|work_dt|task|state|description" > $LOG_FILE
fi

###############
#  ENV END    #
###############

#DB ENV SET#
echo "POSTGRES_HOME=${INSTALL_DB_HOME}/postgresql-${POSTGRESQL_VER}-bin" > $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/postgresql_env.sh
echo "PGLIB=\$POSTGRES_HOME/lib" >> $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/postgresql_env.sh
echo "PGDATA=\$POSTGRES_HOME/data" >> $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/postgresql_env.sh
echo "export POSTGRES_HOME PGLIB PGDATA" >> $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/postgresql_env.sh

echo "ALTER USER ${INSTALL_USER_ID} WITH PASSWORD '${INSTALL_USER_ID}1234';" > $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/init.sql
echo "CREATE USER hive with password 'hive123';" >>$INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/init.sql
echo "CREATE database hive;" >> $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/init.sql
echo "GRANT ALL PRIVILEGES ON DATABASE hive TO hive;" >> $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}/init.sql

cd $INSTALL_PACKAGE_BIN

tar -cvf postgresql-${POSTGRESQL_VER}.tar postgresql-${POSTGRESQL_VER}

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${INSTALL_USER_PWD} scp -o StrictHostKeyChecking=no $INSTALL_PACKAGE_BIN/postgresql-${POSTGRESQL_VER}.tar ${INSTALL_DB_ID}@${INSTALL_DB_IP}:$INSTALL_DB_HOME
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "scp error"
  echo "$datetime|$work_dt|$PRG_NM|Error|scp error" >> $LOG_FILE
exit 1
fi

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${INSTALL_USER_PWD} ssh -o StrictHostKeyChecking=no $INSTALL_USER_ID@$INSTALL_DB_IP "
rm -rf $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin
cd $INSTALL_DB_HOME
tar -xvf postgresql-${POSTGRESQL_VER}.tar
cd $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}
./configure --prefix=$INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin --enable-depend --enable-nls=ko --with-openssl --disable-spinlocks
make clean
make -j 4
make install
cd $INSTALL_DB_HOME
"

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "execute ssh command error"
  echo "$datetime|$work_dt|$PRG_NM|Error|execute ssh command error" >> $LOG_FILE
exit 1
fi

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${INSTALL_USER_PWD} ssh -o StrictHostKeyChecking=no $INSTALL_USER_ID@$INSTALL_DB_IP "
cp $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}/postgresql_env.sh $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin
cd $INSTALL_DB_HOME
. $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/postgresql_env.sh
cd $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin
./initdb -E utf-8 $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data
echo \"listen_addresses='*'\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/postgresql.conf
echo \"search_path = 'hive,public'\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/postgresql.conf
./pg_ctl -l $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/pgLog.log start
sleep 10
./createdb
./psql < $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}/init.sql
./pg_ctl stop
echo \"host    hive         hive     0.0.0.0/0       md5\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/pg_hba.conf
echo \"host    postgres     hive     0.0.0.0/0       md5\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/pg_hba.conf
echo \"host    all             all             0.0.0.0/0               trust\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/pg_hba.conf
echo \"host    $INSTALL_USER_ID     hive     0.0.0.0/0       md5\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/pg_hba.conf
echo \"host    $INSTALL_USER_ID     $INSTALL_USER_ID     0.0.0.0/0       md5\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/data/pg_hba.conf
echo \"#!/bin/bash\" > $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin//bin/start.sh
echo \". $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/postgresql_env.sh\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/start.sh
echo \"./pg_ctl -l $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/pgLog.log start\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/start.sh
echo \"#!/bin/bash\" > $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/stop.sh
echo \". $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/postgresql_env.sh\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/stop.sh
echo \"./pg_ctl -m immediate stop\" >> $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/stop.sh
chmod 755 $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/start.sh $INSTALL_DB_HOME/postgresql-${POSTGRESQL_VER}-bin/bin/stop.sh
"

RETVAL=$?
if [ $RETVAL -eq 0 ] ; then
    echo "OK: db install"
    datetime=`date +'%Y-%m-%d %H:%M:%S'`
    echo "$datetime|$work_dt|$PRG_NM|OK|db install OK" >> $LOG_FILE
else
    echo "Error: db install"
    datetime=`date +'%Y-%m-%d %H:%M:%S'`
    echo "$datetime|$work_dt|$PRG_NM|Error|db install Error" >> $LOG_FILE
    exit 1
fi

exit 0
