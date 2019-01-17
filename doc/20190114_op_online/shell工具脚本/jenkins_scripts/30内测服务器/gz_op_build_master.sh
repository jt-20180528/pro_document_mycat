set -e

## globle contents
sourceCodePath=/opt/soft/jenkins/workspace/gz_op
deplayScript=/opt/soft/env_deploy_test.sh
export buildenv=$env
export builddir=$buildDir
export jardir=/opt/soft/"$buildenv"_jar

#进行打包、发送到测试服务器并触发jmeter测试、定时检测项目日志，发现错误发送邮件到指定邮箱
checkProStart(){
  
  declare -A pros=(["core"]="op-core" ["open"]="op-open" ["login"]="op-login" ["mc"]="op-mc" ["memCache"]="op-mem-cache" ["oper"]="op-oper" ["report"]="op-report" ["pay"]="op-pay" ["third"]="op-third") 
  
  if [ ! -d $sourceCodePath ]; then
    echo "路径$sourceCodePath不存在op项目，请检查！"
  else
    cd $sourceCodePath
	echo "package op pro..."
	#首先构建op-api和op-cache项目
	mvn -f ./op-api/pom.xml clean install & mvn -f ./op-cache/pom.xml clean install >/dev/null 2>&1
	
	#清理jar目录文件
	if [ ! -d $jardir ]; then
          mkdir $jardir
        else
	  rm -rf $jardir
	  mkdir $jardir
        fi
	for key in ${!pros[@]} 
	do
		if [ ! -d $sourceCodePath/${pros[$key]} ]; then
			echo "${pros[$key]}项目不存在，请检查！"
		else 
			packgePro $sourceCodePath/${pros[$key]} ${pros[$key]}
		fi
	done
	
	deplayPro
  fi
}

packgePro(){
	p1=$1
	p2=$2

	jarDir=target
	version=4.0

	#首先构建op-api和op-cache项目
	cd $p1
	echo "开始打包项目$p2..."
	mvn clean package -Dmaven.test.skip=true -P $buildenv >/dev/null 2>&1
	echo "项目$p2打包完毕！"
	
	echo "开始检测部署环境！"
	echo "复制项目$p2到测试环境..."
        if [ -f $sourceCodePath/$p2/$jarDir/"$buildenv"_$p2-$version.war ]; then
	  cp $sourceCodePath/$p2/$jarDir/"$buildenv"_$p2-$version.war $jardir
        fi
        if [ -f $sourceCodePath/$p2/$jarDir/"$buildenv"_$p2-$version.jar ]; then
          cp $sourceCodePath/$p2/$jarDir/"$buildenv"_$p2-$version.jar $jardir
	fi
        echo "项目$p2复制完成！"
	
}

deplayPro(){
	echo "开始部署项目..."
        if [ ! -f $deplayScript ]; then
          echo "没有部署文件$deplayScript，请检查..."
        else
          sh $deplayScript
        fi
}

defultValue(){
  if [ ${#buildDir} -eq 0 ]; then
    export builddir=projects_test
  fi
  if [ ${#buildenv} -eq 0 ]; then
    export buildenv=pro
    export jardir=/opt/soft/"$buildenv"_jar
  fi
  echo "===============项目环境：$buildenv==================="
  echo "===============打包包名：$builddir==================="
}

defultValue
checkProStart




