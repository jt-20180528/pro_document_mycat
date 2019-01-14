set -e

#mysql recover all data script

mysqlbase=/home/mysql/mysql-8.0.12-slave
allbackupdir=/home/mysql/all_backup_xtrabackup
beforeday=`date -d "1 day ago" +"%Y-%m-%d"`
today=`date +"%Y%m%d%H%M%S"`
recoverdate=$beforeday
mysqlcnfpath=/etc/my3307-slave.cnf

recover(){
  recoverpkg=""

  if [ "${affirm}" == "y" ]; then
    echo "开始还原$recoverdate之前的数据..."
    cd $allbackupdir
    date0=`echo $recoverdate | sed s/-//g`
    for i in `find ./ -name "*$date0*"`
    do
      recoverpkg=$i
      echo "发现还原包：$i，开始还原..."
      break
    done
    if [ ${#recoverpkg} -eq 0 ]; then
      echo "没有发现还原包，请检查还原日期或者联系管理员！"
      exit 0
    fi
    tar -zxvf $recoverpkg
    foldername0=`echo ${recoverpkg##*/}`
    foldername1=`echo ${foldername0%%.*}`
    #进入mysqldata目录开始备份，并还原
    #关闭数据库
    cd $mysqlbase
    tar -czvf data_tmp_$today.tar.gz data
    rm -rf data
    mkdir data
    recoversql
    chown -R mysql:mysql data
    service mysql restart
    echo "======$recoverdate之前的数据还原成功！======"
    cd $allbackupdir
    rm -rf $foldername1
    exit 0
  else
    echo "已经退出数据库恢复，如需帮助，请联系管理员！"
    exit 0
  fi
}

recoversql(){
  echo "----defaults-file=$mysqlcnfpath --copy-back --target-dir=$allbackupdir/$foldername1--"
  xtrabackup --defaults-file=$mysqlcnfpath --copy-back --target-dir=$allbackupdir/$foldername1
}

tipandcheck(){
  if [ ! -d $mysqlbase ]; then
    echo "没有mysql安装目录：$mysqlbase，请检查！"
    exit 0
  fi
  if [ ! -f $mysqlcnfpath ]; then
    echo "没有mysql配置文件：$mysqlcnfpath，请检查！"
    exit 0
  fi
  if [ ! -d $allbackupdir ]; then
    echo "没有备份文件目录：$allbackupdir，请检查！"
    exit 0
  fi
  read -t 30 -p "进行数据库还原会重启数据库，是否继续，y / n ? " check
  if [ "${check}" == "n" ]; then
    echo "已经退出数据库恢复，如需帮助，请联系管理员！"
    exit 0
  fi
  read -t 30 -p "请输入恢复日期，默认不输入则恢复昨天最近一次全量备份数据，格式：xxxx-xx-xx,并确认你输入的日期是最近30天之内,如需退出，输入：n " r_date
  if [ "$r_date" == "n" ]; then
    echo "已经退出数据库恢复，如需帮助，请联系管理员！"
    exit 0
  elif [ ${#r_date} -eq 0 ]; then
    read -t 30 -p "你将恢复$beforeday之前的数据！是否继续: y / n ?" affirm
  else
    #正则检查日期格式
    read -t 30 -p "你将恢复$affirm之前的数据！是否继续: y / n ?" affirm
    recoverdate=$r_date
  fi
}
tipandcheck
recover
