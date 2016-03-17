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

if [ ! -d "$INSTALL_PACKAGE_BIN/hdfs" ] ; then
    mkdir -p "$INSTALL_PACKAGE_BIN/hdfs"
    mkdir -p "$INSTALL_PACKAGE_BIN/hdfs/data"
    mkdir -p "$INSTALL_PACKAGE_BIN/hdfs/logs"
    mkdir -p "$INSTALL_PACKAGE_BIN/hdfs/name"
    mkdir -p "$INSTALL_PACKAGE_BIN/hdfs/temp"
fi

if [ -f "$INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh.bak" ] ; then
  echo "OK file exist"
else
  cp $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh.bak
fi

if [ -f "$INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh.bak" ] ; then
  echo "OK file exist"
else
  cp $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh.bak
fi


cp $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh.bak $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "copy error hadoop-env.sh"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 copy error hadoop-env.sh" >> $LOG_FILE
exit 1
fi

cp $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh.bak $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
RETVAL=$?
if [ $RETVAL -ne 0 ] ; then
  datetime=`date +'%Y-%m-%d %H:%M:%S'`
  echo "copy error hadoop-config.sh"
  echo "$datetime|$ref_dt|$PRG_NM|Error|$0 copy error hadoop-config.sh" >> $LOG_FILE
exit 1
fi

echo "export JAVA_HOME=$JAVA_HOME" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_PREFIX=$INSTALL_HOME/hadoop-${HADOOP_VER}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_CONF_DIR=\${HADOOP_PREFIX}/etc/hadoop" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_MAPRED_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_COMMON_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_HDFS_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_LOG_DIR=$INSTALL_HOME/hdfs/logs" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export YARN_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export YARN_LOG_DIR=$INSTALL_HOME/hdfs/logs" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\${HADOOP_PREFIX}/lib/native" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh
echo "export HADOOP_OPTS=-Djava.library.path=\$HADOOP_PREFIX/lib" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hadoop-env.sh

echo "export JAVA_HOME=$JAVA_HOME" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_PREFIX=$INSTALL_HOME/hadoop-${HADOOP_VER}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_CONF_DIR=\${HADOOP_PREFIX}/etc/hadoop" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_MAPRED_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_COMMON_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_HDFS_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_LOG_DIR=$INSTALL_HOME/hdfs/logs" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export YARN_HOME=\${HADOOP_PREFIX}" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export YARN_LOG_DIR=$INSTALL_HOME/hdfs/logs" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\${HADOOP_PREFIX}/lib/native" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh
echo "export HADOOP_OPTS=-Djava.library.path=\$HADOOP_PREFIX/lib" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/libexec/hadoop-config.sh

echo "<?xml version=\"1.0\"?>" > $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "<!-- Put site-specific property overrides in this file. -->" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "<configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "  <name>fs.default.name</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "  <value>hdfs://$NAME_NODE_IP:9000</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "  <name>hadoop.tmp.dir</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "  <value>$INSTALL_HOME/hdfs/temp</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml
echo "</configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/core-site.xml

echo "<?xml version=\"1.0\"?>" > $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<!-- Put site-specific property overrides in this file. -->" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <name>dfs.replication</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <value>$REPLICATION_NUM</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <name>dfs.namenode.name.dir</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <value>file:${INSTALL_HOME}/hdfs/name</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <final>true</final>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <name>dfs.datanode.data.dir</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <value>file:${INSTALL_HOME}/hdfs/data</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <final>true</final>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <name>dfs.http.address</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <value>$NAME_NODE_IP:50070</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <name>dfs.namenode.secondary.http.address</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <value>$SECOND_NAME_NODE_IP:50090</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml

echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <name>dfs.namenode.datanode.registration.ip-hostname-check</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "  <value>false</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml

echo "</configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/hdfs-site.xml



echo "<?xml version=\"1.0\"?>" > $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<!-- Put site-specific property overrides in this file. -->" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <name>mapreduce.framework.name</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <value>yarn</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <name>mapred.local.dir</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <value>$INSTALL_HOME/hdfs/mapred/local</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <name>mapred.system.dir</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <value>$INSTALL_HOME/hdfs/mapred/system</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <name>mapred.map.output.compression.codec</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <value>org.apache.hadoop.io.compress.GzipCodec</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <name>mapred.child.java.opts</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "  <value>-server12g -XX:+UseConcMarkSweepGC -XX:-UseGCOverheadLimit</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml
echo "</configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/mapred-site.xml

echo "<?xml version=\"1.0\"?>" > $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<!-- Put site-specific property overrides in this file. -->" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <name>yarn.nodemanager.aux-services</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <value>mapreduce_shuffle</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <value>org.apache.hadoop.mapred.ShuffleHandler</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <name>yarn.resourcemanager.resource-tracker.address</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <value>${NAME_NODE_IP}:8025</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <name>yarn.resourcemanager.scheduler.address</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <value>${NAME_NODE_IP}:8030</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <name>yarn.resourcemanager.address</name>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "  <value>${NAME_NODE_IP}:8035</value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "<property>  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "       <name>yarn.application.classpath</name>  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "       <value>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/etc/hadoop,  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/common/*,  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/common/lib/*,  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/hdfs/*,  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/hdfs/lib/*,  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/yarn/*" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/yarn/lib/*" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/mapreduce/*,  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "            $INSTALL_HOME/hadoop-${HADOOP_VER}/share/hadoop/mapreduce/lib/*  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "       </value>  " >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml
echo "</property>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml

echo "</configuration>" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/yarn-site.xml

rm -f $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/slaves
rm -f $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/master

INSTALL_LIST="$NAME_NODE_IP"

for ATTR in $INSTALL_LIST
do
echo "$INSTALL_USER_ID@$ATTR" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/master
done

INSTALL_LIST="$DATA_NODE_IP"

for ATTR in $INSTALL_LIST
do
echo "$INSTALL_USER_ID@$ATTR" >> $INSTALL_PACKAGE_BIN/hadoop-${HADOOP_VER}/etc/hadoop/slaves
done

datetime=`date +'%Y-%m-%d %H:%M:%S'`
echo "OK : hadoop.conf.sh"
echo "$datetime|$ref_dt|$PRG_NM|OK|$0 hadoop.conf.sh" >> $LOG_FILE

exit 0
