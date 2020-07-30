#!/bin/bash
set -e
#配置
#数据库配置
#mysql地址ip:port/dbName、用户名、密码
mysql_ip=172.32.1.181
mysql_port=3367
mysql_username=root
mysql_password=123456

#注册中心地址：IP：端口
eureka_ip=localhost
eureka_port=8000

#gateway配置：端口
gateway_port=9753

#HDFS配置：IP、端口
hdfs_ip=172.32.1.7
hdfs_port=8020
#如果开启hdfs开启了高可用，请填写下面信息
hdfs_nameservice=nameservice1
hdfs_namenodes="172.32.1.7:8020,172.32.1.7:8020"

#zookeeper地址配置：IP、端口
zk_addr=172.32.1.171
zk_port=2181

#phoenix配置 地址=ip：端口
PHOENIX_ADDR=$zk_addr:$zk_port
phoenix_templateId=1

#hbase设置：hdfs上hbase数据存放地址
hbase_parent=/hbase
hbase_datadir=/hbase/data

#redis配置：IP、端口、密码、数据库、datax数据库
redis_ip=172.32.1.181
redis_port=6379
redis_password=123456
redis_db=1
redis_db_datax=9

#es设置：集群地址 IP1:端口,IP2:端口,IP3:端口
es_nodes=172.32.1.173:9200,172.32.1.183:9200,172.32.1.186:9200
es_before_index_name=before-error-data-test
es_middle_index_name=middle-error-data-test
es_after_index_name=after-error-data-test

#atlas配置 ip地址:端口
atlas_addr=172.32.1.181:21000
atlas_username=admin
atlas_password=admin

#Kafka配置 
kafka_addr=172.32.1.171:9092
kafka_group=yx-dataclean
kafka_destination=yx-dataclearn-uat

#datax配置
datax_home_dir=/home/datax


#spark_shell及datacleaner配置
spark_shell_ip=172.32.1.171
spark_shell_port=22
spark_shell_username=root
spark_shell_password='1QAZ@ws'

#nlp设置
nlpwebroot=http://10.221.121.4:8080/
nlpdocumnetPath=/var/ftp/pub/document/
ftppath=/pub/document/

#-----------------------------------------------------------------------------------------
#本地路径设置，一般之规定总路径即可总路径即可，一般规定为绝对路径
#执行Datacleaner任务的shell目录、
dc_shell_dir=/home/spark_task

#执行DataCleaner任务总目录
task_path_local_dir=/home/dataclean_job

#事中深度清洗路径配置
api_clean_shell_file=/home/DataCleaner/datacleaner.sh
api_clean_base_dir=$task_path_local_dir/monitor-api-clean/
#事中核对
sz_datacheck_config_file=$task_path_local_dir/sz_datacheck/conf/conf.xml
sz_datacheck_log_dir=$task_path_local_dir/sz_datacheck/job/
#事后核对
sh_datacheck_log_dir=$task_path_local_dir/sh_datacheck/log/

#hdfs上DataCleaner配置
spark_config_hdfs_dir=/datacleaner/jobs
#datax文件配置
datax_config_file=$datax_home_dir/conf/core.json
datax_log_dir=$datax_home_dir/log/
datax_libs_dir=$datax_home_dir/plugin/reader/rdbmsreader/libs
sql_parse_dir=$datax_home_dir/uploadfile_parse/
datax_upload_dir=$datax_home_dir/upload/
#数据概貌脚本地址
shell_file=/home/spark_task/182/statV2.sh
#元数据完善的上传、下载路径
metadata_upload_dir=/home/yx_metadata/
metadata_download_template_dir=$metadata_upload_dir/download/
#服务共享文件
share_file_dir=/home/share
share_example_file=$share_file_dir/example.xlsx
share_downLoad_dir=$share_file_dir/file


init_dirs=($dc_shell_dir $task_path_local_dir $api_clean_shell_file $api_clean_base_dir $sz_datacheck_log_dir $sh_datacheck_log_dir $datax_log_dir $datax_libs_dir $sql_parse_dir $datax_upload_dir $metadata_upload_dir $metadata_download_template_dir $share_file_dir $share_downLoad_dir)


for test in ${init_dirs[@]};
do
  echo "init_dirs is $test"
done


init_file=($share_example_file $sz_datacheck_config_file $shell_file $datax_config_file)



