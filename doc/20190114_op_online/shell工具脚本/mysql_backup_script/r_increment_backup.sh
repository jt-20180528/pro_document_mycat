set -e
#table recover scripts

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
rtable=""
rtime=""
rpkg=""

declare -A tablelist=(
  ["t_user"]="用户表"
  ["t_user_balance"]="余额表"
  ["t_bet_order"]="注单表"
  ["t_chase_order"]="追号订单表"
  ["t_chase_issue"]="追号期号表"
)

recover(){
  cd $backupdir
  for i in `ls`
  do 
    file0=${i/-/""}
    if [[ $file0 =~ $rtime ]]; then
      echo "找到待还原增量备份目录：$i"
      rpkg=$i
      continue
    fi
  done
  if [ ${#rpkg} -eq 0 ]; then
    echo "没有找到你输入时间的备份文件，请检查你的输入或者联系管理员！"
    exit 0
  else
    tar -zxvf $rpkg
    folde=`echo ${rpkg%%.*}`
    cd $mysqlbase/bin
    $mysql -e "$to_op_sql; LOAD DATA INFILE '$backupdir/$folde/$rtable.sql' INTO TABLE $rtable FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n';"
    echo "还原表 $rtable 到 $rtime 成功！"
    cd $backupdir
    rm -rf $folde
    exit 0
  fi
}

checkdir(){
  if [ ! -d $mysqlbase ]; then
    echo "=======mysql安装目录不存在，请检查！"
    exit 0
  fi
  if [ ! -d $backupdir ]; then
    echo "=======增量备份目录不存在，请检查！"
    exit 0
  fi
  rtable=""
  rtime=""

  read -t 30 -p "你正在操作增量还原数据，下一步将要求你输入表明和时间(只能是小时|年月日时)格式例如：t_table 2012010115，是否继续 y / n ? " check
  if [ ${#check} -eq 0 ]; then
    echo "已经退出操作，如需帮助，请联系管理员！"
    exit 0
  fi
  if [ "${check}" == "n" ]; then
    echo "已经退出操作，如需帮助，请联系管理员！"
    exit 0
  fi
  read -t 30 -p "请输入表明和时间(只能是最近24小时整点)... " rtable rtime

  if [ ${#rtable} -eq 0 -o ${#rtime} -eq 0 ]; then
    echo“"请输入正确的表明和时间！"
    exit 0
  else
    rtime=$rtime
    flag=0
    for i in ${!tablelist[@]}
    do
      if [ "$i" == "$rtable" ]; then
        flag=1
        continue 
      fi
    done
    if [[ $flag -eq 0 ]]; then
      echo“"你输入的表明不存在备份目录中，请检查！"
      exit 0
    else
      rtable=$rtable
    fi
  fi
  
}

checkdir
recover
