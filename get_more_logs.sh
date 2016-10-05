#!/bin/bash
#CentOS
#Jacob Delgado - lrsupport - indexer box 

OUTPUT_DIR=/home/logrhythm/$(hostname)-$(date +%F-%H%M%S)
ES_LOGS_DIR=${OUTPUT_DIR}/es/

###################################################################
# elasticsearch information
###################################################################
echo "Obtaining elasticsearch logs and settings..."
mkdir -p ${ES_LOGS_DIR}/logs
find /var/log/elasticsearch/ -type f -mtime -5 -exec cp {} ${ES_LOGS_DIR}/logs \;

ES_INFO_FILE=${ES_LOGS_DIR}/info
echo "gathering elasticsearch settings"
echo "$(date) host=$(hostname) type=es cmd=all_settings" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_all/_settings?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch recovery information"
echo "$(date) host=$(hostname) type=es cmd=recovery" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_recovery/?pretty&human" >> ${ES_INFO_FILE}

###########
# Cat information
###########
echo "gathering elasticsearch cat/master"
echo "$(date) host=$(hostname) type=es cmd=cat_master" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cat/master?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cat/indices"
echo "$(date) host=$(hostname) type=es cmd=cat_indices" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cat/indices?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cat/shards"
echo "$(date) host=$(hostname) type=es cmd=cat_shards" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cat/shards?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cat/recovery"
echo "$(date) host=$(hostname) type=es cmd=cat_recovery" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cat/recovery?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cat/segments"
echo "$(date) host=$(hostname) type=es cmd=cat_segments" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cat/segments?pretty&human" >> ${ES_INFO_FILE}

###########
# Stats information
###########
echo "gathering elasticsearch stats/fielddata/all fields"
echo "$(date) host=$(hostname) type=es cmd=stats_fielddata" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_stats/fielddata?fields=*&pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch stats/query_cache"
echo "$(date) host=$(hostname) type=es cmd=stats_query_cache" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_stats/query_cache?pretty&human" >> ${ES_INFO_FILE}

###########
# Cluster information
###########
echo "gathering elasticsearch cluster/health"
echo "$(date) host=$(hostname) type=es cmd=cluster_health" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cluster/health?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cluster/settings"
echo "$(date) host=$(hostname) type=es cmd=cluster_settings" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cluster/settings?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cluster/state"
echo "$(date) host=$(hostname) type=es cmd=cluster_state" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cluster/state?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch cluster/pending_tasks"
echo "$(date) host=$(hostname) type=es cmd=cluster_pending_tasks" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_cluster/pending_tasks?pretty&human" >> ${ES_INFO_FILE}

###########
# Nodes information
###########
echo "gathering elasticsearch nodes"
echo "$(date) host=$(hostname) type=es cmd=nodes" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_nodes?pretty&human" >>${ES_INFO_FILE}

echo "gathering elasticsearch nodes/stats"
echo "$(date) host=$(hostname) type=es cmd=nodes_stats" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_nodes/stats?pretty&human" >>${ES_INFO_FILE}

echo "gathering elasticsearch nodes/hot_threads"
echo "$(date) host=$(hostname) type=es cmd=nodes_hot_threads" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_nodes/hot_threads?pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch nodes/stats/indicies/fielddata/all fields"
echo "$(date) host=$(hostname) type=es cmd=node_stats_indicies_fielddata_all" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_nodes/stats/indices/fielddata?fields=*&pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch nodes/stats/indices/fielddata/indicies and fields"
echo "$(date) host=$(hostname) type=es cmd=nodes_stats_indices_fielddata_indicies_fields" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_nodes/stats/indices/fielddata?level=indices&fields=*&pretty&human" >> ${ES_INFO_FILE}

echo "gathering elasticsearch nodes/stats/indices/query_cache"
echo "$(date) host=$(hostname) type=es cmd=nodes_stats_indicies_query_cache" >> ${ES_INFO_FILE}
curl --silent "localhost:9200/_nodes/stats/indices/query_cache?pretty&human" >> ${ES_INFO_FILE}

