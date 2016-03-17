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

#########DB LIB INSTALL########
$INSTALL_HOME/sshpass_bin/bin/sshpass -p${ROOT_PWD} ssh -o StrictHostKeyChecking=no root@$INSTALL_DB_IP "
apt-get -y install g++-4.8
apt-get -y install g++
apt-get -y install libreadline6 libreadline6-dev
apt-get -y install zlibc zlib1g zlib1g-dev
apt-get -y install openssl libssl-dev
apt-get -y install gettext
echo -e \"${INSTALL_USER_PWD}\\n${INSTALL_USER_PWD}\\n\\n\\n\\n\\n\\nY\\n\" | adduser $INSTALL_USER_ID
"

#yum -y install gcc gcc-c++ make autoconf wget readline readline-devel zlib zlib-devel openssl openssl-devel gettext gettext-devel
RETVAL=$?
if [ $RETVAL -ne 0 ] && [ $RETVAL -ne 1 ] ; then
  echo "passwd Error && install stoped"
  echo "$datetime|$work_dt|$PRG_NM|Error|passwd Error" >> $LOG_FILE
exit 1
fi

echo "OK: install lib and adduser"
echo "$datetime|$work_dt|$PRG_NM|OK|install lib and adduser OK" >> $LOG_FILE

exit 0
