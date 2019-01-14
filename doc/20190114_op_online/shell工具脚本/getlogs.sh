#!/bin/sh

#获取所有机器日志脚本

alllogdir=/root/alllogs
currenttime=`date "+%Y-%m-%d"`
declare -A promap=()  
ipprefix=192.168.10.
logtime=$1

config(){
  promap["core"]="153,154,155"
  promap["login"]="157"
  promap["mc"]="151,152"
  promap["mem-cache"]="166"
  promap["third"]="162"
  promap["open"]="159"
  promap["oper"]="160"
  promap["pay"]="161"
  promap["report"]="158"
}

checkdir(){
  if [ ${#logtime} -eq 0 ]; then
    echo "========开始获取今天日志========="
    echo "========如果需要获取制定天日志，请在脚本后添加:****-**-**========="
  else
    echo "========开始获取$logtime日志========="
    currenttime=$logtime
  fi
  if [ ! -d $alllogdir ]; then
    mkdir $alllogdir
    cd $alllogdir
	mkdir $currenttime
  else
    cd $alllogdir
    if [ ! -d $currenttime ]; then
	  mkdir $currenttime
	fi
  fi
}

getlogs(){
  for i in ${!promap[@]}  
  do 
    value=${promap[$i]}
	hosts=(${value//,/ })
	cd $alllogdir/$currenttime
	if [ ! -d $i ]; then
            mkdir $i
          else
            rm -rf $i
            mkdir $i
          fi
	for n in ${hosts[@]} 
	do 
	  echo "复制日志$i来自$ipprefix$n"
	  cd $alllogdir/$currenttime/$i
	  if [ ! -d "$i"-$n ]; then
	    mkdir "$i"-$n
	  else
 	    rm -rf "$i"-$n
	    mkdir "$i"-$n
  	  fi
	  cd "$i"-$n
	  scp $ipprefix"$n":/opt/logs/"$i"/*"$currenttime".log ./
	  if [ "$?" == "1" ]; then
	    scp $ipprefix"$n":/root/"$i"/*"$currenttime".log ./
	  fi
	done
  done
	  
}

checkdir
config
getlogs