#-----------------------------------------------------------------------------------------
#应用服务名称，为应用之间相互调用，一般不做修改
yx_gataway='yx-gateway'
yx_auth='yx-auth'
yx_clean='yx-clean'
yx_dataaccess='yx-dataaccess'
yx_share='yx-share'
yx_meta='yx-meta'
yx_datax='yx-datax'
#-----------------------------------------------------------------------------------------
#这里的配置文件是上面配置的连接完整部分，不用修改
#datagovern和dataxdb数据库连接配置
DATASOURCE_URL_DATAGOVERN="jdbc:mysql://$mysql_ip:$mysql_port/datagovern?useUnicode=true&characterEncoding=utf8&useSSL=false&allowMultiQueries=true"
DATASOURCE_URL_DATAXDB="jdbc:mysql://$mysql_ip:$mysql_port/dataxdb?useUnicode=true&characterEncoding=utf-8"

#hdfs地址
HDFS_ADDR="hdfs://$hdfs_ip:$hdfs_port"

#eureka地址
EUREKA_ADDR="http://$eureka_ip:$eureka_port/eureka/"

#atlas地址
ATLAS_BASE_URL="http://${atlas_addr}"

#Hbase数据目录地址
HBASE_DATADIR_URL="hdfs://${hdfs_ip}:${hdfs_port}${hbase_datadir}"

#phoenix连接地址
PHOENIX_URL="jdbc:phoenix:$PHOENIX_ADDR"
#-----------------------------------------------------------------------------------------
#服务中相互引用的配置
#dataclean
appname_metadata=$yx_meta
appname_yx_datasource=$yx_dataaccess
appname_standardevaluate=$yx_dataaccess
#dataaccess
service_xdata=$yx_dataaccess
service_dataAnalyze=$yx_clean
#yx-datax
service_xdata=$yx_dataaccess
service_dataAnalyze=$yx_clean

#-----------------------------------------------------------------------------------------
#全局配置
#应用根目录
base_dir=$(dirname $(readlink -f $0))
echo "base_dir is :${base_dir}"
#服务中配置文件的相对位置
config_file=config/application.properties
#应用安装包后缀名
suffix_name=full.zip

#-----------------------------------------------------------------------------------------
#----随机生成9000~10000之间的端口
#----启动应用,将启动命令写入应用所在目录
#----将启动后的应用进程号写入文件
#----修改nginx，启动前端
#-----------------------------------------------------------------------------------------

#生成随机端口号
#指定区间随机数
function random_range() {
  shuf -i $1-$2 -n1
}
#判断当前端口是否被占用，没被占用返回0，反之1
function Listening() {
  TCPListeningnum=$(netstat -an | grep ":$1 " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l)
  UDPListeningnum=$(netstat -an | grep ":$1 " | awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l)
  ((Listeningnum = TCPListeningnum + UDPListeningnum))
  if [ $Listeningnum == 0 ]; then
    echo "0"
  else
    echo "1"
  fi
}
#给定一个区间获取到一个未被使用的随机端口
function get_random_port() {
  PORT=0
  while [ $PORT == 0 ]; do
    temp=$(random_range $1 $2)
    if [[ $(Listening $temp)g == 0g ]]; then
      PORT=$temp
    fi
  done
  echo $PORT
}
#随机端口
server_port=$(get_random_port 9000 10000)

#-----------------------------------------------------------------------------------------
#将文件中匹配的字符串换成另一方字符串
#$1：文件路径，$2：需要设置值得参数，$3：替换的字符串
function replaceProperty(){
    sed -n -e "/$2=/=" $1 | xargs -I {} sed -i "{}c $2=${3}" $1
}
echo "begin run"
#replaceProperty $1 $2 $3

#-----------------------------------------------------------------------------------------
#启动注册中心
eureka_dir=$base_dir/eureka
eureka_app="spring-0.0.1-SNAPSHOT"

unzip -oq $eureka_dir/$eureka_app-$suffix_name -d $eureka_dir
eureka_dir=$eureka_dir/$eureka_app

echo "改注册中心配置"
#修改配置文件
eureka_config_addr=$eureka_dir/$config_file
replaceProperty $eureka_config_addr 'server.port' $eureka_port

eureka_shell="java -jar -Duser.timezone=GMT+8 ${eureka_dir}/${eureka_app}.jar -spring.config.location=${eureka_config_addr}"

