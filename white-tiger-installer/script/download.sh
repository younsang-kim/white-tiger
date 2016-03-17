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
rm -rf $INSTALL_PACKAGE_BIN
if [ ! -d "$INSTALL_PACKAGE_BIN" ] ; then
    mkdir -p "$INSTALL_PACKAGE_BIN"
fi

cd $INSTALL_PACKAGE_BIN
wget $HADOOP_DOWN_URL

RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "hadoop download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 hadoop download error ( check url )" >> $LOG_FILE
exit 1
fi

wget $HIVE_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "hive download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 hive download error ( check url )" >> $LOG_FILE
exit 1
fi

wget $POSTGRESQL_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "postgresql download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 postgresql download error ( check url )" >> $LOG_FILE
exit 1
fi

wget $SSHPASS_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "sshpass download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 sshpass download error ( check url )" >> $LOG_FILE
exit 1
fi

mv download sshpass-${SSHPASS_VER}.tar.gz

wget $SPARK_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "spark download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 spark download error ( check url )" >> $LOG_FILE
exit 1
fi

wget $R_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "R download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 R download error ( check url )" >> $LOG_FILE
exit 1
fi

gzip -d *.gz
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "gzip error"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 gzip error" >> $LOG_FILE
exit 1
fi

tar -xvf hadoop-${HADOOP_VER}.tar
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "tar error"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

tar -xvf apache-hive-${HIVE_VER}-bin.tar
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "tar error"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

tar -xvf postgresql-${POSTGRESQL_VER}.tar
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "tar error"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

tar -xvf R-${R_VER}.tar
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "tar error"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

tar -xvzf spark-${SPARK_VER}-bin-hadoop2.6.tgz
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "tar error"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

cd $INSTALL_PACKAGE_BIN/apache-hive-${HIVE_VER}-bin/lib

wget $POSTGRESQL_JDBC_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "postgresql jdbc download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 postgresql jdbc download error ( check url )" >> $LOG_FILE
exit 1
fi

cd $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/lib
wget $POSTGRESQL_JDBC_DOWN_URL
RETVAL=$?
datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $RETVAL -ne 0 ] ; then
    echo "postgresql jdbc download error ( check url )"
    echo "$datetime|$ref_dt|$PRG_NM|Error|$0 postgresql jdbc download error ( check url )" >> $LOG_FILE
exit 1
fi

exit 0
