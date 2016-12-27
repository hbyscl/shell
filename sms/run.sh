#!/bin/bash
echo "开始发送短信……"
thisShell=$0
errMsg="通过namelist.csv文件发送短信命令为：${thisShell} 或 向指定人员发送短信：${thisShell} 张三 男 18812341234 12"
nowtime=`date "+%Y%m%d%H%M%S"`
function buildSex(){
	sex=$1
	if test -z "$sex"
    then
        echo ""
    fi
    if [ "$sex" = "男" ]
    then
    	echo "先生"
    elif [[ "$sex" = "女" ]]; then
    	echo "女士"
    elif [[ "$sex" = "女士" ]]; then
    	echo "女士"
    elif [[ "$sex" = "先生" ]]; then
    	echo "先生"
    else
    	echo ""
	fi
}
function sendSms(){
	sex=`buildSex $3`
    gbkurl='http://115.29.242.32:8888/smsGBK.aspx'
    result=`curl -d "action=send&userid=922&account=tyjr&password=&mobile=$1&content=尊敬的${2}${sex}，欢迎您参加晚宴。您的座位安排在$4桌，晚宴将于18点正式开始，请您准时赴宴！【】" ${gbkurl}`
    echo $result
    if [[ $result =~ "<returnstatus>Success</returnstatus>" ]]
    then
        echo -e "curl -d 'action=send&userid=922&account=tyjr&password=&mobile=$1&content=尊敬的${2}${sex}，欢迎您参加晚宴。您的座位安排在$4桌，晚宴将于18点正式开始，请您准时赴宴！【】' ${gbkurl} \n${result}" >> info-${nowtime}.log
        echo $1'' >> sended.log
        echo "Success：发送短信成功>姓名：${2}${sex},手机号：$1,座次：$4"
    else
	echo "${result}" >> err.log
        echo "Faild：发送短信失败>姓名：${2}${sex},手机号：$1,座次：$4"
    fi
}
echo "校验参数中……"
if [ -n "$1" ]
then
    name=$1
    sex=$2
    phone=$3
    addr=$4
    if test -z "$sex"
    then
        echo "性别不能为空，${errMsg}"
        exit 1
    fi
    if test -z "$phone"
    then
        echo "手机号码不能为空，${errMsg}"
        exit 1
    fi
    if test -z "$addr"
    then
        echo "座次不能为空，${errMsg}"
        exit 1
    fi
    sendSms $phone $name $sex $addr
    exit
fi
echo "开始读取人员列表……"
for line in $(cat namelist.csv| sed 's/\n//g')
do
    arr=(${line//,/ })
    name=${arr[0]}
    sex=${arr[1]}
  	phone=${arr[2]}
  	addr=${arr[3]}

    count=`cat sended.log | grep "${arr[1]}" | wc -l`
    if [ ! -n  "${count}" ]
    then
     	count=0
	fi
    if [ $count -lt 1 ]
    then
        sendSms $phone $name $sex $addr
    else
        echo "Duplicate：短信已经发送成功>姓名：$name,性别：$sex,手机号：$phone,座次：$addr"
    fi
done
echo "短信发送完成。"
