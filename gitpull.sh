#!/bin/bash
lighterDir="/data/lighter"
accountName="account"
accounts=$(ls -l $lighterDir |grep ^d | grep $accountName | awk '{print $NF}')
for account in $accounts; do
        cd $lighterDir/$account
        git pull
done