#-----------------------------------------------------------------------------------------
#启动gateway
gateway_dir=$base_dir/gateway
gateway_app="gateway-0.0.1-SNAPSHOT"
echo "修改gateway"
#解压
#unzip -o ${BUILD_ID}/${app_name}-bin.zip -d ${BUILD_ID}

unzip -oq $gateway_dir/$gateway_app-$suffix_name -d $gateway_dir
gateway_dir=$gateway_dir/$gateway_app

#修改配置文件
gateway_config_addr=$gateway_dir/$config_file

replaceProperty $gateway_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAGOVERN
replaceProperty $gateway_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $gateway_config_addr 'spring.datasource.password' $mysql_password
replaceProperty $gateway_config_addr 'spring.application.name' $yx_gataway
replaceProperty $gateway_config_addr 'server.port' $gateway_port
replaceProperty $gateway_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR

gateway_shell="java -jar -Duser.timezone=GMT+8 ${gateway_dir}/${gateway_app}.jar --spring.config.location=$gateway_config_addr "

#-----------------------------------------------------------------------------------------
#启动dataclean
dataclean_dir=$base_dir/dataclean
dataclean_app="dataclean-0.0.1-SNAPSHOT"

#解压
unzip -oq $dataclean_dir/$dataclean_app-$suffix_name -d $dataclean_dir
dataclean_dir=$dataclean_dir/$dataclean_app

echo "修改dataclean"
#修改配置文件
dataclean_config_addr=$dataclean_dir/$config_file

replaceProperty $dataclean_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAGOVERN
replaceProperty $dataclean_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $dataclean_config_addr 'spring.datasource.password' $mysql_password 
replaceProperty $dataclean_config_addr 'server.port' $(get_random_port 9000 10000)
replaceProperty $dataclean_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR
replaceProperty $dataclean_config_addr 'spring.application.name' $yx_clean
replaceProperty $dataclean_config_addr 'appname.metadata' $yx_meta
replaceProperty $dataclean_config_addr 'appname.yx-datasource' $yx_dataaccess
replaceProperty $dataclean_config_addr 'appname.yx-datasource' $yx_dataaccess
replaceProperty $dataclean_config_addr 'spring.cloud.stream.kafka.binder.brokers' $kafka_addr
replaceProperty $dataclean_config_addr 'spring.cloud.stream.bindings.clearn-result.group' $kafka_group
replaceProperty $dataclean_config_addr 'spring.cloud.stream.bindings.clearn-result.destination' $kafka_destination
replaceProperty $dataclean_config_addr 'datacleaner.path.dcsourceconfig' $sz_datacheck_config_file
replaceProperty $dataclean_config_addr 'datacleaner.path.joblogpath' $sz_datacheck_log_dir
replaceProperty $dataclean_config_addr 'monitor-sh-datacheck.logpath' $sh_datacheck_log_dir
replaceProperty $dataclean_config_addr 'monitor-api-clean.basePath' $api_clean_base_dir
replaceProperty $dataclean_config_addr 'monitor-api-clean.shellPath' $api_clean_shell_file
replaceProperty $dataclean_config_addr 'taskpath.localPath' $task_path_local_dir
replaceProperty $dataclean_config_addr 'hbase.zk.quorum' $zk_addr
replaceProperty $dataclean_config_addr 'hbase.zk.url' $PHOENIX_URL
replaceProperty $dataclean_config_addr 'taskpath.hdfsAddress' $HDFS_ADDR
replaceProperty $dataclean_config_addr 'taskpath.sparkAddr.password' $spark_shell_password
replaceProperty $dataclean_config_addr 'taskpath.sparkAddr.host' $spark_shell_ip
replaceProperty $dataclean_config_addr 'phoenix.templateId' $phoenix_templateId
replaceProperty $dataclean_config_addr 'atlas.baseUrl' $ATLAS_BASE_URL
replaceProperty $dataclean_config_addr 'atlas.username' $atlas_username
replaceProperty $dataclean_config_addr 'atlas.password' $atlas_password
replaceProperty $dataclean_config_addr 'myElasticsearch.cluster-nodes' $es_nodes
replaceProperty $dataclean_config_addr 'myElasticsearch.before-index-name' $es_before_index_name
replaceProperty $dataclean_config_addr 'myElasticsearch.middle-index-name' $es_middle_index_name
replaceProperty $dataclean_config_addr 'myElasticsearch.after-index-name' $es_after_index_name
replaceProperty $dataclean_config_addr 'spring.redis.host' $redis_ip
replaceProperty $dataclean_config_addr 'spring.redis.port' $redis_port
replaceProperty $dataclean_config_addr 'spring.redis.password' $redis_password
replaceProperty $dataclean_config_addr 'spring.redis.database' $redis_db

