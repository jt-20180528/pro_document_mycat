#jmeter service run scripts

set -m

func1(){
  p1=$1
  if [ ${#p1} -gt 0 ]; then
    processNum=`ps -ef | grep '/opt/lujun/soft/jmeter-4.0/bin/ApacheJMeter.jar' | grep -v grep | awk '{print $2}'`
    if [ $p1 == "start" ]; then
          if [ ${#processNum} -gt 0 ]; then
            echo "服务已经启动，进程号：$processNum"
          else
            echo "准备启动测试服务..."
			echo "开始清空上一次日志和测试结果..."
			>log.jtl
			>jmeter.log
			echo "日志清理完毕，正在启动测试服务..."
            jmeter -n -t C1内测CT-KG多单投注.jmx -l log.jtl &
            echo "启动服务成功！进程号：`ps -ef | grep '/opt/lujun/soft/jmeter-4.0/bin/ApacheJMeter.jar' | grep -v grep | awk '{print $2}'`"
	      fi
        elif [ $p1 == "stop" ]; then
          if [ ${#processNum} -gt 0 ]; then
            echo "正在停止服务..."
                kill -9 $processNum
                echo "服务已经停止！"
          else
            echo "服务已经停止！"
          fi
        elif [ $p1 == "status" ]; then
          if [ ${#processNum} -gt 0 ]; then
            echo "服务已经启动，进程号：$processNum"
          else
            echo "服务已关闭！"
          fi
        elif [ $p1 == "tail" ]; then
          if [ ${#processNum} -gt 0 ]; then
            tailLog
          else
            echo "服务没有启动，请先启动服务！"
          fi
        else
          echo "只能输入{start | status | stop | tail}, 请检查！"
        fi
  else
    echo "请输入{start | status | stop | tail}！"
  fi
}

tailLog(){
  tail -f log.jtl
}

func1 $1
