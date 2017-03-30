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

INSTALL_LIST="$NAME_NODE_IP $SECOND_NAME_NODE_IP $DATA_NODE_IP $INSTALL_HIVE_IP"

cp -R $INSTALL_PACKAGE_HOME/bin/sshpass-1.05.tar $INSTALL_HOME

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "sshpass copy error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 sshpass copy error" >> $LOG_FILE
exit 1
fi

cd $INSTALL_HADOOP_HOME

tar -xvf sshpass-1.05.tar

rm sshpass-1.05.tar

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "tar error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 tar error" >> $LOG_FILE
exit 1
fi

cd sshpass-1.05

./configure --prefix=$INSTALL_HOME/sshpass_bin

make

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "sshpass compile error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 sshpass compile error" >> $LOG_FILE
exit 1
fi

make install

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "sshpass bin install error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 sshpass bin install error" >> $LOG_FILE
exit 1
fi

echo "connect test start"
for ATTR in $INSTALL_LIST
do

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${ROOT_PWD} ssh -o StrictHostKeyChecking=no root@$ATTR whoami

RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  echo "not connected $ATTR user=root"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 not connected $ATTR user=root" >> $LOG_FILE
exit 1
fi

done
echo "connect test end"

for ATTR in $INSTALL_LIST
do
$INSTALL_HOME/sshpass_bin/bin/sshpass -p${ROOT_PWD} ssh -o StrictHostKeyChecking=no root@$ATTR "
ufw disable
apt-get update
apt-get -y install openjdk-7-jdk
apt-get -y install g++-4.8
apt-get -y install g++
apt-get -y install net-tools
apt-get -y install iputils-ping
apt-get -y install ssh
apt-get -y install vim
echo -e \"${INSTALL_USER_PWD}\\n${INSTALL_USER_PWD}\\n\\n\\n\\n\\n\\nY\\n\" | adduser $INSTALL_USER_ID
"

RETVAL=$?
if [ $RETVAL -ne 0 ] && [ $RETVAL -ne 1 ] ; then
  echo "passwd Error && install stoped"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 passwd Error && install stoped" >> $LOG_FILE
exit 1
fi

done

echo "install_default_lib_adduser.sh OK"
echo "$datetime|$ref_dt|$PRG_NM|OK|$0 install_default_lib_adduser.sh OK" >> $LOG_FILE

exit 0
