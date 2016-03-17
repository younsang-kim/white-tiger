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

sh $INSTALL_PACKAGE_SCRIPT/hadoop_conf.sh $1

cd $INSTALL_PACKAGE_BIN
tar -cvf hadoop-${HADOOP_VER}.tar hadoop-${HADOOP_VER} hdfs
tar -cvf apache-hive-${HIVE_VER}-bin.tar apache-hive-${HIVE_VER}-bin

ssh $INSTALL_USER_ID@$INSTALL_HIVE_IP "
cd $INSTALL_HOME
rm -rf apache-hive-${HIVE_VER}-bin.tar apache-hive-${HIVE_VER}-bin
"

RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "ssh error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 ssh error" >> $LOG_FILE
exit 1
fi

scp $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}.tar $INSTALL_PACKAGE_BIN/apache-hive-${HIVE_VER}-bin.tar ${INSTALL_USER_ID}@${INSTALL_HIVE_IP}:$INSTALL_HOME
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
echo "scp error"
exit 1
fi

ssh $INSTALL_USER_ID@$INSTALL_HIVE_IP "
cd $INSTALL_HOME
tar -xvf hadoop-${HADOOP_VER}.tar
tar -xvf apache-hive-${HIVE_VER}-bin.tar
rm hadoop-${HADOOP_VER}.tar
rm apache-hive-${HIVE_VER}-bin.tar
"

RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "tar error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

cd $INSTALL_HOME/hadoop-${HADOOP_VER}/sbin
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "cd error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 cd error" >> $LOG_FILE
exit 1
fi


sh start-all.sh
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "hadoop start error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 hadoop start error" >> $LOG_FILE
exit 1
fi

ssh $INSTALL_USER_ID@$INSTALL_DB_IP "
cd $INSTALL_HOME/postgresql-${POSTGRESQL_VER}-bin/bin
sh start.sh
"
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "db start error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 db start error" >> $LOG_FILE
exit 1
fi

echo "just wait one min.."
sleep 60

ssh $INSTALL_USER_ID@$INSTALL_HIVE_IP "
cd apache-hive-${HIVE_VER}-bin/bin
./schematool -dbType postgres -initSchema
./hive <<!
grant All to user ${INSTALL_USER_ID};
grant All to user hive;
CREATE DATABASE IF NOT EXISTS test_db;
!
"
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
echo "hive create database error"
sh stop-all.sh
ssh $INSTALL_USER_ID@$INSTALL_DB_IP "
cd $INSTALL_HOME/postgresql-${POSTGRESQL_VER}-bin/bin
sh stop.sh
"
exit 1
fi

ssh $INSTALL_USER_ID@$INSTALL_DB_IP "
cd $INSTALL_HOME/postgresql-${POSTGRESQL_VER}-bin/bin
sh stop.sh
"
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "db stop error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 db stop error" >> $LOG_FILE
exit 1
fi

sh stop-all.sh
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "hadoop stop error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 hadoop stop error" >> $LOG_FILE
exit 1
fi

exit 0
