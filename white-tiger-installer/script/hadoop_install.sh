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

if [ ! -d "hdfs" ] ; then
    mkdir -p "hdfs"
    mkdir -p "hdfs/data"
    mkdir -p "hdfs/logs"
    mkdir -p "hdfs/name"
    mkdir -p "hdfs/temp"
fi

tar -cvf hadoop-${HADOOP_VER}.tar hadoop-${HADOOP_VER} hdfs

rm -rf  $INSTALL_HOME/hadoop-${HADOOP_VER}.tar $INSTALL_HOME/hadoop-${HADOOP_VER}

INSTALL_LIST="$NAME_NODE_IP $SECOND_NAME_NODE_IP $DATA_NODE_IP"

for ATTR in $INSTALL_LIST
do

ssh $INSTALL_USER_ID@$ATTR "
cd $INSTALL_HOME
rm -rf hadoop-${HADOOP_VER}.tar hadoop-${HADOOP_VER} hdfs
"

RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "rm error"
  echo "$datetime|$work_dt|$PRG_NM|Error|rm Error" >> $LOG_FILE
exit 1
fi
done

for ATTR in $INSTALL_LIST
do

scp $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}.tar ${INSTALL_USER_ID}@${ATTR}:$INSTALL_HOME
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "scp error"
  echo "$datetime|$work_dt|$PRG_NM|Error|scp Error" >> $LOG_FILE
exit 1
fi
done

for ATTR in $INSTALL_LIST
do

ssh $INSTALL_USER_ID@$ATTR "
cd $INSTALL_HOME
tar -xvf hadoop-${HADOOP_VER}.tar
rm -f hadoop-${HADOOP_VER}.tar

if [ -f $INSTALL_HOME/.bashrc.bak ] ; then
  echo \"OK file exist\"
else
  cp $INSTALL_HOME/.bashrc $INSTALL_HOME/.bashrc.bak
fi

cp $INSTALL_HOME/.bashrc.bak $INSTALL_HOME/.bashrc

echo "export HADOOP_HOME=$INSTALL_HOME/hadoop-${HADOOP_VER}" >> $INSTALL_HOME/.bashrc
echo "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> $INSTALL_HOME/.bashrc
echo "export HADOOP_COMMON_HOME=\$HADOOP_HOME" >> $INSTALL_HOME/.bashrc
echo "export HADOOP_HDFS_HOME=\$HADOOP_HOME" >> $INSTALL_HOME/.bashrc
echo "export YARN_HOME=\$HADOOP_HOME" >> $INSTALL_HOME/.bashrc
echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> $INSTALL_HOME/.bashrc
echo "export YARN_CONF_DIR=\$HADOOP_HOME/etc/hadoop" >> $INSTALL_HOME/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native/" >> $INSTALL_HOME/.bashrc
echo "export HADOOP_OPTS=\$HADOOP_HOME/lib/" >> $INSTALL_HOME/.bashrc
"
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  echo "tar error"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|ssh command Error" >> $LOG_FILE
exit 1
fi
done

cd $INSTALL_HOME/hadoop-${HADOOP_VER}/bin

echo -e "Y" | sh hadoop namenode -format

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "Error: hadoop install"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop install Error" >> $LOG_FILE
  exit 1
fi

cd $INSTALL_HOME/hadoop-${HADOOP_VER}/sbin

sh start-all.sh

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "Error: hadoop start"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop start Error" >> $LOG_FILE
  exit 1
fi

cd $INSTALL_HOME/hadoop-${HADOOP_VER}/bin

sh hadoop dfsadmin -safemode leave
sh hadoop dfs -mkdir /tmp
sh hadoop dfs -mkdir /tmp/hive-${INSTALL_USER_ID}

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "Error: hadoop tmp mkdir"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop tmp mkdir Error" >> $LOG_FILE
  sh stop-all.sh
  exit 1
fi

sh hadoop dfs -chmod -R 777 /tmp

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "Error: hadoop tmp chmod 777"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop tmp chmod 777 Error" >> $LOG_FILE
  sh stop-all.sh
  exit 1
fi

cd $INSTALL_HOME/hadoop-${HADOOP_VER}/sbin

sh stop-all.sh

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "Error: hadoop stop"
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "$datetime|$work_dt|$PRG_NM|Error|hadoop stop Error" >> $LOG_FILE
  exit 1
fi

exit 0
