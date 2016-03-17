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

cd $INSTALL_PACKAGE_BIN
tar -cvf spark-${SPARK_VER}-bin-hadoop2.6.tar spark-${SPARK_VER}-bin-hadoop2.6

INSTALL_LIST="$DATA_NODE_IP $INSTALL_HIVE_IP"

for ATTR in $INSTALL_LIST
do

ssh $INSTALL_USER_ID@$ATTR "
cd $INSTALL_HOME
rm -rf spark-${SPARK_VER}-bin-hadoop2.6
"

RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
echo "rm error"
exit 1
fi
done

for ATTR in $INSTALL_LIST
do

scp $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6.tar ${INSTALL_USER_ID}@${ATTR}:$INSTALL_HOME
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
echo "scp error"
exit 1
fi
done

for ATTR in $INSTALL_LIST
do

ssh $INSTALL_USER_ID@$ATTR "
cd $INSTALL_HOME
tar -xvf spark-${SPARK_VER}-bin-hadoop2.6.tar
rm -f spark-${SPARK_VER}-bin-hadoop2.6.tar
"

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "tar error"
exit 1
fi

done

exit 0
