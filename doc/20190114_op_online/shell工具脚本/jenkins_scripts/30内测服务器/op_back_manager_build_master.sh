set -e

## globle contents
sourceCodePath=/opt/soft/jenkins/workspace/op_back_manager/op-admin-vue
packagename=backVue
targetip=192.168.10.150
buildenv=$env

#进行打包、发送到测试服务器并触发jmeter测试、定时检测项目日志，发现错误发送邮件到指定邮箱
deployPro(){
  if [ ! -d $sourceCodePath ]; then
    echo "没有源码路径$sourceCodePath,请检查！"
    exit 0
  fi
  echo "开始构建项目op_back_manager..."
  cd $sourceCodePath
  npm install
  npm run build
  echo "项目op_back_manager构建完毕，开始发送到目标服务器！"
  if [ ! -d $sourceCodePath/$packagename ]; then
    echo "没有找到构建包$sourceCodePath/$packagename,可能构建失败，请检查！"
    exit 0
  fi
  if [ -f "$packagename".tar.gz ]; then
    rm -rf "$packagename".tar.gz
  fi
  chmod 777 $packagename
  tar -czvf "$packagename".tar.gz $packagename
  chmod 777 "$packagename".tar.gz
  if [ "$buildenv" == "pro" ]; then
    scp "$packagename".tar.gz $targetip:/root/updateOp/projects
  else
    cp "$packagename".tar.gz /root/updataOp4.2/projects
  fi
}


deployPro



