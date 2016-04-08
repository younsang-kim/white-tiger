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


sh $INSTALL_PACKAGE_SCRIPT/download.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "download.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|download.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/install_default_lib_adduser.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "install_default_lib_adduser.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|install_default_lib_adduser.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/set_ssl.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "set_ssl.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|set_ssl.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/hadoop_conf.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "hadoop_conf.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop_conf.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/hadoop_install.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "hadoop_install.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop_install.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/db_lib_install.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "db_lib_install.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|db_lib_install.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/db_install.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "db_install.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|db_install.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/hive_conf.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "hive_conf.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hive_conf.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/hive_install.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "hive_install.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hive_install.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/spark_conf.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "spark_conf.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|spark_conf.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/spark_install.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "spark_install.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|spark_install.sh Error" >> $LOG_FILE
exit 1
fi

sh $INSTALL_PACKAGE_SCRIPT/R_install.sh $1
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "R_install.sh error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|R_install.sh Error" >> $LOG_FILE
exit 1
fi


exit 0
