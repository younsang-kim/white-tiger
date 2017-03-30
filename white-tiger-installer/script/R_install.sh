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
tar -cvf R-${R_VER}.tar R-${R_VER}

INSTALL_LIST="$INSTALL_HIVE_IP"

for ATTR in $INSTALL_LIST
do

scp $INSTALL_PACKAGE_BIN/R-${R_VER}.tar ${INSTALL_USER_ID}@${ATTR}:$INSTALL_HOME
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
echo "scp error"
exit 1
fi

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${ROOT_PWD} ssh -o StrictHostKeyChecking=no root@$ATTR "
apt-get update
apt-get -y install libcairo2-dev
apt-get -y install libjpeg8-dev
apt-get -y install apt-get install libpango1.0-0
apt-get -y install build-essential
apt-get -y install libgif-dev
"

RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
echo "yum error"
exit 1
fi

ssh $INSTALL_USER_ID@$ATTR "
cd $INSTALL_HOME
tar -xvf R-${R_VER}.tar
cd $INSTALL_HOME/R-${R_VER}
./configure --enable-R-shlib --with-cairo=yes --with-libpng=yes --prefix=$INSTALL_HOME/R_${R_VER}-bin
make -j 4
make install
cd $INSTALL_HOME
rm R-${R_VER}.tar
rm -rf $INSTALL_HOME/R-${R_VER}
"
RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "Error: R install error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 R install error" >> $LOG_FILE
exit 1
fi

$INSTALL_HOME/sshpass_bin/bin/sshpass -p${ROOT_PWD} ssh -o StrictHostKeyChecking=no root@$ATTR "
echo \"remote enable\" > /etc/Rserv.conf
"

RETVAL=$?

if [ $RETVAL -ne 0 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "Error: R install error"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 R install error" >> $LOG_FILE
exit 1
fi

done

echo "R_install complete"
echo "$datetime|$ref_dt|$PRG_NM|OK|$0 R install" >> $LOG_FILE

exit 0
