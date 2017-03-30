#! /bin/sh

ref_dt=`date +'%Y%m%d'`
if [ $# -ne 1 ] ; then
    echo "Usage: $0 log_file_name"
exit 1
fi

log_file_name=$1


# OS specific support.  $var _must_ be set to either true or false.
#cygwin=false
#os400=false
#case "`uname`" in
#CYGWIN*) cygwin=true;;
#OS400*) os400=true;;
#esac

#-----------------------------------------------------------------------
#
#  Program Home Check.
#
#-----------------------------------------------------------------------

# resolve links - $0 may be a softlink
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

# Get standard environment variables
PRG_DIR=`dirname "$PRG"`

# Only set PRG_HOME if not already set
[ -z "$PRG_HOME" ] && PRG_HOME=`cd "$PRG_DIR/.." ; pwd`

if [ -r "$PRG_HOME"/env/shell.env ]; then
  . "$PRG_HOME"/env/shell.env
fi

# echo "PRG=$PRG"
# echo "PRG_DIR=$PRG_DIR"
# echo "PRG_HOME=$PRG_HOME"
# echo "PRG_ID=$PRG_ID"
# echo "PRG_NM=$PRG_NM"

LOG_FILE="$INSTALL_PACKAGE_LOG_DIR/$ref_dt/${log_file_name}"


#########################################
#########################################
##
##   ENV START
##
#########################################
#########################################

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

#if $cygwin; then
#    MY_INSTALL_HOME=`cygpath --path --mixed "$INSTALL_HOME"`
#    MY_INSTALL_META=`cygpath --path --mixed "$INSTALL_LOG_DIR"`
#else
#    MY_INSTALL_HOME="$INSTALL_HOME"
#    MY_INSTALL_META="$INSTALL_LOG_DIR"
#fi

#########################################
#########################################
##
##   ENV END
##
#########################################
#########################################

datetime=`date +'%Y-%m-%d %H:%M:%S'`
if [ $# -ne 1 ] ; then
    echo "Usage: $0 work_dt"
    echo "$datetime|$work_dt|$PRG_NM|Error|Usage: $0 work_dt" >> $LOG_FILE
exit 1
fi

cd $INSTALL_HOME/hadoop-${HADOOP_VER}/sbin

sh stop-all.sh

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
echo "stop hadoop error"
fi

ssh $INSTALL_USER_ID@$INSTALL_DB_IP "
cd $INSTALL_HOME/postgresql-${POSTGRESQL_VER}-bin/bin
./pg_ctl -D $INSTALL_HOME/postgresql-${POSTGRESQL_VER}-bin/data -m immediate stop
"

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
echo "ssh db stop error"
fi

ssh $INSTALL_USER_ID@$INSTALL_HIVE_IP "
cd $INSTALL_HOME/apache-hive-${HIVE_VER}-bin/bin
sh stop.sh
"

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
echo "ssh hive stop error"
fi

ssh $INSTALL_USER_ID@$INSTALL_HIVE_IP "
cd $INSTALL_HOME/spark-${SPARK_VER}-bin-hadoop${SPARK_HADOOP_VER}/sbin
sh stop-thriftserver.sh
sh stop-slaves.sh
sh stop-master.sh
"

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
echo "ssh spark stop error"

fi

exit 0
