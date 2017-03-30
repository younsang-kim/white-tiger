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

rm -f $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/slaves
INSTALL_LIST="$DATA_NODE_IP"
for ATTR in $INSTALL_LIST
do
echo "${INSTALL_USER_ID}@${ATTR}" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/slaves
done

echo "#!/usr/bin/env bash" > $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export STANDALONE_SPARK_MASTER_HOST=$INSTALL_HIVE_IP" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_MASTER_HOST=$INSTALL_HIVE_IP" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export HADOOP_CONF_DIR=$INSTALL_HOME/hadoop-${HADOOP_VER}/etc/hadoop" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_EXECUTOR_INSTANCES=$INSTALL_SPARK_EXECUTOR_INSTANCES" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_EXECUTOR_CORES=$INSTALL_SPARK_EXECUTOR_CORE" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_EXECUTOR_MEMORY=$INSTALL_SPARK_EXECUTOR_MEMORY" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_DRIVER_MEMORY=$INSTALL_SPARK_DRIVER_MEMORY" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_YARN_APP_NAME=Spark" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_YARN_QUEUE=Default" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_DEAMON_MEMORY=$INSTALL_SPARK_DEAMON_MEMORY" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_WORKER_MEMORY=$INSTALL_SPARK_WORKER_MEMORY" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_WORKER_INSTANCES=$INSTALL_SPARK_WORKER_INSTANCES" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_WORKER_CORES=$INSTALL_SPARK_WORKER_CORE" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "export SPARK_DEAMON_JAVA_OPTS=\"-Xms${INSTALL_SPARK_WORKER_MEMORY} -Xmx${INSTALL_SPARK_WORKER_MEMORY}\"" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh
echo "#export SPARK_JAVA_OPTS=\"-Xms${INSTALL_SPARK_WORKER_MEMORY} -Xmx${INSTALL_SPARK_WORKER_MEMORY} -Dspark.kryoserializer.buffer.mb=10 -Dspark.cleaner.ttl=43200\"" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh

echo "spark.master=spark://$INSTALL_HIVE_IP:7077" > $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "spark.driver.maxResultSize=32g" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "yarn.scheduler.maximum-allocation-mb=32g" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "spark.kryoserializer.buffer.max=1024m" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "spark.serializer=org.apache.spark.serializer.KryoSerializer" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "spark.io.compression.codec=lzf" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "spark-defaults.conf=604800" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf
echo "spark.driver.allowMultipleContexts=true" >> $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-defaults.conf

chmod 755 $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/spark-env.sh

