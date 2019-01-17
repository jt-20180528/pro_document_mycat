#currtime=`date +"%Y-%m-%d %H-%M-%S"`
i=20

while [ $i -gt 0 ]; do
sleep 1
echo "当前时间：`date +"%Y-%m-%d %H:%M:%S"`"
echo "剩余【$i】次循环将退出。"
let i--
done
