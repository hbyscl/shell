#!/bin/bash
nowtime=`date "+%Y-%m-%d"`
startDate=$1
endDate=$2
errmsg="参数错误,参数1为开始时间时:分:秒，参数2为结束时间时:分:秒，如： $0 10:30:10 10:40:10 "

if test -z $startDate
then
	echo $errmsg
	exit
fi
if test -z $endDate
then
	echo $errmsg
	exit
fi

startSec=`date -d "${nowtime} ${startDate}" +%s`
endSec=`date -d "${nowtime} ${endDate}" +%s`
count=0
for i in `seq $startSec $endSec`
do
	t=`date -d @$i "+%Y-%m-%d %H:%M:%S"`
	tps=`cat /data/tomcat-7/webapps/soter/WEB-INF/logs/soter.log | grep "${t}" | wc -l`
	count=$(($count+$tps))
	echo "时间：${t},并发数：${tps}"
done
echo "当前时间段内请求总数为：${count}"