#replaceProperty $dataclean_config_addr ''

dataclean_shell="java -jar -Duser.timezone=GMT+8 ${dataclean_dir}/${dataclean_app}.jar --spring.config.location=$dataclean_config_addr "

#-----------------------------------------------------------------------------------------
#启动dataaccess
dataaccess_dir=$base_dir/dataaccess
dataaccess_app="tools.manage-0.0.1-SNAPSHOT"

#解压
unzip -oq $dataaccess_dir/$dataaccess_app-$suffix_name -d $dataaccess_dir
dataaccess_dir=$dataaccess_dir/$dataaccess_app

echo "修改dataaccess"
#修改配置文件
dataaccess_config_addr=$dataaccess_dir/$config_file

replaceProperty $dataaccess_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAGOVERN
replaceProperty $dataaccess_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $dataaccess_config_addr 'spring.datasource.password' $mysql_password 
replaceProperty $dataaccess_config_addr 'server.port' $(get_random_port 9000 10000)
replaceProperty $dataaccess_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR
replaceProperty $dataaccess_config_addr 'spring.application.name' $yx_dataaccess
replaceProperty $dataaccess_config_addr 'feign.name.auth' $yx_auth
replaceProperty $dataaccess_config_addr 'feign.name.dataClean' $yx_clean
replaceProperty $dataaccess_config_addr 'feign.name.datax' $yx_datax
replaceProperty $dataaccess_config_addr 'feign.name.metadata' $yx_meta
replaceProperty $dataaccess_config_addr 'hbase.zk.quorum' $zk_addr
replaceProperty $dataaccess_config_addr 'hbase.zk.url' $PHOENIX_URL
replaceProperty $dataaccess_config_addr 'SHELL_PATH' $shell_file
replaceProperty $dataaccess_config_addr 'SHELL_PWD' $spark_shell_password
replaceProperty $dataaccess_config_addr 'SHELL_IP' $spark_shell_ip
replaceProperty $dataaccess_config_addr 'phoenix.jdbc.url' $PHOENIX_URL
replaceProperty $dataaccess_config_addr 'hbase.datadir' $HBASE_DATADIR_URL
replaceProperty $dataaccess_config_addr 'upload.path' $metadata_upload_dir
replaceProperty $dataaccess_config_addr 'download.template.path' $metadata_download_template_dir
replaceProperty $dataaccess_config_addr 'atlas.baseUrl' $ATLAS_BASE_URL
replaceProperty $dataaccess_config_addr 'atlas.username' $atlas_username
replaceProperty $dataaccess_config_addr 'atlas.password' $atlas_password
replaceProperty $dataaccess_config_addr 'phoenix.templateId' $phoenix_templateId
replaceProperty $dataaccess_config_addr 'spring.redis.host' $redis_ip
replaceProperty $dataaccess_config_addr 'spring.redis.port' $redis_port
replaceProperty $dataaccess_config_addr 'spring.redis.password' $redis_password
replaceProperty $dataaccess_config_addr 'redis.database.access' $redis_db_datax
replaceProperty $dataaccess_config_addr 'spring.redis.database' $redis_db

dataaccess_shell="java -jar -Duser.timezone=GMT+8 ${dataaccess_dir}/${dataaccess_app}.jar --spring.config.location=$dataaccess_config_addr"

#-----------------------------------------------------------------------------------------
#启动metadata
metadata_dir=$base_dir/metadata
metadata_app="metadata-0.0.1-SNAPSHOT"
echo "修改metadata"
#解压
unzip -oq $metadata_dir/$metadata_app-$suffix_name -d $metadata_dir
metadata_dir=$metadata_dir/$metadata_app

metadata_config_addr=$metadata_dir/$config_file

