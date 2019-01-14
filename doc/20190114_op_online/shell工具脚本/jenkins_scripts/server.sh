#jenkins 启动，停止脚本
func1(){
 p1=$1
 jenkinsTomcatDir=/opt/soft/jenkins/jenkins-tomcat-8.0.53/bin
 currentStatus=`ps -ef | grep tomcat|grep /opt/soft/jenkins/jenkins-tomcat-8.0.53/ | grep -v "grep" | awk '{print $2}'`
 if [ ${#p1} -eq 0 ]; then
    echo "please input option commend：start | status | stop !"
    exit
 elif [ $p1 == "start" ]; then
    if [ ${#currentStatus} -eq 0 ]; then
       echo "准备启动jenkins tomcat服务..."
       sh $jenkinsTomcatDir/startup.sh
       echo "服务启动完毕！"
    else
       echo "service has already running and progress $currentStatus !"
       exit
    fi
 elif [ $p1 == "status" ]; then
    if [ ${#currentStatus} -eq 0 ]; then
       echo "service not running!"
    else
       echo "service is running and progress $currentStatus !"
       exit
    fi
 elif [ $p1 == "stop" ]; then
    if [ ${#currentStatus} -eq 0 ]; then
       echo "service has already stop!"
    else
       echo "准备停止jenkins tomcat服务..."
       sh $jenkinsTomcatDir/shutdown.sh
       echo "服务停止完毕！"
       exit
    fi
 else
    echo "only input start | status | stop , please check your input!"
 fi
}


func1 $1