###################################################################
# consul information
###################################################################
CONSUL_LOG_DIR=${OUTPUT_DIR}/consul
mkdir -p ${CONSUL_LOG_DIR}
CONSUL_STATUS_FILE=${CONSUL_LOG_DIR}/status
echo "gathering consul v1/status/leader"
printf "\n$(date) host=$(hostname) type=consul cmd=v1_status_leader\n" >> ${CONSUL_STATUS_FILE}
curl --silent "localhost:8500/v1/status/leader" | python -m json.tool >> ${CONSUL_STATUS_FILE}
echo "gathering consul v1/status/peers"
printf "\n$(date) host=$(hostname) type=consul cmd=v1_status_peers\n" >> ${CONSUL_STATUS_FILE}
curl --silent "localhost:8500/v1/status/peers" | python -m json.tool >> ${CONSUL_STATUS_FILE}

CONSUL_CATALOG_FILE=${CONSUL_LOG_DIR}/catalog
echo "gathering consul v1/catalog/datacenters"
printf "\n$(date) host=$(hostname) type=consul cmd=v1_catalog_datacenters\n" >> ${CONSUL_CATALOG_FILE}
curl --silent "localhost:8500/v1/catalog/datacenters" | python -m json.tool >> ${CONSUL_CATALOG_FILE}
echo "gathering consul v1/catalog/nodes"
printf "\n$(date) host=$(hostname) type=consul cmd=v1_catalog_nodes\n" >> ${CONSUL_CATALOG_FILE}
NODES=$(curl --silent "localhost:8500/v1/catalog/nodes" | python -m json.tool | grep Node | awk -F\" '{print $4}')
curl --silent "localhost:8500/v1/catalog/nodes" | python -m json.tool >> ${CONSUL_CATALOG_FILE}
echo "gathering consul v1/catalog/services"
printf "\n$(date) host=$(hostname) type=consul cmd=v1_catalog_services\n" >> ${CONSUL_CATALOG_FILE}
curl --silent "localhost:8500/v1/catalog/services" | python -m json.tool >> ${CONSUL_CATALOG_FILE}

CONSUL_HEALTH_FILE=${CONSUL_LOG_DIR}/health
for n in ${NODES}
do
  echo "gathering consul v1/health/node/${n}"
  printf "\n$(date) host=$(hostname) type=consul cmd=v1_health_node_${n}\n" >> ${CONSUL_HEALTH_FILE}
  curl --silent "localhost:8500/v1/health/node/${n}" | python -m json.tool >> ${CONSUL_HEALTH_FILE}
done
echo "gathering consul v1/health/state/any"
printf "\n$(date) host=$(hostname) type=consul cmd=v1_health_state_any\n" >> ${CONSUL_HEALTH_FILE}
curl --silent "localhost:8500/v1/health/state/any" | python -m json.tool >> ${CONSUL_HEALTH_FILE}

###################################################################
# operating system information
###################################################################
OS_LOG_DIR=${OUTPUT_DIR}/os/
mkdir -p ${OS_LOG_DIR}
echo "Obtaining centos version..."
cp /etc/redhat-release ${OS_LOG_DIR}

echo "Copying secure logs..."
cp /var/log/secure* ${OS_LOG_DIR}

echo "Copying secure logs..."
cp /var/log/secure* ${OS_LOG_DIR}

echo "Copying meminfo logs..."
cp /proc/meminfo ${OS_LOG_DIR}

echo "Copying vmstat logs..."
cp /proc/vmstat ${OS_LOG_DIR}

echo "Copying vmallocinfo logs..."
cp /proc/vmallocinfo ${OS_LOG_DIR}

echo "Copying uptime logs..."
cp /proc/uptime ${OS_LOG_DIR}
uptime >> ${OS_LOG_DIR}/uptime

echo "Copying version logs..."
cp /proc/version ${OS_LOG_DIR}

echo "Copying cpuinfo logs..."
cp /proc/cpuinfo ${OS_LOG_DIR}

echo "Copying diskstats logs..."
cp /proc/diskstats ${OS_LOG_DIR}

echo "Copying swaps logs..."
cp /proc/swaps ${OS_LOG_DIR}
SUM=0
OVERALL=0
for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"`
do
  PID=`echo $DIR | cut -d / -f 3`
  PROGNAME=`ps -p $PID -o comm --no-headers`
  for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`
  do
    let SUM=$SUM+$SWAP
  done
  echo "PID=$PID - Swap used: $SUM - ($PROGNAME )" >> ${OS_LOG_DIR}/swaps
  let OVERALL=$OVERALL+$SUM
  SUM=0
done
echo "Overall swap used: $OVERALL" >> ${OS_LOG_DIR}/swaps

echo "Running 'free' command"
free > ${OS_LOG_DIR}/free

echo "running 'getconf PAGESIZE' command"
getconf PAGESIZE > ${OS_LOG_DIR}/getconf

echo "Copying messages..."
cp /var/log/messages* ${OS_LOG_DIR}

echo "Copying yum logs..."
cp /var/log/yum* ${OS_LOG_DIR}

echo "Obtaining network related information..."
NETWORK_INFO_FILE=${OS_LOG_DIR}/network

echo "$(date) host=$(hostname) type=os cmd=ss" >> ${NETWORK_INFO_FILE}
ss -aneef inet >> ${NETWORK_INFO_FILE}

echo "$(date) host=$(hostname) type=os cmd=ip_link" >> ${NETWORK_INFO_FILE}
ip -s link >> ${NETWORK_INFO_FILE}

echo "$(date) host=$(hostname) type=os cmd=ip_n" >> ${NETWORK_INFO_FILE}
ip -s n >> ${NETWORK_INFO_FILE}

OS_INFO_FILE=${OS_LOG_DIR}/os
echo "Obtaining system information..."
echo "$(date) host=$(hostname) type=os cmd=top" >> ${OS_INFO_FILE}
top -n 10 >> ${OS_INFO_FILE}

echo "$(date) host=$(hostname) type=os cmd=ps" >> ${OS_INFO_FILE}
ps aux >> ${OS_INFO_FILE}

echo "$(date) host=$(hostname) type=os cmd=fstab" >> ${OS_INFO_FILE}
cat /etc/fstab >> ${OS_INFO_FILE}

echo "$(date) host=$(hostname) type=os cmd=dfh" >> ${OS_INFO_FILE}
df -h >> ${OS_INFO_FILE}

###################################################################
# data indexer specific information
###################################################################
DX_LOG_DIR=${OUTPUT_DIR}/dx
mkdir -p ${DX_LOG_DIR}
echo "Obtaining data indexer version..."
cp /usr/local/logrhythm/version ${DX_LOG_DIR}/version

echo "Obtaining mergeforward.ini..."
cp /usr/local/logrhythm/cluster/mergeforward.ini ${DX_LOG_DIR}

echo "Copying conf files..."
cp -R /usr/local/logrhythm/configserver/conf ${DX_LOG_DIR}

echo "Copying data indexer logs..."
cp -R /var/log/persistent/ ${DX_LOG_DIR}

echo "Gathering verification of Data Indexer rpms..."
echo "$(date) host=$(hostname) type=os cmd=yum_list" > ${DX_LOG_DIR}/rpms
yum list installed | grep logrhythm | tee -a ${DX_LOG_DIR}/rpms > /dev/null
for i in allconf anubis bulldozer carpenter columbo conductor configserver consul consul-template dispatch dxmergeforward elasticsearch godispatch gomaintain grafana heartthrob influxdb jre keyczar libsodium nginx persistent silence sshpass unicon unzip vitals zeromq
do
    echo "$(date) host=$(hostname) type=os cmd=yum_verify package=${i}" >> ${DX_LOG_DIR}/rpms
    rpm -V $(rpm -qa | grep ${i}) | tee -a ${DX_LOG_DIR}/rpms > /dev/null
done

echo "Gathering influxDB database..."
systemctl stop influxdb
cp -R /usr/local/logrhythm/db/influxdb ${DX_LOG_DIR}
systemctl start influxdb

echo "Gathering grafana database..."
systemctl stop grafana
cp -R /usr/local/logrhythm/db/grafana ${DX_LOG_DIR}
systemctl start grafana

echo "Gathering gigawatt database..."
systemctl stop anubis
cp -R /usr/local/logrhythm/db/gigawatt ${DX_LOG_DIR}
systemctl start anubis

###################################################################
# rpms
###################################################################
RPMS_DIR=${OUTPUT_DIR}/rpms/
echo "Collecting grafana rpm used for install"
cp /usr/local/logrhythm/node-repository/grafana*.rpm ${RPMS_DIR}

echo "Collecting grafana rpm used for install"
cp /usr/local/logrhythm/node-repository/influx*.rpm ${RPMS_DIR}

###################################################################
# Wrap-up data collection
###################################################################
echo "Creating $OUTPUT_DIR.tgz..."
tar cfz ${OUTPUT_DIR}.tgz -C ${OUTPUT_DIR} .

if [ -f ${OUTPUT_DIR}.tgz ]; then
    echo "Deleting $OUTPUT_DIR"
    rm -rf ${OUTPUT_DIR}
fi