replaceProperty $metadata_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAGOVERN
replaceProperty $metadata_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $metadata_config_addr 'spring.datasource.password' $mysql_password 
replaceProperty $metadata_config_addr 'server.port' $(get_random_port 9000 10000)
replaceProperty $metadata_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR
replaceProperty $metadata_config_addr 'spring.application.name' $yx_meta
replaceProperty $metadata_config_addr 'service.dataAnalyze' $yx_clean
replaceProperty $metadata_config_addr 'upload.path' $metadata_upload_dir
replaceProperty $metadata_config_addr 'download.template.path' $metadata_download_template_dir
replaceProperty $metadata_config_addr 'atlas.baseUrl' $ATLAS_BASE_URL
replaceProperty $metadata_config_addr 'atlas.username' $atlas_username
replaceProperty $metadata_config_addr 'atlas.password' $atlas_password
replaceProperty $metadata_config_addr 'nlpwebroot' $nlpwebroot
replaceProperty $metadata_config_addr 'nlpdocumnetPath' $nlpdocumnetPath
replaceProperty $metadata_config_addr 'ftppath' $ftppath

metadata_shell="java -jar -Duser.timezone=GMT+8 ${metadata_dir}/${metadata_app}.jar --spring.config.location=$metadata_config_addr"
#-----------------------------------------------------------------------------------------
#启动share
share_dir=$base_dir/share
share_app="share-0.0.1-SNAPSHOT"
echo "修改share"
#解压
unzip -oq $share_dir/$share_app-$suffix_name -d $share_dir
share_dir=$share_dir/$share_app

#修改配置文件
share_config_addr=$share_dir/$config_file

replaceProperty $share_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAGOVERN
replaceProperty $share_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $share_config_addr 'spring.datasource.password' $mysql_password 
replaceProperty $share_config_addr 'server.port' $(get_random_port 9000 10000)
replaceProperty $share_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR
replaceProperty $share_config_addr 'spring.application.name' $yx_share
replaceProperty $share_config_addr 'filePath' $share_file_dir
replaceProperty $share_config_addr 'exampleFilePath' $share_example_file
replaceProperty $share_config_addr 'downLoadPath' $share_downLoad_dir

share_shell="java -jar -Duser.timezone=GMT+8 ${share_dir}/${share_app}.jar --spring.config.location=$share_config_addr"

#-----------------------------------------------------------------------------------------
#启动yx-datax
yx_datax_dir=$base_dir/yx-datax
yx_datax_app="yeexun-datax-sc-0.0.1-SNAPSHOT"
echo "修改yx-datax"
#解压
unzip -oq $yx_datax_dir/$yx_datax_app-$suffix_name -d $yx_datax_dir
yx_datax_dir=$yx_datax_dir/$yx_datax_app

#修改配置文件
yxdatax_config_addr=$yx_datax_dir/$config_file

replaceProperty $yxdatax_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAXDB
replaceProperty $yxdatax_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $yxdatax_config_addr 'spring.datasource.password' $mysql_password 
replaceProperty $yxdatax_config_addr 'server.port' $(get_random_port 9000 10000)
replaceProperty $yxdatax_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR
replaceProperty $yxdatax_config_addr 'spring.application.name' $yx_datax
replaceProperty $yxdatax_config_addr 'service.xdata' $yx_dataaccess
replaceProperty $yxdatax_config_addr 'service.dataAnalyze' $yx_clean
replaceProperty $yxdatax_config_addr 'dataxHome' $datax_home_dir

yx_datax_shell="java -jar -Duser.timezone=GMT+8 ${yx_datax_dir}/${yx_datax_app}.jar --spring.config.location=$yxdatax_config_addr "
#-----------------------------------------------------------------------------------------
#启动auth
auth_dir=$base_dir/auth
auth_app="shiro-0.0.1-SNAPSHOT"
echo "修改auth"
#解压
unzip -oq $auth_dir/$auth_app-$suffix_name -d $auth_dir
auth_dir=$auth_dir/$auth_app

#修改配置文件
auth_config_addr=$auth_dir/$config_file

replaceProperty $auth_config_addr 'spring.datasource.url' $DATASOURCE_URL_DATAGOVERN
replaceProperty $auth_config_addr 'spring.datasource.username' $mysql_username
replaceProperty $auth_config_addr 'spring.datasource.password' $mysql_password 
replaceProperty $auth_config_addr 'server.port' $(get_random_port 9000 10000)
replaceProperty $auth_config_addr 'eureka.client.serviceUrl.defaultZone' $EUREKA_ADDR
replaceProperty $auth_config_addr 'spring.application.name' $yx_auth
replaceProperty $auth_config_addr 'dataxHome' $datax_home_dir
replaceProperty $auth_config_addr 'feign.name.xdata' $yx_dataaccess
replaceProperty $auth_config_addr 'spring.uploadFilePath' $datax_upload_dir