#######################################################################################
echo "<?xml version=\"1.0\"?>" >  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<configuration>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>mapred.reduce.tasks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>-1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    <description>The default number of reduce tasks per job.  Typically set" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  to a prime close to the number of available hosts.  Ignored when" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  mapred.job.tracker is \"local\". Hadoop set this to 1 by default, whereas Hive uses -1 as its default value." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  By setting this property to -1, Hive will automatically figure out what should be the number of reducers." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.reducers.bytes.per.reducer</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>size per reducer.The default is 1G, i.e if the input size is 10G, it will use 10 reducers.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.reducers.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>999</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>max number of reducers will be used. If the one" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	specified in the configuration parameter mapred.reduce.tasks is" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	negative, Hive will use this one as the max number of reducers when" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	automatically determine number of reducers.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cli.print.header</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to print the names of the columns in query output.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cli.print.current.db</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to include the current database in the Hive prompt.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cli.prompt</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hive</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Command line prompt configuration value. Other hiveconf can be used in" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "        this configuration value. Variable substitution will only be invoked at the Hive" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "        CLI startup.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cli.pretty.output.num.cols</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>-1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The number of columns to use when formatting output generated" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "        by the DESCRIBE PRETTY table_name command.  If the value of this property" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "        is -1, then Hive will use the auto-detected terminal width.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.scratchdir</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>/tmp/hive-\${user.name}</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Scratch space for Hive jobs</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.local.scratchdir</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>/tmp/\${user.name}</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Local scratch space for Hive jobs</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.test.mode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether Hive is running in test mode. If yes, it turns on sampling and prefixes the output tablename.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.test.mode.prefix</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>test_</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>if Hive is running in test mode, prefixes the output table by this string</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!-- If the input table is not bucketed, the denominator of the tablesample is determined by the parameter below   -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!-- For example, the following query:                                                                              -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!--   INSERT OVERWRITE TABLE dest                                                                                  -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!--   SELECT col1 from src                                                                                         -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!-- would be converted to                                                                                          -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!--   INSERT OVERWRITE TABLE test_dest                                                                             -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!--   SELECT col1 from src TABLESAMPLE (BUCKET 1 out of 32 on rand(1))                                             -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.test.mode.samplefreq</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>32</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>if Hive is running in test mode and table is not bucketed, sampling frequency</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.test.mode.nosamplelist</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>if Hive is running in test mode, don't sample the above comma separated list of tables</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.uris</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>thrift://$INSTALL_HIVE_IP:9083</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Thrift URI for the remote metastore. Used by metastore client to connect to remote metastore.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.ConnectionURL</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>jdbc:postgresql://$INSTALL_DB_IP:5432/hive</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>JDBC connect string for a JDBC metastore</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.ConnectionDriverName</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.postgresql.Driver</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Driver class name for a JDBC metastore</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.PersistenceManagerFactoryClass</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.datanucleus.api.jdo.JDOPersistenceManagerFactory</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>class implementing the jdo persistence</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.DetachAllOnCommit</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>detaches all objects from session so that they can be used after transaction is committed</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.NonTransactionalRead</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>reads outside of transactions</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.ConnectionUserName</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hive</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>username to use against metastore database</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.ConnectionPassword</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hive123</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>password to use against metastore database</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>javax.jdo.option.Multithreaded</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Set this to true if multiple threads access metastore through JDO concurrently.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.connectionPoolingType</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>BoneCP</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Uses a BoneCP connection pool for JDBC metastore</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.validateTables</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>validates existing schema against code. turn this on if you want to verify existing schema </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.validateColumns</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>validates existing schema against code. turn this on if you want to verify existing schema </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.validateConstraints</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>validates existing schema against code. turn this on if you want to verify existing schema </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.storeManagerType</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>rdbms</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>metadata store type</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.autoCreateSchema</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>creates necessary schema on a startup if one doesn't exist. set this to false, after creating it once</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.autoStartMechanismMode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>checked</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>throw exception if metadata tables are incorrect</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.transactionIsolation</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>read-committed</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Default transaction isolation level for identity generation. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.cache.level2</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Use a level 2 cache. Turn this off if metadata is changed independently of Hive metastore server</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.cache.level2.type</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>SOFT</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>SOFT=soft reference based cache, WEAK=weak reference based cache.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.identifierFactory</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>datanucleus1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Name of the identifier factory to use when generating table/column names etc. 'datanucleus1' is used for backward compatibility with DataNucleus v1</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>datanucleus.plugin.pluginRegistryBundleCheck</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>LOG</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Defines what happens when plugin bundles are found and are duplicated [EXCEPTION|LOG|NONE]</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.warehouse.dir</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>/home/hive/warehouse</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>location of default database for the warehouse</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.execute.setugi</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>In unsecure mode, setting this property to true will cause the metastore to execute DFS operations using the client's reported user and group permissions. Note that this property must be set on both the client and server sides. Further note that its best effort. If client sets its to true and server sets it to false, client setting will be ignored.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.event.listeners</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>list of comma separated listeners for metastore events.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.partition.inherit.table.properties</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>list of comma separated keys occurring in table properties which will get inherited to newly created partitions. * implies all the keys will get inherited.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metadata.export.location</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When used in conjunction with the org.apache.hadoop.hive.ql.parse.MetaDataExportListener pre event listener, it is the location to which the metadata will be exported. The default is an empty string, which results in the metadata being exported to the current user's home directory on HDFS.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metadata.move.exported.metadata.to.trash</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When used in conjunction with the org.apache.hadoop.hive.ql.parse.MetaDataExportListener pre event listener, this setting determines if the metadata that is exported will subsequently be moved to the user's trash directory alongside the dropped table data. This ensures that the metadata will be cleaned up along with the dropped table data.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.partition.name.whitelist.pattern</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Partition names will be checked against this regex pattern and rejected if not matched.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.disallow.incompatible.col.type.change</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If true (default is false), ALTER TABLE operations which change the type of " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    a column (say STRING) to an incompatible type (say MAP&lt;STRING, STRING&gt;) are disallowed.  " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    RCFile default SerDe (ColumnarSerDe) serializes the values in such a way that the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    datatypes can be converted from string to any type. The map is also serialized as" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    a string, which can be read as a string as well. However, with any binary " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    serialization, this is not true. Blocking the ALTER TABLE prevents ClassCastExceptions" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    when subsequently trying to access old partitions. " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "      " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Primitive types like INT, STRING, BIGINT, etc are compatible with each other and are " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    not blocked.  " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    See HIVE-4409 for more details." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.end.function.listeners</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>list of comma separated listeners for the end of metastore functions.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.event.expiry.duration</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Duration after which events expire from events table (in seconds)</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.event.clean.freq</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Frequency at which timer task runs to purge expired events in metastore(in seconds).</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.connect.retries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of retries while opening a connection to metastore</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.failure.retries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>3</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of retries upon failure of Thrift metastore calls</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.client.connect.retry.delay</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of seconds for the client to wait between consecutive connection attempts</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.client.socket.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>600</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>MetaStore Client socket timeout in seconds</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.rawstore.impl</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.metastore.ObjectStore</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Name of the class that implements org.apache.hadoop.hive.metastore.rawstore interface. This class is used to store and retrieval of raw metadata objects such as table, database</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.batch.retrieve.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>300</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of objects (tables/partitions) can be retrieved from metastore in one batch. The higher the number, the less the number of round trips is needed to the Hive metastore server, but it may also cause higher memory requirement at the client side.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.batch.retrieve.table.partition.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of table partitions that metastore internally retrieves in one batch.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.default.fileformat</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>TextFile</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Default file format for CREATE TABLE statement. Options are TextFile and SequenceFile. Users can explicitly say CREATE TABLE ... STORED AS &lt;TEXTFILE|SEQUENCEFILE&gt; to override</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.default.rcfile.serde</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.serde2.columnar.LazyBinaryColumnarSerDe</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default SerDe Hive will use for the RCFile format</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.fileformat.check</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to check file format or not when loading data files</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.file.max.footer</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>maximum number of lines for footer user can define for a table file</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.map.aggr</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to use map-side aggregation in Hive Group By queries</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.groupby.skewindata</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether there is skew in data to optimize group by queries</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.multigroupby.common.distincts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to optimize a multi-groupby query with the same distinct." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Consider a query like:" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "      from src" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "        insert overwrite table dest1 select col1, count(distinct colx) group by col1" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "        insert overwrite table dest2 select col2, count(distinct colx) group by col2;" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    With this parameter set to true, first we spray by the distinct value (colx), and then" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    perform the 2 groups bys. This makes sense if map-side aggregation is turned off. However," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    with maps-side aggregation, it might be useful in some cases to treat the 2 inserts independently, " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    thereby performing the query above in 2MR jobs instead of 3 (due to spraying by distinct key first)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If this parameter is turned off, we don't consider the fact that the distinct key is the same across" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    different MR jobs." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.groupby.mapaggr.checkinterval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of rows after which size of the grouping keys/aggregation classes is performed</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapred.local.mem</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>For local mode, memory of the mappers/reducers</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapjoin.followby.map.aggr.hash.percentmemory</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.3</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Portion of total memory to be used by map-side group aggregation hash table, when this group by is followed by map join</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.map.aggr.hash.force.flush.memory.threshold</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.9</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The max memory to be used by map-side group aggregation hash table, if the memory usage is higher than this number, force to flush data</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.map.aggr.hash.percentmemory</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.5</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Portion of total memory to be used by map-side group aggregation hash table</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.session.history.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to log Hive query, query plan, runtime statistics etc.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.map.aggr.hash.min.reduction</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.5</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Hash aggregation will be turned off if the ratio between hash" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  table size and input rows is bigger than this number. Set to 1 to make sure" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  hash aggregation is never turned off.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.index.filter</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable automatic use of indexes</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.index.groupby</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable optimization of group-by queries using Aggregate indexes.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.ppd</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable predicate pushdown</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.ppd.storage</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to push predicates down into storage handlers.  Ignored when hive.optimize.ppd is false.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.ppd.recognizetransivity</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to transitively replicate predicate filters over equijoin conditions.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.groupby</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable the bucketed group by from bucketed partitions/tables.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.sort.dynamic.partition</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When enabled dynamic partitioning column will be globally sorted." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  This way we can keep only one record writer open for each partition value" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  in the reducer thereby reducing the memory pressure on reducers.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.skewjoin.compiletime</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to create a separate plan for skewed keys for the tables in the join." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This is based on the skewed keys stored in the metadata. At compile time, the plan is broken" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    into different joins: one for the skewed keys, and the other for the remaining keys. And then," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    a union is performed for the 2 joins generated above. So unless the same skewed key is present" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    in both the joined tables, the join for the skewed key will be performed as a map-side join." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The main difference between this parameter and hive.optimize.skewjoin is that this parameter" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    uses the skew information stored in the metastore to optimize the plan at compile time itself." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If there is no skew information in the metadata, this parameter will not have any affect." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Both hive.optimize.skewjoin.compiletime and hive.optimize.skewjoin should be set to true." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Ideally, hive.optimize.skewjoin should be renamed as hive.optimize.skewjoin.runtime, but not doing" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    so for backward compatibility." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If the skew information is correctly stored in the metadata, hive.optimize.skewjoin.compiletime" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    would change the query plan to take care of it, and hive.optimize.skewjoin will be a no-op." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.union.remove</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Whether to remove the union and push the operators between union and the filesink above" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    union. This avoids an extra scan of the output by union. This is independently useful for union" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    queries, and specially useful when hive.optimize.skewjoin.compiletime is set to true, since an" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    extra union is inserted." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The merge is triggered if either of hive.merge.mapfiles or hive.merge.mapredfiles is set to true." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If the user has set hive.merge.mapfiles to true and hive.merge.mapredfiles to false, the idea was the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    number of reducers are few, so the number of files anyway are small. However, with this optimization," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    we are increasing the number of files possibly by a big margin. So, we merge aggressively.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapred.supports.subdirectories</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether the version of Hadoop which is running supports sub-directories for tables/partitions." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Many Hive optimizations can be applied if the Hadoop version supports sub-directories for" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    tables/partitions. It was added by MAPREDUCE-1501</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.multigroupby.singlereducer</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to optimize multi group by query to generate single M/R" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  job plan. If the multi group by query has common group by keys, it will be" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  optimized to generate single M/R job.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.map.groupby.sorted</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If the bucketing/sorting properties of the table exactly match the grouping key, whether to" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    perform the group by in the mapper by using BucketizedHiveInputFormat. The only downside to this" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    is that it limits the number of mappers to the number of files." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.map.groupby.sorted.testmode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If the bucketing/sorting properties of the table exactly match the grouping key, whether to" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    perform the group by in the mapper by using BucketizedHiveInputFormat. If the test mode is set, the plan" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    is not converted, but a query property is set to denote the same." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.new.job.grouping.set.cardinality</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>30</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Whether a new map-reduce job should be launched for grouping sets/rollups/cubes." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    For a query like: select a, b, c, count(1) from T group by a, b, c with rollup;" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    4 rows are created per row: (a, b, c), (a, b, null), (a, null, null), (null, null, null)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This can lead to explosion across map-reduce boundary if the cardinality of T is very high," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and map-side aggregation does not do a very good job. " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This parameter decides if Hive should add an additional map-reduce job. If the grouping set" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    cardinality (4 in the example above), is more than this value, a new MR job is added under the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    assumption that the original group by will reduce the data size." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.join.emit.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>How many rows in the right-most join operand Hive should buffer before emitting the join result.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.join.cache.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>25000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>How many rows in the joining tables (except the streaming table) should be cached in memory. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.smbjoin.cache.rows</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>How many rows with the same key value should be cached in memory per SMB joined table.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.skewjoin</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable skew join optimization." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The algorithm is as follows: At runtime, detect the keys with a large skew. Instead of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    processing those keys, store them temporarily in an HDFS directory. In a follow-up map-reduce" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    job, process those skewed keys. The same key need not be skewed for all the tables, and so," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    the follow-up map-reduce job (for the skewed keys) would be much faster, since it would be a" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    map-join." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.skewjoin.key</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Determine if we get a skew key in join. If we see more" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	than the specified number of rows with the same key in join operator," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	we think the key as a skew join key. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.skewjoin.mapjoin.map.tasks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> Determine the number of map task used in the follow up map join job" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	for a skew join. It should be used together with hive.skewjoin.mapjoin.min.split" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	to perform a fine grained control.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.skewjoin.mapjoin.min.split</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>33554432</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> Determine the number of map task at most used in the follow up map join job" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	for a skew join by specifying the minimum split size. It should be used together with" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	hive.skewjoin.mapjoin.map.tasks to perform a fine grained control.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapred.mode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>nonstrict</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The mode in which the Hive operations are being performed." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     In strict mode, some risky queries are not allowed to run. They include:" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       Cartesian Product." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       No partition being picked up for a query." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       Comparing bigints and strings." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       Comparing bigints and doubles." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       Orderby without limit." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.enforce.bucketmapjoin</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If the user asked for bucketed map-side join, and it cannot be performed," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    should the query fail or not ? For example, if the buckets in the tables being joined are" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    not a multiple of each other, bucketed map-side join cannot be performed, and the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    query will fail if hive.enforce.bucketmapjoin is set to true." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.script.maxerrsize</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of bytes a script is allowed to emit to standard error (per map-reduce task). This prevents runaway scripts from filling logs partitions to capacity </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.script.allow.partial.consumption</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> When enabled, this option allows a user script to exit successfully without consuming all the data from the standard input." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.script.operator.id.env.var</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>HIVE_SCRIPT_OPERATOR_ID</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> Name of the environment variable that holds the unique script operator ID in the user's transform function (the custom mapper/reducer that the user has specified in the query)" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.script.operator.truncate.env</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Truncate each environment variable for external script in scripts operator to 20KB (to fit system limits)</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.compress.output</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> This controls whether the final outputs of a query (to a local/HDFS file or a Hive table) is compressed. The compression codec and other options are determined from Hadoop config variables mapred.output.compress* </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.compress.intermediate</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> This controls whether intermediate files produced by Hive between multiple map-reduce jobs are compressed. The compression codec and other options are determined from Hadoop config variables mapred.output.compress* </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.parallel</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to execute jobs in parallel</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.parallel.thread.number</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>8</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>How many jobs at most can be executed in parallel</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.rowoffset</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to provide the row offset virtual column</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.counters.group.name</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>HIVE</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The name of counter group for internal Hive variables (CREATED_FILE, FATAL_ERROR, etc.)</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.hwi.war.file</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>lib/hive-hwi-@VERSION@.war</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This sets the path to the HWI war file, relative to \${HIVE_HOME}. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.hwi.listen.host</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.0.0.0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This is the host address the Hive Web Interface will listen on</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.hwi.listen.port</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>9999</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This is the port the Hive Web Interface will listen on</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.pre.hooks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma-separated list of pre-execution hooks to be invoked for each statement.  A pre-execution hook is specified as the name of a Java class which implements the org.apache.hadoop.hive.ql.hooks.ExecuteWithHookContext interface.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.post.hooks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma-separated list of post-execution hooks to be invoked for each statement.  A post-execution hook is specified as the name of a Java class which implements the org.apache.hadoop.hive.ql.hooks.ExecuteWithHookContext interface.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.failure.hooks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma-separated list of on-failure hooks to be invoked for each statement.  An on-failure hook is specified as the name of Java class which implements the org.apache.hadoop.hive.ql.hooks.ExecuteWithHookContext interface.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.init.hooks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>A comma separated list of hooks to be invoked at the beginning of HMSHandler initialization. An init hook is specified as the name of Java class which extends org.apache.hadoop.hive.metastore.MetaStoreInitListener.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.client.stats.publishers</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma-separated list of statistics publishers to be invoked on counters on each job.  A client stats publisher is specified as the name of a Java class which implements the org.apache.hadoop.hive.ql.stats.ClientStatsPublisher interface.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.client.stats.counters</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Subset of counters that should be of interest for hive.client.stats.publishers (when one wants to limit their publishing). Non-display names should be used</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.merge.mapfiles</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Merge small files at the end of a map-only job</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.merge.mapredfiles</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Merge small files at the end of a map-reduce job</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.merge.tezfiles</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Merge small files at the end of a Tez DAG</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.heartbeat.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Send a heartbeat after this interval - used by mapjoin and filter operators</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.merge.size.per.task</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>256000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Size of merged files at the end of the job</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.merge.smallfiles.avgsize</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>16000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When the average output file size of a job is less than this number, Hive will start an additional map-reduce job to merge the output files into bigger files.  This is only done for map-only jobs if hive.merge.mapfiles is true, and for map-reduce jobs if hive.merge.mapredfiles is true.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapjoin.smalltable.filesize</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>25000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The threshold for the input file size of the small tables; if the file size is smaller than this threshold, it will try to convert the common join into map join</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.ignore.mapjoin.hint</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Ignore the mapjoin hint</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapjoin.localtask.max.memory.usage</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.90</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This number means how much memory the local task can take to hold the key/value into an in-memory hash table. If the local task's memory usage is more than this number, the local task will abort by itself. It means the data of the small table is too large to be held in memory.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapjoin.followby.gby.localtask.max.memory.usage</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.55</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This number means how much memory the local task can take to hold the key/value into an in-memory hash table when this map join is followed by a group by. If the local task's memory usage is more than this number, the local task will abort by itself. It means the data of the small table is too large to be held in memory.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapjoin.check.memory.rows</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The number means after how many rows processed it needs to check the memory usage</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.join</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether Hive enables the optimization about converting common join into mapjoin based on the input file size</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.join.noconditionaltask</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether Hive enables the optimization about converting common join into mapjoin based on the input file " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    size. If this parameter is on, and the sum of size for n-1 of the tables/partitions for a n-way join is smaller than the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    specified size, the join is directly converted to a mapjoin (there is no conditional task)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.join.noconditionaltask.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If hive.auto.convert.join.noconditionaltask is off, this parameter does not take affect. However, if it" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    is on, and the sum of size for n-1 of the tables/partitions for a n-way join is smaller than this size, the join is directly" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    converted to a mapjoin(there is no conditional task). The default is 10MB" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.join.use.nonstaged</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>For conditional joins, if input stream from a small alias can be directly applied to join operator without" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    filtering or projection, the alias need not to be pre-staged in distributed cache via mapred local task." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Currently, this is not working with vectorization or tez execution engine." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.script.auto.progress</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether Hive Transform/Map/Reduce Clause should automatically send progress information to TaskTracker to avoid the task getting killed because of inactivity.  Hive sends progress information when the script is outputting to stderr.  This option removes the need of periodically producing stderr messages, but users should be cautious because this may prevent infinite loops in the scripts to be killed by TaskTracker. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.script.serde</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default SerDe for transmitting input data to and reading output data from the user scripts. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.binary.record.max.length</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Read from a binary stream and treat each hive.binary.record.max.length bytes as a record." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The last record before the end of stream can have less than hive.binary.record.max.length bytes</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.max.start.attempts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>30</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This number of times HiveServer2 will attempt to start before exiting, sleeping 60 seconds between retries. The default of 30 will keep trying for 30 minutes.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.transport.mode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>binary</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Server transport mode. \"binary\" or \"http\".</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.http.port</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10001</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Port number when in HTTP mode.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property> " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.http.path</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>cliservice</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Path component of URL endpoint when in HTTP mode.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property> " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.http.min.worker.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Minimum number of worker threads when in HTTP mode.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property> " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.http.max.worker.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>500</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of worker threads when in HTTP mode.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property> " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.script.recordreader</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.exec.TextRecordReader</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default record reader for reading data from the user scripts. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>stream.stderr.reporter.prefix</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>reporter:</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Streaming jobs that log to standard error with this prefix can log counter or status information.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>stream.stderr.reporter.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Enable consumption of status and counter messages for streaming jobs.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.script.recordwriter</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.exec.TextRecordWriter</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default record writer for writing data to the user scripts. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.input.format</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.io.CombineHiveInputFormat</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default input format. Set this to HiveInputFormat if you encounter problems with CombineHiveInputFormat.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.tez.input.format</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.io.HiveInputFormat</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default input format for tez. Tez groups splits in the AM.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.udtf.auto.progress</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether Hive should automatically send progress information to TaskTracker when using UDTF's to prevent the task getting killed because of inactivity.  Users should be cautious because this may prevent TaskTracker from killing tasks with infinite loops.  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.mapred.reduce.tasks.speculative.execution</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether speculative execution for reducers should be turned on. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.counters.pull.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The interval with which to poll the JobTracker for the counters the running job. The smaller it is the more load there will be on the jobtracker, the higher it is the less granular the caught will be.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.querylog.location</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>/tmp/\${user.name}</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Location of Hive run time structured log file" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.querylog.enable.plan.progress</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Whether to log the plan's progress every time a job's progress is checked." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    These logs are written to the location specified by hive.querylog.location" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.querylog.plan.progress.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>60000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The interval to wait between logging the plan's progress in milliseconds." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If there is a whole number percentage change in the progress of the mappers or the reducers," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    the progress is logged regardless of this value." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The actual interval will be the ceiling of (this value divided by the value of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    hive.exec.counters.pull.interval) multiplied by the value of hive.exec.counters.pull.interval" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    I.e. if it is not divide evenly by the value of hive.exec.counters.pull.interval it will be" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    logged less frequently than specified." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This only has an effect if hive.querylog.enable.plan.progress is set to true." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.enforce.bucketing</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether bucketing is enforced. If true, while inserting into the table, bucketing is enforced. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.enforce.sorting</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether sorting is enforced. If true, while inserting into the table, sorting is enforced. </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.bucketingsorting</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If hive.enforce.bucketing or hive.enforce.sorting is true, don't create a reducer for enforcing" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    bucketing/sorting for queries of the form: " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    insert overwrite table T2 select * from T1;" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    where T1 and T2 are bucketed/sorted by the same keys into the same number of buckets." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.enforce.sortmergebucketmapjoin</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If the user asked for sort-merge bucketed map-side join, and it cannot be performed," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    should the query fail or not ?" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.sortmerge.join</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Will the join be automatically converted to a sort-merge join, if the joined tables pass" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    the criteria for sort-merge join." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.sortmerge.join.bigtable.selection.policy</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.optimizer.AvgPartitionSizeBasedBigTableSelectorForAutoSMJ</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The policy to choose the big table for automatic conversion to sort-merge join." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    By default, the table with the largest partitions is assigned the big table. All policies are:" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    . based on position of the table - the leftmost table is selected" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    org.apache.hadoop.hive.ql.optimizer.LeftmostBigTableSMJ." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    . based on total size (all the partitions selected in the query) of the table " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    org.apache.hadoop.hive.ql.optimizer.TableSizeBasedBigTableSelectorForAutoSMJ." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    . based on average size (all the partitions selected in the query) of the table " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    org.apache.hadoop.hive.ql.optimizer.AvgPartitionSizeBasedBigTableSelectorForAutoSMJ." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    New policies can be added in future." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.convert.sortmerge.join.to.mapjoin</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If hive.auto.convert.sortmerge.join is set to true, and a join was converted to a sort-merge join," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    this parameter decides whether each table should be tried as a big table, and effectively a map-join should be" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    tried. That would create a conditional task with n+1 children for a n-way join (1 child for each table as the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    big table), and the backup task will be the sort-merge join. In some cases, a map-join would be faster than a" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    sort-merge join, if there is no advantage of having the output bucketed and sorted. For example, if a very big sorted" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and bucketed table with few files (say 10 files) are being joined with a very small sorter and bucketed table" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    with few files (10 files), the sort-merge join will only use 10 mappers, and a simple map-only join might be faster" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    if the complete small table can fit in memory, and a map-join can be performed." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.ds.connection.url.hook</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Name of the hook to use for retrieving the JDO connection URL. If empty, the value in javax.jdo.option.ConnectionURL is used </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.hmshandler.retry.attempts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The number of times to retry a metastore call if there were a connection error</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <name>hive.hmshandler.retry.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <description>The number of milliseconds between metastore retry attempts</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.server.min.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>200</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Minimum number of worker threads in the Thrift server's pool.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.server.max.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of worker threads in the Thrift server's pool.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.server.tcp.keepalive</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable TCP keepalive for the metastore server. Keepalive will prevent accumulation of half-open connections.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.sasl.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If true, the metastore Thrift interface will be secured with SASL. Clients must authenticate with Kerberos.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.thrift.framed.transport.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If true, the metastore Thrift interface will use TFramedTransport. When false (default) a standard TTransport is used.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.kerberos.keytab.file</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The path to the Kerberos Keytab file containing the metastore Thrift server's service principal.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.kerberos.principal</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hive-metastore/_HOST@EXAMPLE.COM</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The service principal for the metastore Thrift server. The special string _HOST will be replaced automatically with the correct host name.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cluster.delegation.token.store.class</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.thrift.MemoryTokenStore</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The delegation token store implementation. Set to org.apache.hadoop.hive.thrift.ZooKeeperTokenStore for load-balanced cluster.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cluster.delegation.token.store.zookeeper.connectString</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>$INSTALL_HIVE_IP:2181</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The ZooKeeper token store connect string.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cluster.delegation.token.store.zookeeper.znode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>/hive/cluster/delegation</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The root path for token store data.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cluster.delegation.token.store.zookeeper.acl</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>sasl:hive/host1@EXAMPLE.COM:cdrwa,sasl:hive/host2@EXAMPLE.COM:cdrwa</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>ACL for token store entries. List comma separated all server principals for the cluster.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.cache.pinobjtypes</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>Table,StorageDescriptor,SerDeInfo,Partition,Database,Type,FieldSchema,Order</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>List of comma separated metastore object types that should be pinned in the cache</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.reducededuplication</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Remove extra map-reduce jobs if the data is already clustered by the same key which needs to be used again. This should always be set to true. Since it is a new feature, it has been made configurable.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.correlation</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>exploit intra-query correlations.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.reducededuplication.min.reducer</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>4</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Reduce deduplication merges two RSs by moving key/parts/reducer-num of the child RS to parent RS." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  That means if reducer-num of the child RS is fixed (order by or forced bucketing) and small, it can make very slow, single MR." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The optimization will be disabled if number of reducers is less than specified value.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.dynamic.partition</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether or not to allow dynamic partitions in DML/DDL.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.dynamic.partition.mode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>strict</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>In strict mode, the user must specify at least one static partition in case the user accidentally overwrites all partitions.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.max.dynamic.partitions</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>2048</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of dynamic partitions allowed to be created in total.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.max.dynamic.partitions.pernode</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>256</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of dynamic partitions allowed to be created in each mapper/reducer node.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.max.created.files</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of HDFS files created by all mappers/reducers in a MapReduce job.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.default.partition.name</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>__HIVE_DEFAULT_PARTITION__</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default partition name in case the dynamic partition column value is null/empty string or any other values that cannot be escaped. This value must not contain any special character used in HDFS URI (e.g., ':', '%', '/' etc). The user has to be aware that the dynamic partition value should not contain this value to avoid confusions.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.dbclass</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>fs</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The storage that stores temporary Hive statistics. Supported values are" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  fs (filesystem), jdbc(:.*), hbase, counter, and custom. In FS based statistics collection," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  each task writes statistics it has collected in a file on the filesystem, which will be" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  aggregated after the job has finished.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.autogather</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>A flag to gather statistics automatically during the INSERT OVERWRITE command.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.jdbcdriver</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.derby.jdbc.EmbeddedDriver</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The JDBC driver for the database that stores temporary Hive statistics.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.dbconnectionstring</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>jdbc:derby:;databaseName=TempStatsStore;create=true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The default connection string for the database that stores temporary Hive statistics.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.default.publisher</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The Java class (implementing the StatsPublisher interface) that is used by default if hive.stats.dbclass is custom type.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.default.aggregator</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The Java class (implementing the StatsAggregator interface) that is used by default if hive.stats.dbclass is custom type.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.jdbc.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>600</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Timeout value (number of seconds) used by JDBC connection and statements.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.retries.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of retries when stats publisher/aggregator got an exception updating intermediate database. Default is no tries on failures.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.retries.wait</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>3000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The base waiting window (in milliseconds) before the next retry. The actual wait time is calculated by baseWindow * failures  baseWindow * (failure  1) * (random number between [0.0,1.0]).</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.reliable</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether queries will fail because stats cannot be collected completely accurately." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If this is set to true, reading/writing from/into a partition may fail because the stats" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    could not be computed accurately." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.collect.tablekeys</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether join and group by keys on tables are derived and maintained in the QueryPlan." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This is useful to identify how tables are accessed and to determine if they should be bucketed." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.collect.scancols</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether column accesses are tracked in the QueryPlan." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This is useful to identify how tables are accessed and to determine if there are wasted columns that can be trimmed." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.ndv.error</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>20.0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Standard error expressed in percentage. Provides a tradeoff between accuracy and compute cost.A lower value for error indicates higher accuracy and a higher compute cost." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.key.prefix.max.length</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>200</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Determines if when the prefix of the key used for intermediate stats collection" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    exceeds a certain length, a hash of the key is used instead.  If the value &lt; 0 then hashing" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    is never used, if the value >= 0 then hashing is used only when the key prefixes length" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    exceeds that value.  The key prefix is defined as everything preceding the task ID in the key." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    For counter type stats, it's maxed by mapreduce.job.counters.group.name.max, which is by default 128." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.key.prefix.reserve.length</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>24</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Reserved length for postfix of stats key. Currently only meaningful for counter type which should" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    keep length of full stats key smaller than max length configured by hive.stats.key.prefix.max.length." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    For counter type, it should be bigger than the length of LB spec if exists." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.max.variable.length</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    To estimate the size of data flowing through operators in Hive/Tez(for reducer estimation etc.)," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    average row size is multiplied with the total number of rows coming out of each operator." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Average row size is computed from average column size of all columns in the row. In the absence" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of column statistics, for variable length columns (like string, bytes etc.), this value will be" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    used. For fixed length columns their corresponding Java equivalent sizes are used" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    (float - 4 bytes, double - 8 bytes etc.)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.list.num.entries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    To estimate the size of data flowing through operators in Hive/Tez(for reducer estimation etc.)," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    average row size is multiplied with the total number of rows coming out of each operator." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Average row size is computed from average column size of all columns in the row. In the absence" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of column statistics and for variable length complex columns like list, the average number of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    entries/values can be specified using this config." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.map.num.entries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    To estimate the size of data flowing through operators in Hive/Tez(for reducer estimation etc.)," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    average row size is multiplied with the total number of rows coming out of each operator." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Average row size is computed from average column size of all columns in the row. In the absence" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of column statistics and for variable length complex columns like map, the average number of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    entries/values can be specified using this config." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <name>hive.stats.map.parallelism</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <value>1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "    Hive/Tez optimizer estimates the data size flowing through each of the operators." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "    For GROUPBY operator, to accurately compute the data size map-side parallelism needs to" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "    be known. By default, this value is set to 1 since optimizer is not aware of the number of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "    mappers during compile-time. This Hive config can be used to specify the number of mappers" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "    to be used for data size computation of GROUPBY operator." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.fetch.column.stats</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Annotation of operator tree with statistics information requires column statisitcs." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Column statistics are fetched from metastore. Fetching column statistics for each needed column" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    can be expensive when the number of columns is high. This flag can be used to disable fetching" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of column statistics from metastore." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.fetch.partition.stats</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Annotation of operator tree with statistics information requires partition level basic" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    statisitcs like number of rows, data size and file size. Partition statistics are fetched from" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    metastore. Fetching partition statistics for each needed partition can be expensive when the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    number of partitions is high. This flag can be used to disable fetching of partition statistics" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    from metastore. When this flag is disabled, Hive will make calls to filesystem to get file sizes" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and will estimate the number of rows from row schema." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.join.factor</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1.1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Hive/Tez optimizer estimates the data size flowing through each of the operators. JOIN operator" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    uses column statistics to estimate the number of rows flowing out of it and hence the data size." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    In the absence of column statistics, this factor determines the amount of rows that flows out" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of JOIN operator." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.deserialization.factor</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1.0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Hive/Tez optimizer estimates the data size flowing through each of the operators. In the absence" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of basic statistics like number of rows and data size, file size is used to estimate the number" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    of rows and data size. Since files in tables/partitions are serialized (and optionally" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    compressed) the estimates of number of rows and data size cannot be reliably determined." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This factor is multiplied with the file size to account for serialization and compression." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.support.concurrency</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether Hive supports concurrency or not. A ZooKeeper instance must be up and running for the default Hive lock manager to support read-write locks.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.lock.numretries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The number of times you want to try to get all the locks</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.unlock.numretries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The number of times you want to retry to do one unlock</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.lock.sleep.between.retries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>60</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The sleep time (in seconds) between various retries</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.zookeeper.quorum</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The list of ZooKeeper servers to talk to. This is only needed for read/write locks.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.zookeeper.client.port</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>2181</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The port of ZooKeeper servers to talk to. This is only needed for read/write locks.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.zookeeper.session.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>600000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>ZooKeeper client's session timeout. The client is disconnected, and as a result, all locks released, if a heartbeat is not sent in the timeout.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.zookeeper.namespace</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hive_zookeeper_namespace</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The parent node under which all ZooKeeper nodes are created.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.zookeeper.clean.extra.nodes</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Clean extra nodes at the end of the session.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>fs.har.impl</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.shims.HiveHarFileSystem</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The implementation for accessing Hadoop Archives. Note that this won't be applicable to Hadoop versions less than 0.20</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.archive.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether archiving operations are permitted</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.fetch.output.serde</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.serde2.DelimitedJSONSerDe</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The SerDe used by FetchTask to serialize the fetch output.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.mode.local.auto</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description> Let Hive determine whether to run in local mode automatically </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.drop.ignorenonexistent</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Do not report an error if DROP TABLE/VIEW specifies a non-existent table/view" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.show.job.failure.debug.info</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  	If a job fails, whether to provide a link in the CLI to the task with the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  	most failures, along with debugging hints if applicable." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.auto.progress.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    How long to run autoprogressor for the script/UDTF operators (in seconds)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Set to 0 for forever." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<!-- HBase Storage Handler Parameters -->" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.hbase.wal.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether writes to HBase should be forced to the write-ahead log.  Disabling this improves HBase write performance at the risk of lost writes in case of a crash.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.table.parameters.default</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Default property values for newly created tables</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.entity.separator</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>@</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Separator used to construct names of tables and partitions. For example, dbname@tablename@partitionname</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.ddl.createtablelike.properties.whitelist</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Table Properties to copy over when executing a Create Table Like.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.variable.substitute</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This enables substitution using syntax like \${var} \${system:var} and \${env:var}.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.variable.substitute.depth</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>40</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The maximum replacements the substitution engine will do.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.conf.validation</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Enables type checking for registered Hive configurations</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authorization.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>enable or disable the Hive client authorization</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authorization.manager</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.security.authorization.DefaultHiveAuthorizationProvider</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The Hive client authorization manager class name." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The user defined authorization class should implement interface org.apache.hadoop.hive.ql.security.authorization.HiveAuthorizationProvider." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.metastore.authorization.manager</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.security.authorization.DefaultHiveMetastoreAuthorizationProvider</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>authorization manager class name to be used in the metastore for authorization." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The user defined authorization class should implement interface org.apache.hadoop.hive.ql.security.authorization.HiveMetastoreAuthorizationProvider. " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authenticator.manager</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.security.HadoopDefaultAuthenticator</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>hive client authenticator manager class name." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The user defined authenticator should implement interface org.apache.hadoop.hive.ql.security.HiveAuthenticationProvider.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.metastore.authenticator.manager</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.security.HadoopDefaultMetastoreAuthenticator</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>authenticator manager class name to be used in the metastore for authentication. " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The user defined authenticator should implement interface org.apache.hadoop.hive.ql.security.HiveAuthenticationProvider.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authorization.createtable.user.grants</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>the privileges automatically granted to some users whenever a table gets created." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   An example like \"userX,userY:select;userZ:create\" will grant select privilege to userX and userY," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   and grant create privilege to userZ whenever a new table created.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authorization.createtable.group.grants</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>the privileges automatically granted to some groups whenever a table gets created." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   An example like \"groupX,groupY:select;groupZ:create\" will grant select privilege to groupX and groupY," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   and grant create privilege to groupZ whenever a new table created.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authorization.createtable.role.grants</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>the privileges automatically granted to some roles whenever a table gets created." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   An example like \"roleX,roleY:select;roleZ:create\" will grant select privilege to roleX and roleY," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   and grant create privilege to roleZ whenever a new table created.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.authorization.createtable.owner.grants</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>ALL</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>the privileges automatically granted to the owner whenever a table gets created." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   An example like \"select,drop\" will grant select and drop privilege to the owner of the table</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.users.in.admin.role</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma separated list of users who are in admin role for bootstrapping." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    More users can be added in ADMIN role later.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.security.command.whitelist</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>set,reset,dfs,add,delete</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma separated list of non-SQL Hive commands users are authorized to execute</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.conf.restricted.list</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hive.security.authenticator.manager,hive.security.authorization.manager</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Comma separated list of configuration options which are immutable at runtime</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.authorization.storage.checks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Should the metastore do authorization checks against the underlying storage" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  for operations like drop-partition (disallow the drop-partition if the user in" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  question doesn't have permissions to delete the corresponding directory" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  on the storage).</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.error.on.empty.partition</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to throw an exception if dynamic partition insert generates empty results.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.index.compact.file.ignore.hdfs</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When true the HDFS location stored in the index file will be ignored at runtime." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  If the data got moved or the name of the cluster got changed, the index data should still be usable.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.index.filter.compact.minsize</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5368709120</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Minimum size (in bytes) of the inputs on which a compact index is automatically used.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.optimize.index.filter.compact.maxsize</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>-1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum size (in bytes) of the inputs on which a compact index is automatically used." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  A negative number is equivalent to infinity.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.index.compact.query.max.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10737418240</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The maximum number of bytes that a query using the compact index can read. Negative value is equivalent to infinity.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.index.compact.query.max.entries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The maximum number of index entries to read during a query that uses the compact index. Negative value is equivalent to infinity.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.index.compact.binary.search</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether or not to use a binary search to find the entries in an index table that match the filter, where possible</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exim.uri.scheme.whitelist</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hdfs,pfile</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>A comma separated list of acceptable URI schemes for import and export.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.lock.mapred.only.operation</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This param is to control whether or not only do lock on queries" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  that need to execute at least one mapred job.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.limit.row.max.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When trying a smaller subset of data for simple LIMIT, how much size we need to guarantee" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   each row to have at least.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.limit.optimize.limit.file</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>When trying a smaller subset of data for simple LIMIT, maximum number of files we can" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   sample.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.limit.optimize.enable</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable to optimization to trying a smaller subset of data for simple LIMIT first.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.limit.optimize.fetch.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>50000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of rows allowed for a smaller subset of data for simple LIMIT, if it is a fetch query." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   Insert queries are not restricted by this limit.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.limit.pushdown.memory.usage</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.3f</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The max memory to be used for hash in RS operator for top K selection.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.rework.mapredwork</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>should rework the mapred work or not." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  This is first introduced by SymlinkTextInputFormat to replace symlink files with real paths at compile time.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.concatenate.check.index</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If this is set to true, Hive will throw error when doing" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   'alter table tbl_name [partSpec] concatenate' on a table/partition" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    that has indexes on it. The reason the user want to set this to true" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    is because it can help user to avoid handling all index drop, recreation," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    rebuild work. This is very helpful for tables with thousands of partitions.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.sample.seednumber</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>A number used to percentage sampling. By changing this number, user will change the subsets" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   of data sampled.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	<name>hive.io.exception.handlers</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	<value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "	<description>A list of io exception handler class names. This is used" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "		to construct a list exception handlers to handle exceptions thrown" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "		by record readers</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.autogen.columnalias.prefix.label</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>_c</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>String used as a prefix when auto generating column alias." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  By default the prefix label will be appended with a column position number to form the column alias. Auto generation would happen if an aggregate function is used in a select clause without an explicit alias.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.autogen.columnalias.prefix.includefuncname</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to include function name in the column alias auto generated by Hive.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.perf.logger</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.log.PerfLogger</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The class responsible logging client side performance metrics.  Must be a subclass of org.apache.hadoop.hive.ql.log.PerfLogger</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.start.cleanup.scratchdir</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>To cleanup the Hive scratchdir while starting the Hive Server</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.output.file.extension</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>String used as a file extension for output files. If not set, defaults to the codec extension for text files (e.g. \".gz\"), or no extension otherwise.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.insert.into.multilevel.dirs</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Where to insert into multilevel directories like" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  \"insert directory '/HIVEFT25686/chinna/' from table\"</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.warehouse.subdir.inherit.perms</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Set this to true if the the table directories should inherit the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    permission of the warehouse or database directory instead of being created" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    with the permissions derived from dfs umask</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.job.debug.capture.stacktraces</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether or not stack traces parsed from the task logs of a sampled failed task for" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  			   each failed job should be stored in the SessionState" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.driver.run.hooks</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>A comma separated list of hooks which implement HiveDriverRunHook" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and will be run at the beginning and end of Driver.run, these will be run in" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    the order specified." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.ddl.output.format</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>text</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The data format to use for DDL output.  One of \"text\" (for human" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    readable text) or \"json\" (for a json object)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.display.partition.cols.separately</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    In older Hive version (0.10 and earlier) no distinction was made between" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    partition columns or non-partition columns while displaying columns in describe" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    table. From 0.12 onwards, they are displayed separately. This flag will let you" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    get old behavior, if desired. See, test-case in patch for HIVE-6689." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.transform.escape.input</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This adds an option to escape special chars (newlines, carriage returns and" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    tabs) when they are passed to the user script. This is useful if the Hive tables" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    can contain data that contains special characters." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.rcfile.use.explicit.header</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If this is set the header for RCFiles will simply be RCF.  If this is not" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    set the header will be that borrowed from sequence files, e.g. SEQ- followed" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    by the input and output RCFile formats." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.default.stripe.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>268435456</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Define the default ORC stripe size." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.default.row.index.stride</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Define the default ORC index stride in number of rows." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.default.buffer.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>262144</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Define the default ORC buffer size in bytes." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.default.block.padding</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Define the default block padding." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.default.compress</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>ZLIB</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Define the default compression codec for ORC file." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.dictionary.key.size.threshold</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.8</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If the number of keys in a dictionary is greater than this fraction of the total number of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    non-null rows, turn off dictionary encoding.  Use 1 to always use dictionary encoding." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.skip.corrupt.data</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>If ORC reader encounters corrupt data, this value will be used to determine" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  whether to skip the corrupt data or throw exception. The default behavior is to throw exception." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.multi.insert.move.tasks.share.dependencies</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If this is set all move tasks for tables/partitions (not directories) at the end of a" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    multi-insert query will only begin once the dependencies for all these move tasks have been" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    met." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Advantages: If concurrency is enabled, the locks will only be released once the query has" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                finished, so with this config enabled, the time when the table/partition is" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                generated will be much closer to when the lock on it is released." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Disadvantages: If concurrency is not enabled, with this disabled, the tables/partitions which" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                   are produced by this query and finish earlier will be available for querying" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                   much earlier.  Since the locks are only released once the query finishes, this" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                   does not apply if concurrency is enabled." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.fetch.task.conversion</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>minimal</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Some select queries can be converted to single FETCH task minimizing latency." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Currently the query should be single sourced not having any subquery and should not have" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    any aggregations or distincts (which incurs RS), lateral views and joins." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    1. minimal : SELECT STAR, FILTER on partition columns, LIMIT only" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    2. more    : SELECT, FILTER, LIMIT only (TABLESAMPLE, virtual columns)" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.fetch.task.conversion.threshold</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>-1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Input threshold for applying hive.fetch.task.conversion. If target table is native, input length" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    is calculated by summation of file lengths. If it's not native, storage handler for the table" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    can optionally implement org.apache.hadoop.hive.ql.metadata.InputEstimator interface." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.fetch.task.aggr</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Aggregation queries with no group-by clause (for example, select count(*) from src) execute" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    final aggregations in single reduce task. If this is set true, Hive delegates final aggregation" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    stage to fetch task, possibly decreasing the query time." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.cache.expr.evaluation</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If true, evaluation result of deterministic expression referenced twice or more will be cached." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    For example, in filter condition like \".. where key + 10 > 10 or key + 10 = 0\"" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    \"key + 10\" will be evaluated/cached once and reused for following expression (\"key + 10 = 0\")." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Currently, this is applied only to expressions in select or filter operator." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.hmshandler.retry.attempts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>The number of times to retry a HMSHandler call if there were a connection error</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <name>hive.hmshandler.retry.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <description>The number of milliseconds between HMSHandler retry attempts</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <name>hive.server.read.socket.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <description>Timeout for the HiveServer to close the connection if no response from the client in N seconds, defaults to 10 seconds.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <name>hive.server.tcp.keepalive</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <description>Whether to enable TCP keepalive for the Hive Server. Keepalive will prevent accumulation of half-open connections.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <name>hive.decode.partition.name</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <description>Whether to show the unquoted partition names in query results.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.log4j.file</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Hive log4j configuration file." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  If the property is not set, then logging will be initialized using hive-log4j.properties found on the classpath." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  If the property is set, the value must be a valid URI (java.net.URI, e.g. \"file:///tmp/my-logging.properties\"), which you can then extract a URL from and pass to PropertyConfigurator.configure(URL).</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.log4j.file</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Hive log4j configuration file for execution mode(sub command)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  If the property is not set, then logging will be initialized using hive-exec-log4j.properties found on the classpath." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  If the property is set, the value must be a valid URI (java.net.URI, e.g. \"file:///tmp/my-logging.properties\"), which you can then extract a URL from and pass to PropertyConfigurator.configure(URL).</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.infer.bucket.sort</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If this is set, when writing partitions, the metadata will include the bucketing/sorting" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    properties with which the data was written if any (this will not overwrite the metadata" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    inherited from the table if the table is bucketed/sorted)" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.infer.bucket.sort.num.buckets.power.two</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If this is set, when setting the number of reducers for the map reduce task which writes the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    final output files, it will choose a number which is a power of two, unless the user specifies" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    the number of reducers to use using mapred.reduce.tasks.  The number of reducers" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    may be set to a power of two, only to be followed by a merge task meaning preventing" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    anything from being inferred." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    With hive.exec.infer.bucket.sort set to true:" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Advantages:  If this is not set, the number of buckets for partitions will seem arbitrary," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                 which means that the number of mappers used for optimized joins, for example, will" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                 be very low.  With this set, since the number of buckets used for any partition is" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                 a power of two, the number of mappers used for optimized joins will be the least" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                 number of buckets used by any partition being joined." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Disadvantages: This may mean a much larger or much smaller number of reducers being used in the" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                   final map reduce job, e.g. if a job was originally going to take 257 reducers," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                   it will now take 512 reducers, similarly if the max number of reducers is 511," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                   and a job was going to use this many, it will now use 256 reducers." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "                 " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.groupby.orderby.position.alias</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to enable using Column Position Alias in Group By or Order By</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " <property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.min.worker.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Minimum number of Thrift worker threads</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.max.worker.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>500</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of Thrift worker threads</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.async.exec.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of threads in the async thread pool for HiveServer2</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.async.exec.shutdown.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Time (in seconds) for which HiveServer2 shutdown will wait for async" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  threads to terminate</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.async.exec.keepalive.time</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Time (in seconds) that an idle HiveServer2 async thread (from the thread pool) will wait" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  for a new task to arrive before terminating</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.long.polling.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5000L</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Time in milliseconds that HiveServer2 will wait, before responding to asynchronous calls that use long polling</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.async.exec.wait.queue.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Size of the wait queue for async thread pool in HiveServer2." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  After hitting this limit, the async thread pool will reject new requests.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.port</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Port number of HiveServer2 Thrift interface." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Can be overridden by setting \$HIVE_SERVER2_THRIFT_PORT</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.bind.host</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>$INSTALL_HIVE_IP</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Bind host on which to run the HiveServer2 Thrift interface." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Can be overridden by setting \$HIVE_SERVER2_THRIFT_BIND_HOST</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>NONE</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Client authentication types." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       NONE: no authentication check" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       LDAP: LDAP/AD based authentication" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       KERBEROS: Kerberos/GSSAPI authentication" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       CUSTOM: Custom authentication provider" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "               (Use with property hive.server2.custom.authentication.class)" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "       PAM: Pluggable authentication module." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.custom.authentication.class</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Custom authentication class. Used when property" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    'hive.server2.authentication' is set to 'CUSTOM'. Provided class" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    must be a proper implementation of the interface" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    org.apache.hive.service.auth.PasswdAuthenticationProvider. HiveServer2" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    will call its Authenticate(user, passed) method to authenticate requests." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The implementation may optionally extend Hadoop's" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    org.apache.hadoop.conf.Configured class to grab Hive's Configuration object." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.kerberos.principal</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Kerberos server principal" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.kerberos.keytab</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Kerberos keytab file for server principal" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.spnego.principal</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    SPNego service principal, optional," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    typical value would look like HTTP/_HOST@EXAMPLE.COM" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    SPNego service principal would be used by hiveserver2 when kerberos security is enabled" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and HTTP transport mode is used." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This needs to be set only if SPNEGO is to be used in authentication." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.spnego.keytab</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    keytab file for SPNego principal, optional," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    typical value would look like /etc/security/keytabs/spnego.service.keytab," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This keytab would be used by hiveserver2 when kerberos security is enabled" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and HTTP transport mode is used." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This needs to be set only if SPNEGO is to be used in authentication." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    SPNego authentication would be honored only if valid" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    hive.server2.authentication.spnego.principal" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    hive.server2.authentication.spnego.keytab" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    are specified." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.ldap.url</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    LDAP connection URL." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.ldap.baseDN</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    LDAP base DN (distinguished name)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.ldap.Domain</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    LDAP domain." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.enable.doAs</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   Setting this property to true will have HiveServer2 execute" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Hive operations as the user making the calls to it." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.execution.engine</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>mr</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Chooses execution engine. Options are mr (MapReduce, default) or Tez (Hadoop 2 only)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.prewarm.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Enables container prewarm for Tez (Hadoop 2 only)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.prewarm.numcontainers</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Controls the number of containers to prewarm for Tez (Hadoop 2 only)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.table.type.mapping</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>CLASSIC</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   This setting reflects how HiveServer2 will report the table types for JDBC and other" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   client implementations that retrieve the available tables and supported table types" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     HIVE : Exposes Hive's native table types like MANAGED_TABLE, EXTERNAL_TABLE, VIRTUAL_VIEW" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     CLASSIC : More generic types like TABLE and VIEW" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.session.hook</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Session-level hook for HiveServer2." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.thrift.sasl.qop</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>auth</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Sasl QOP value; set it to one of the following values to enable higher levels of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     protection for HiveServer2 communication with clients." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "      \"auth\" - authentication only (default)" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "      \"auth-int\" - authentication plus integrity protection" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "      \"auth-conf\" - authentication plus integrity and confidentiality protection" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     Note that hadoop.rpc.protection being set to a higher level than HiveServer2 does not" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     make sense in most situations. HiveServer2 ignores hadoop.rpc.protection in favor of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     hive.server2.thrift.sasl.qop." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "     This is applicable only if HiveServer2 is configured to use Kerberos authentication." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.plan.serialization.format</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>kryo</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Query plan format serialization between client and task nodes. " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Two supported values are : kryo and javaXML. Kryo is default." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.vectorized.execution.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  This flag should be set to true to enable vectorized mode of query execution." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  The default value is false." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.vectorized.groupby.maxentries</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Max number of entries in the vector group by aggregation hashtables. Exceeding this will trigger a flush irrelevant of memory pressure condition.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.vectorized.groupby.checkinterval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>100000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of entries added to the group by aggregation hash before a reocmputation of average entry size is performed.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.vectorized.groupby.flush.percent</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Percent of entries in the group by aggregation hash flushed when the memory treshold is exceeded.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compute.query.using.stats</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  When set to true Hive will answer a few queries like count(1) purely using stats" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  stored in metastore. For basic stats collection turn on the config hive.stats.autogather to true." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  For more advanced stats collection need to run analyze table queries." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.schema.verification</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   Enforce metastore schema version consistency." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   True: Verify that version information stored in metastore matches with one from Hive jars.  Also disable automatic" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "         schema migration attempt. Users are required to manually migrate schema after Hive upgrade which ensures" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "         proper metastore schema migration. (Default)" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   False: Warn if the version information stored in metastore doesn't match with one from in Hive jars." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.integral.jdo.pushdown</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   Allow JDO query pushdown for integral partition columns in the metastore. Off by default." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   This improves metastore performance for integral columns, especially with a large number of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   partitions. However, it doesn't work correctly for integral values that are not normalized" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   (for example, if they have leading zeroes like 0012). If metastore direct SQL is enabled and" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "   works (hive.metastore.try.direct.sql), this optimization is also irrelevant." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.orc.splits.include.file.footer</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If turned on splits generated by orc will include metadata about the stripes in the file. This" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    data is read remotely (from the client or HS2 machine) and sent to all the tasks." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.orc.cache.stripe.details.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Cache size for keeping meta info about orc splits cached in the client." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.orc.compute.splits.num.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    How many threads orc should use to create splits in parallel." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.stats.gather.num.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Number of threads used by partialscan/noscan analyze command for partitioned tables." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This is applicable only for file formats that implement StatsProvidingRecordReader (like ORC)." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.orc.zerocopy</name>." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Use zerocopy reads with ORC." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.jar.directory</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This is the location Hive in Tez mode will look for to find a site wide" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    installed Hive instance. If not set, the directory under hive.user.install.directory" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    corresponding to current user name will be used." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.user.install.directory</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>hdfs:///home/hive/</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    If Hive (in Tez mode only) cannot find a usable Hive jar in \"hive.jar.directory\"," >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    it will upload the Hive jar to &lt;hive.user.install.directory&gt;/&lt;user name&gt;" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    and use it to run queries." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.tez.container.size</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>-1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>By default Tez will spawn containers of the size of a mapper. This can be used to overwrite.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.tez.java.opts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>By default Tez will use the Java options from map tasks. This can be used to overwrite.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.tez.log.level</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>INFO</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The log level to use for tasks executing as part of the DAG." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Used only if hive.tez.java.opts is used to configure Java options." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.tez.default.queues</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    A list of comma separated values corresponding to YARN queues of the same name." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    When HiveServer2 is launched in Tez mode, this configuration needs to be set" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    for multiple Tez sessions to run in parallel on the cluster." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.tez.sessions.per.default.queue</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    A positive integer that determines the number of Tez sessions that should be" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    launched on each of the queues specified by \"hive.server2.tez.default.queues\"." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Determines the parallelism on each queue." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.tez.initialize.default.sessions</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    This flag is used in HiveServer2 to enable a user to use HiveServer2 without" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    turning on Tez for HiveServer2. The user could potentially want to run queries" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    over Tez without the pool of sessions." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.allow.user.substitution</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Allow alternate user to be specified as part of HiveServer2 open connection request" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.resultset.use.unique.column.names</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Make column names unique in the result set by qualifying column names with table alias if needed." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Table alias will be added to column names for queries of type \"select *\" or" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    if query explicitly uses table alias \"select r1.x..\"." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compat</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.12</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Enable (configurable) deprecated behaviors by setting desired level of backward compatbility" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.try.direct.sql</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Whether Hive metastore should try to use direct SQL queries instead of DataNucleus for certain" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  read paths. Can improve metastore performance when fetching many partitions or column stats by" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  orders of magnitude; however, is not guaranteed to work on all RDBMS-es and all versions. In case" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  of SQL failures, metastore will fall back to DataNucleus, so it's safe even if SQL doesn't work" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  for all queries on your datastore. If all SQL queries fail (e.g. your metastore is backed by" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  MongoDB), you might want to disable this to save the try-and-fall-back cost." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.metastore.try.direct.sql.ddl</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Same as hive.metastore.try.direct.sql, for read statements within a transaction that modifies" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  metastore data. Due to non-standard behavior in Postgres, if direct SQL select query has" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  incorrect syntax or something inside a transaction, entire transaction will fail and fall-back to" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  DataNucleus will not be possible. You should disable the usage of direct SQL inside transactions" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  if that happens in your case." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <name>hive.mapjoin.optimized.keys</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  Whether MapJoin hashtable should use optimized (size-wise), keys, allowing the table to take less" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  memory. Depending on key, the memory savings for entire table can be 5-15% or so." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <name>hive.mapjoin.lazy.hashtable</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  Whether MapJoin hashtable should deserialize values on demand. Depending on how many values in" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  the table the join will actually touch, it can save a lot of memory by not creating objects for" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  rows that are not needed. If all rows are needed obviously there's no gain." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
#echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.check.crossproducts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Check if a plan contains a Cross Product. If there is one, output a warning to the Session's console." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.localize.resource.wait.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    Time in milliseconds to wait for another thread to localize the same resource for hive-tez." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.localize.resource.num.wait.attempts</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>5</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "    The number of attempts waiting for localizing a resource in hive-tez." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.use.SSL</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Set this to true for using SSL encryption in HiveServer2</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.keystore.path</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>SSL certificate keystore location</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.keystore.password</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>SSL certificate keystore password.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.authentication.pam.services</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value></value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>List of the underlying PAM services that should be used when authentication" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  type is PAM (hive.server2.authentication). A file with the same name must exist in" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  /etc/pam.d</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " <name>hive.convert.join.bucket.mapjoin.tez</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " <description>Whether joins can be automatically converted to bucket map " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " joins in hive when tez is used as the execution engine." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo " </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.serdes.using.metastore.for.schema</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.io.orc.OrcSerde,org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe,org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe,org.apache.hadoop.hive.serde2.dynamic_type.DynamicSerDe,org.apache.hadoop.hive.serde2.MetadataTypedColumnsetSerDe,org.apache.hadoop.hive.serde2.columnar.LazyBinaryColumnarSerDe,org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe,org.apache.hadoop.hive.serde2.lazybinary.LazyBinarySerDe</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This an internal parameter. Check with the hive dev. team</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.limit.query.max.table.partition</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>-1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>This controls how many partitions can be scanned for each partitioned table. The default value \"-1\" means no limit.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.txn.manager</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>org.apache.hadoop.hive.ql.lockmgr.DummyTxnManager</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description></description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.txn.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>300</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>time after which transactions are declared aborted if the client has" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  not sent a heartbeat, in seconds.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.txn.max.open.batch</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Maximum number of transactions that can be fetched in one call to open_txns()." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  Increasing this will decrease the number of delta files created when" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  streaming data into Hive.  But it will also increase the number of" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  open transactions at any given time, possibly impacting read " >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  performance." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  </description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.initiator.on</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>false</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Whether to run the compactor's initiator thread in this metastore instance or not.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.worker.threads</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of compactor worker threads to run on this metastore instance.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.worker.timeout</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>86400</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Time, in seconds, before a given compaction in working state is declared a failure and returned to the initiated state.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.check.interval</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>300</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Time in seconds between checks to see if any partitions need compacted." >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  This should be kept high because each check for compaction requires many calls against the NameNode.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.delta.num.threshold</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>10</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of delta files that must exist in a directory before the compactor will attempt a minor compaction.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.delta.pct.threshold</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>0.1</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Percentage (by size) of base that deltas can be before major compaction is initiated.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.mode.local.auto.inputbytes.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>107370000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description></description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.exec.mode.local.auto.input.files.max</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>200000000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description></description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.compactor.abortedtxn.threshold</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>1000</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description>Number of aborted transactions involving a particular table or partition before major compaction is initiated.</description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.logging.operation.enabled</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>true</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description></description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "<property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <name>hive.server2.logging.operation.log.location</name>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <value>$INSTALL_HOME/spark-${SPARK_VER}-bin-hadoop2.6/logs/operation.logs</value>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "  <description></description>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</property>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml
echo "</configuration>" >>  $INSTALL_PACKAGE_BIN/spark-${SPARK_VER}-bin-hadoop2.6/conf/hive-site.xml

exit 0
