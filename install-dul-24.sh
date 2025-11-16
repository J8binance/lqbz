#!/bin/bash
#
apt update &> /dev/null
if [ $? -eq 0 ]; then
    echo "更新系统缓存成功"
else
    echo "更新系统失败"
    exit 9
fi
apt install git python-is-python3 screen python3.12-venv -y &> /dev/null
if [ $? -eq 0 ]; then
    echo "安装系统工具成功"
else
    echo "安装系统工具失败"
    exit 9
fi
lighterDir="/data/lighter"
lighterLogDir="$lighterDir/log"
if [ ! -d $lighterLogDir ];then
        mkdir -p $lighterLogDir
fi

#拉取代码
if [ -d lighter-prep-own ];then
	cd lighter-prep-own
	git pull &> /dev/null
	cd ..
else
	git clone git@github.com:yimings2000/lighter-prep-own.git &> /dev/null
	if [ $? -eq 0 ]; then
    		echo "拉取代码成功"
	else
    		echo "拉取代码失败"
    		exit 9
	fi
fi
#确认帐户数量
num=$(grep 'account' info-dul.txt | wc -l)
if [ $num -eq 0 ]; then
	echo "请准备帐户文件info-dul.txt"
	exit 9
fi
accountNameList=$(grep 'account' info-dul.txt)
accountNameList="${accountNameList//[\[\]]}"
for name in $accountNameList; do
	echo "开始配置$name帐户"
	if [ -d $name ];then
		echo "$name帐户已存在."
		continue
	fi
	cp -r lighter-prep-own $name
	cp $name/.env.example $name/.env
	cd $name/
	python3 -m venv venv &> /dev/null
	if [ $? -eq 0 ];then
		echo $"创建虚拟环境成功"
	else
		echo $"创建虚拟环境失败"
		exit 9
	fi
	source venv/bin/activate
	pip install -r requirements.txt &> /dev/null
	if [ $? -eq 0 ];then
		echo $"安装依赖成功"
	else
		echo $"安装依赖失败"
		exit 9
	fi
	source venv/bin/activate
	cd ..
	#获取帐户所有变量
	accountConfig=$(awk -v section="$name" '/^\[.*\]$/ { in_section = ($0 == "[" section "]") } in_section { print }' info-dul.txt)
	set -- $accountConfig
	shift
	for arg in "$@"; do
    		if [[ "$arg" == *=* ]]; then
        		declare "$arg"
    		fi
	done
	#修改代理配置文件
	sed -i \
    		-e "/'name': '代理1'/,/'protocol'/ s/'host': '[^']*'/'host': '$PROXY1_HOST'/" \
    		-e "/'name': '代理1'/,/'protocol'/ s/'port': [0-9]\+/'port': $PROXY1_PORT/" \
    		-e "/'name': '代理1'/,/'protocol'/ s/'username': '[^']*'/'username': '$PROXY1_USERNAME'/" \
    		-e "/'name': '代理1'/,/'protocol'/ s/'password': '[^']*'/'password': '$PROXY1_PASSWORD'/" \
    		-e "/'name': '代理1'/,/'protocol'/ s/'static_ip': '[^']*'/'static_ip': '$PROXY1_HOST'/" \
    		"$name/proxy_config.py"
	if [ $? -eq 0 ];then
		echo "修改代理成功"
	else
		echo "修改代理失败"
		exit 9
	fi
	sed -i \
    		-e "/'name': '代理2'/,/'protocol'/ s/'host': '[^']*'/'host': '$PROXY2_HOST'/" \
    		-e "/'name': '代理2'/,/'protocol'/ s/'port': [0-9]\+/'port': $PROXY2_PORT/" \
    		-e "/'name': '代理2'/,/'protocol'/ s/'username': '[^']*'/'username': '$PROXY2_USERNAME'/" \
    		-e "/'name': '代理2'/,/'protocol'/ s/'password': '[^']*'/'password': '$PROXY2_PASSWORD'/" \
    		-e "/'name': '代理2'/,/'protocol'/ s/'static_ip': '[^']*'/'static_ip': '$PROXY2_HOST'/" \
    		"$name/proxy_config.py"

	#修改策略参数
	for config in $accountConfig; do
		if [[ $config =~ account ]]; then
			continue
		# 自启动逻辑暂时路过
		elif [[ $config =~ AUTO_START_SERVICE ]]; then
			continue
		else
			filed=$(echo $config | awk -F'=' '{print $1}')
			if [[ $filed == "HOLDING_TIME" ]];then
				sed -i -r "s/^HOLDING_TIME=60.*/$config/" $name/.env
			elif [[ $filed == "HOLDING_TIME_MIN" ]];then
				sed -i -r "s/^HOLDING_TIME_MIN=60.*/$config/" $name/.env
			elif [[ $filed == "HOLDING_TIME_MAX" ]];then
				sed -i -r "s/^HOLDING_TIME_MAX=120.*/$config/" $name/.env
			else
    				sed -i -r "s/^$filed.*/$config/" $name/.env
    				if [ $? -eq 0 ];then
    					echo "修改$filed成功"
    				else
    					echo "修改$filed失败"
    					exit 9
				fi
    			fi
		fi
	done
	# 服务自启动逻辑
	if [[ $AUTO_START_SERVICE == true ]];then
        	cd $name
        	#判断screen是否已经运行
        	screen -ls | grep $name &> /dev/null
        	if [ $? -eq 0 ]; then
        		echo "$name 服务已经启动，不需要重复启动"
        		cd ..
        		echo "结束配置$name帐户"
        		continue
        	fi
        	#screen -dmS $name sh -c 'python dual_account_wash_trading.py'
		screen -dmS "$name" bash -c "python dual_account_wash_trading.py >> \"account.log\" 2>&1"
        	cd ..
		echo "服务被定义为自启动，结束配置$name帐户"
	else
		echo "服务被定义为不启动，结束配置$name帐户"
	fi
	sleep 3
done
