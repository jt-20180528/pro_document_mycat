set -e

#基本变量
#ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/'`
ip=192.168.10.150
basedir=/opt/soft/
builddir=$builddir
proRoot=$basedir/$builddir
jarDir=$jardir
sourceCodePath=/opt/soft/jenkins/workspace/gz_op
version=4.0
#dubbourl=$ip:2181,$ip:2182,$ip:2183
dubbourl=172.168.30.252:2181
buildenv=$buildenv

#redis config
#redismonitor=mymaster
redismonitor=redis-master
h1ip=$ip
h2ip=$ip
h3ip=$ip
h1p=26397
h2p=26398
h3p=26399

#amq config
#amqurl="failover:(tcp://$ip:61616,tcp://$ip:61617)"

amqurl=tcp://"$ip":61616
amqname=yt
amqpass=yt123$%^

#mysql config
dburl=172.168.30.30:3306
dbname=root
dbpass=Jt@2018

#rmq config
rmqpgn=mem-cache-producer-group
rmqcgn=mem-cache-producer-group
rmqna="$ip":9876

#jgourpUrl
jgurl="$ip"[7800]
jgroupInitNum=1

defultValue(){
  if [ ${#buildenv} -eq 0 ]; then
    buildenv=test
  fi
  if [ ${#builddir} -eq 0 ]; then
    builddir=projects_test
  fi
  if [ ! -d $basedir/$builddir ]; then
    mkdir $basedir/$builddir
  fi
  proRoot=$basedir/$builddir
}

checkDeploy(){

  if [ ! -d $jarDir ]; then
    echo "不存在jar包目录$jarDir，请检查！"
    exit 0
  else
    cd $jarDir
    if [ ! -d $proRoot ]; then
        mkdir $proRoot
    else
	rm -rf $proRoot
	mkdir $proRoot
    fi
	jarCount=`find ./ -name \*.jar -o -name \*.war|wc -l`
	if [ $jarCount -gt 0 ]; then
	    echo "发现$jarCount个jar开始部署..."
		deploy
		echo "$jarCount个jar部署完毕！"
	else
	  echo "发现路径$jarDir中没有jar,请检查！"
	exit 0
    fi	
  fi
}


publicConfig(){
  #开始替换日志路径
    cd $1
    if [ -f $1/logback.xml ]; then
      echo "开始替换日志路径..."
      sed -i 's#${LOG_DIR}#/opt/logs/sname-sname#g' logback.xml
      sed -i "s#sname-sname#$2#g" logback.xml
    fi
}

#新包部署
deploy(){
    cd $basedir
    if [ ! -d $builddir ]; then
      mkdir $builddir
    fi
    cd $jarDir
    for i in `ls`
    do
	echo "开始部署$i..."
	pname=${i%-*}
	if [ "$buildenv" == "pro" ]; then
          pagname=$pname
        elif [ "$buildenv" == "publictest" ]; then
          pagname=`expr ${pname/"test"/""}`
        else
          pagname=`expr ${pname/"test_op"/"op4.0"}`
        fi
	sourcename=${i%.*}
	if [ ${i##*.} == "jar" ]; then
	  cd $sourceCodePath/`expr ${pname/"$buildenv"_/''}/target` 
	  tar -czvf "$sourcename".tar.gz $sourcename >/dev/null 2>&1
	  cp "$sourcename".tar.gz $basedir/$builddir
	  cd $basedir/$builddir
	  if [ -d $pagname ]; then
	    rm -rf $pagname
	  fi
	  tar -zxvf "$sourcename".tar.gz >/dev/null 2>&1
	  rm -rf "$sourcename".tar.gz
	  mv $sourcename $pagname

	  publicConfig $proRoot/$pagname/classes `expr ${pname/"$buildenv"_op-/''}`
	fi
	if [ ${i##*.} == "war" ]; then
	  cd $sourceCodePath/`expr ${pname/"$buildenv"_/''}/target`
	  cp "$sourcename".war $basedir/$builddir
	  cd $basedir/$builddir
	  if [ ! -d $pagname ]; then
            mkdir $pagname
          fi
          unzip "$sourcename".war -d $pagname >/dev/null 2>&1
          rm -rf "$sourcename".war
	  publicConfig $proRoot/$pagname/WEB-INF/classes `expr ${pname/"$buildenv"_op-/''}`
        fi
    done
}

#打包、部署到测试服务器
buildToTestServer(){
  echo "开始打包部署到测试服务器！"
  if [ ! -d $proRoot ]; then
    mkdir $proRoot
  else
    echo "开始打包部署！"
    cd $basedir
    if [ -f "$builddir".tar.gz ]; then
      rm -rf "$builddir".tar.gz
    fi
    tar -czvf "$builddir".tar.gz $builddir >/dev/null 2>&1
  fi
  #进入测试服务器进行部署
  echo "复制部署项目到测试服务器！"
  if [ "$buildenv" == "pro" ]; then
    scp "$builddir".tar.gz $ip:/root/updateOp/projects
  else
    cp "$builddir".tar.gz /root/updataOp4.2/projects
  fi
  #ssh $ip "cd /root/servers/ && `export builddir=$builddir` sh ./server.sh"
}

defultValue
checkDeploy
buildToTestServer




