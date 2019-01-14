#this is mysql increment backup script

mysqlbase=/home/mysql/mysql-8.0.12-slave
dbname=t_user1
dbpass=123456
dbhost=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/'`
dbport=3307
currenttime=`date +"%Y-%m-%d %H:%M:%S"`
before1h=`date -d "1 hour ago" +"%Y-%m-%d %H:%M:%S"`
to_op_sql="use op;"
backupdir=/home/mysql/increment_backup_intoout
datadir=backup_`date +"%Y%m%d-%H%M%S"`
datesuffix=`date +"%Y%m%d%H%M%S"`
publicfield=CREATED_DATE
sockpath=$mysqlbase/tmp/mysql.sock
mysql="./mysql -u$dbname -p$dbpass -P$dbport -S $sockpath"
cleandate=`date -d "24 hour ago" +"%Y%m%d%H%M%S"`

#一小时备份一次的表，增量备份
#["t_chase_number"]="追号投注内容表"
#["t_user_parent"]="用户层级表"
#没有时间标识不能增量备份
declare -A tablelist=(
  ["t_user"]="用户表"
  ["t_user_balance"]="余额表"
  ["t_bet_order"]="注单表"
  ["t_chase_order"]="追号订单表"
  ["t_chase_issue"]="追号期号表"
)

backuptable(){
  for i in ${!tablelist[@]}
  do
    if [ "$i" == "t_bet_order" ]; then
      publicfield=BET_TIME
    fi
    if [ "$i" == "t_chase_order" ]; then
      publicfield=CHASE_TIME
    fi
    cd $backupdir/$datadir  
    echo "======开始备份$i【${tablelist[$i]}】========"
    cd $mysqlbase/bin
    #$mysql -e "$to_op_sql; select * from $i where $publicfield BETWEEN '$before1h' and '$currenttime' into outfile '$backupdir/$datadir/$i/$datesuffix.sql'"
    $mysql -e "$to_op_sql; select * from $i where $publicfield BETWEEN '$before1h' and '$currenttime' into outfile '$backupdir/$datadir/$i.sql' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'"
    echo "======【${tablelist[$i]}】备份完毕！========"
    publicfield=CREATED_DATE    
  done 
}

checkdir(){
  if [ ! -d $mysqlbase ]; then
    echo "=======mysql安装目录不存在，请检查！"
    exit 0
  fi
  if [ ! -d $backupdir ]; then
    mkdir $backupdir
    chown -R mysql:mysql $backupdir
  fi
  cd $backupdir
  if [ ! -d $datadir ]; then
    mkdir $datadir
    chown -R mysql:mysql $datadir
  fi
}

cleanpkg(){
  echo "=======开始打包备份======="
  cd $backupdir
  if [ ! -d $datadir ]; then
    echo "打包出错，没有备份文件目录，请检查！"
    exit 0
  else
    tar -czvf "$datadir".tar.gz $datadir
    rm -rf $datadir
  fi
  
  #开始清理24小时之前的备份包
  echo "=======开始清理24小时之前的备份包======="
  for i in `ls`
  do
    file0=`expr ${i/"backup_"/""}`
    file1=`expr ${file0/-/""}`
    if [ ${i##*.} == "gz" ]; then
      file1=`expr ${file1%%.*}`
    fi
    if [[ "$file1" -lt "$cleandate" ]]; then
      rm -rf $i
      echo "=======清理备份包:$i======="
    fi    
  done
  echo "=======打包完毕！======="
  echo "=======备份完成！======="
}
checkdir
backuptable
cleanpkg