auth_shell="java -jar -Duser.timezone=GMT+8 ${auth_dir}/${auth_app}.jar --spring.config.location=$auth_config_addr"
#-----------------------------------------------------------------------------------------
#部署masterdata


#-----------------------------------------------------------------------------------------
#部署agent
agent_shell=""

#-----------------------------------------------------------------------------------------
#修改datax配置文件

sed -n -e "/\ \ \ \ \ \ \ \ \"host\":/=" $datax_config_file | xargs -I {} sed -i "{}c \ \ \ \ \ \ \ \ \"host\":\"${redis_ip}\"" $datax_config_file
sed -n -e "/\ \ \ \ \ \ \ \ \"port\":/=" $datax_config_file | xargs -I {} sed -i "{}c \ \ \ \ \ \ \ \ \"port\":\"${redis_port}\"" $datax_config_file
sed -n -e "/\ \ \ \ \ \ \ \ \"pwd\":/=" $datax_config_file | xargs -I {} sed -i "{}c \ \ \ \ \ \ \ \ \"pwd\":\"${redis_password}\"" $datax_config_file
sed -n -e "/\ \ \ \ \ \ \ \ \"base\":/=" $datax_config_file | xargs -I {} sed -i "{}c \ \ \ \ \ \ \ \ \"base\":\"${redis_db_datax}\"" $datax_config_file

#-----------------------------------------------------------------------------------------
#初始化atlas
agent_shell=""

#-----------------------------------------------------------------------------------------
#初始化文件夹和文件
for inintdir in ${init_dirs[@]};
do
  if [ ! -d $inintdir ] ; then
    mkdir -p $inintdir
    echo " $inintdir is created"
  else 
    echo "$inintdir is exist"
  fi
done


#-----------------------------------------------------------------------------------------
#循环启动所有服务
echo "-----------------------------------------------------------------------------------------"

declare -a shell_array
declare -a java_dir

#shell_array=(${eureka_shell},${gateway_shell},${dataclean_shell},${dataaccess_shell},${metadata_shell},${share_shell},${yx_datax_shell},${auth_shell})
#java_dir=("eureka","gateway","dataclean","dataaccess","metadata","share","yx-datax","auth")
shell_array[0]=${eureka_shell}
java_dir[0]=${eureka_dir}

shell_array[1]=${gateway_shell}
java_dir[1]=${gateway_dir}

shell_array[2]=${dataclean_shell}
java_dir[2]=${dataclean_dir}

shell_array[3]=${dataaccess_shell}
java_dir[3]=${dataaccess_dir}

shell_array[4]=${metadata_shell}
java_dir[4]=${metadata_dir}

shell_array[5]=${share_shell}
java_dir[5]=${share_dir}

shell_array[6]=${yx_datax_shell}
java_dir[6]=${yx_datax_dir}

shell_array[7]=${auth_shell}
java_dir[7]=${auth_dir}

shell_length="${#shell_array[@]}"
java_dir_length="${#java_dir[@]}"

echo "shell_array的长度为：${shell_length}"
for cmd in "${shell_array[@]}"; do
  echo "遍历列shell_array：${cmd}"
done

echo "java_dir的长度为：${java_dir_length}"
for dir in "${java_dir[@]}"; do
  echo "遍历列java_dir：${dir}"
done

echo "-----------------------------------------------------------------------------------------"

#-----------------------------------------------------------------------------------------
#循环启动所有服务
# for ((i = 0; i < $shell_length; i++)); do
#   echo " 
#     "
#   abslute_app_dir=${base_dir}/${java_dir[$i]}
#   echo "this shell is:${shell_array[$i]}"
#   echo "this dir is:${java_dir[$i]}"
#   echo "this abs_dir is:${abslute_app_dir}"
#   #--启动命令，将命令写入文件
#   #nohup ${java_command} > ${current_workdir}/application.log 2>&1 & echo $! > java_app.pid
#   start_cmd="nohup ${shell_array[$i]} > ${abslute_app_dir}/application.log 2>&1 & echo \$! > ${abslute_app_dir}/java_app.pid"
#   echo "启动程序：${java_dir[$i]}=====>${start_cmd}"
#   #--将启动命令写入到相应的目录
#   echo ${start_cmd} >${abslute_app_dir}/start.sh
#   /bin/bash ${abslute_app_dir}/start.sh
#   echo "${java_dir[$i]}服务已启动:/bin/bash ${abslute_app_dir}/start.sh"
# 
# done

