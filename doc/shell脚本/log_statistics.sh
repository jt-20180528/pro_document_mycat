
fun1(){
j=0
folder_list=()

originalLogDir=/home/lujun/soft/op-project/logs

logDir=/home/lujun/soft/op-project/logs/temp

echo "你的日志统计信息存放路径为：$logDir"

## 判断是否存在这个文件夹，不存在则创建，否则清空
if [ ! -d $logDir ]; then
    mkdir -p $logDir
else
    rm -rf $logDir/*
fi;

echo "----开始统计日志！----"

cd $originalLogDir

for i in `ls *.log`
do
    folder_list[$j]=$i
    j=`expr $j + 1`
done

echo "统计日志个数为：${#folder_list}"

# echo ${folder_list[@]}
# 循环每一个日志文件，并找出关键字写入到另一个文件中
for n in ${folder_list[@]}
do
    echo "开始统计$n异常信息！"
    ## 查找是否有'exception'或'error'关键字
    exceptionNum=`grep -rni 'exception' $n | wc -l`;
    if [ $exceptionNum -gt 0 ]; then
	grep -rni 'exception' $n > $logDir/${n%.*}"-exception-["$exceptionNum"]."${n##*.} 
    fi;

    errorNum=`grep -rni 'error' $n | wc -l`;
    if [ $errorNum -gt 0 ]; then
        grep -rni 'error' $n > $logDir/${n%.*}"-error-["$errorNum"]."${n##*.}
    fi;
	
    echo "异常信息$n统计结束！";
done

echo "----日志统计结束！----"

}

fun2(){
list="rootfs usr data data2"
for i in $list;
do
echo $i is appoint ;
done
}

echo "This is a log statistics scripts!"
echo "Statistics All logs, please input code 【0】"
echo "Statistics one log, please input code 【1】"
read -t 20 -p "Please input your code: " code
if [ $code -eq 0 ]; then
    fun1
elif [ $code -eq 1 ]; then
    originalLogDir=/home/lujun/soft/op-project/logs
    read -t 20 -p "Please input your logName: " logName
    if [ ! -n $logName ]; then
      echo "You have not input logName! exit! please retry!"
      exit;
    fi; 
    
    if [ ! -f $originalLogDir"/"$logName ]; then
      echo "输入的日志文件名称不存在日志路径$originalLogDir中，请确认！"
      exit;
    else
      echo "存在你输入的日志文件，传参函数待完善，请生成整理所有日志！"
    fi;
   
fi;
