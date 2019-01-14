#this is xtrabackup scripts
set -e 

backupdir=/home/mysql/all_backup_xtrabackup
backupname=backup_`date +"%Y%m%d-%H%M%S"`
cnfpath=/etc/my3307-slave.cnf
dbname=t_user1
dbpass=123456
socketpath=/home/mysql/mysql-8.0.12-slave/tmp/mysql.sock
pkgdate=20
cleandate=`date -d "20 day ago" +"%Y-%m-%d"`

backup(){
  echo "=======开始全量备份数据库======="
  xtrabackup --defaults-file=$cnfpath --user=$dbname --password=$dbpass --socket=$socketpath --backup --target-dir=$backupdir/$backupname
  echo "=======数据库备份完毕！======="
  echo "=======开始打包备份文件！======="
  backupnamepkg="$backupname".tar.gz
  tar -zcvf $backupnamepkg $backupname
  rm -rf $backupname
  echo "=======备份打包完毕！======="
  echo "=======备份路径：$backupdir/$backupnamepkg======="
  
}

checkdir(){
  if [ ! -d $backupdir ]; then
    mkdir $backupdir
  fi
  cd $backupdir
  if [ ! -d $backupname ]; then
    mkdir $backupname
  else
    rm -rf $backupname
    mkdir $backupname
  fi
  if [ ! -f $cnfpath ]; then
    echo "不存在配置文件：$cnfpath，请检查！"
    exit 0
  fi
 # if [ ! -f $socketpath ]; then
 #   echo "不存在配置文件：$socketpath，请检查！"
 #   exit 0
 # fi
}

cleanbackup(){
  #清理大于20天的全量包
  echo "=======开始清理$cleandate日以上的备份======="
  cd $backupdir 
  date0=`echo $cleandate | sed s/-//g`
  for i in `ls`
  do
    file0=`expr ${i/"backup_"/""}`
    file1=${file0%-*}
    if [[ "$file1" -lt "$date0" ]]; then
      rm -rf $i
      echo "=======删除备份文件：$i======="
    fi
  done
 echo "=======过期的备份文件清理完毕!======="
}

checkdir
backup
cleanbackup
