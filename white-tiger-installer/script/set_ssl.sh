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

INSTALL_LIST="$SECOND_NAME_NODE_IP $DATA_NODE_IP $INSTALL_HIVE_IP"

rm ~/.ssh/*

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -P ""

PUB_KEY=`cat ~/.ssh/id_rsa.pub`

for ATTR in $INSTALL_LIST
do

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${INSTALL_USER_PWD} ssh -o StrictHostKeyChecking=no $INSTALL_USER_ID@$ATTR "
mkdir -p ~/.ssh
chmod 755 ~/.ssh
echo \"$PUB_KEY\" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/*"

RETVAL=$?
if [ $RETVAL -ne 0 ] && [ $RETVAL -ne 1 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "ssl set error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 ssl set error" >> $LOG_FILE
exit 1
fi
done

datetime=`date +'%Y-%m-%d %H:%M:%S'`
echo "$pgm:OK: set_ssl.sh"
echo "$datetime|$ref_dt|$PRG_NM|OK|$0 set_ssl.sh" >> $LOG_FILE

exit 0
