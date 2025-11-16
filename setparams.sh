#!/bin/bash
lighterDir="/data/lighter"
accountName="account"
accounts=$(ls -l $lighterDir |grep ^d | grep $accountName | awk '{print $NF}')
for account in $accounts; do
        cd $lighterDir/$account
	sed -i 's/LIMIT_ORDER_CLOSE_TIMEOUT=.*/LIMIT_ORDER_CLOSE_TIMEOUT=5/' .env
	sed -i 's/POSITION_VALUE_MIN=.*/POSITION_VALUE_MIN=188/' .env
    sed -i 's/POSITION_VALUE_MAX=.*/POSITION_VALUE_MAX=198/' .env
	sed -i 's/WASH_MARKET_SYMBOL=.*/WASH_MARKET_SYMBOL=BCH,DOT,TRUMP,UNI,APT,ONDO,ARB,LINK,AVAX,AAVE/' .env
    sed -i 's/HOLDING_TIME_MIN=.*/HOLDING_TIME_MIN=45678/' .env
    sed -i 's/HOLDING_TIME_MAX=.*/HOLDING_TIME_MAX=123456/' .env
	sed -i 's/EMERGENCY_STOP_LOSS_USDC=.*/EMERGENCY_STOP_LOSS_USDC=-18.0/' .env
done