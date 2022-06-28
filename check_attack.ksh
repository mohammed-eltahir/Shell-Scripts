#!/bin/ksh

 

##############################################################################
#       Script to check possible DOS against any Apache
#       Author: Mr. Mohammed Eltahir
#       Pls notify befoRe edit meltahir@emirates.net.ae
#       Last Update: 08 DEC 2020 c
##############################################################################
# Change TH ( Threshold for number of conncurret connections )
#
 

IP1=5.195.197.31
IP2=5.195.197.32
IP3=5.195.197.33
IP4=5.195.197.34
IP5=5.195.197.35
IP6=5.195.197.2

 

TH=50

WS=`uname -n`


MY_EMAIL=my_email@mydomain.com
SENDER_EMAIL=sender_email@myomain.com
Subject="Possible attack in $WS"
EMAILFILE=/tmp/attack.webhosting

cat /dev/null > /tmp/attack.webhosting

sendemail()
        {
        if [ -s $EMAILFILE ]
                then
                echo "sending Email: "
                /admin/mailme localhost $SENDER_EMAIL $MY_EMAIL "$Subject" $EMAILFILE
                fi

        }

 

for IP in $IP1 $IP2 $IP3 $IP4 $IP5 $IP6
do
        echo "Checking using netstat ...."
        apache=`grep $IP:80 /www/apache[1-7]/conf/httpd.conf /www/httpd-cpanel/conf/httpd.conf |cut -d/ -f3`
        np=`ps -eaf | grep -v grep | grep $apache/ |wc -l`
        echo "Established connections on Apache $apache = $np"

        echo "checking Established connection on  IP: $IP ....."
        EST=`netstat -an | grep "$IP" | grep EST | awk '{print $2}' | cut -d. -f1-4 |sort | uniq -c | sort -nr | head -10`
        echo   "$EST"

        if [ -n "$EST" ]
                then
                echo "ESTablished : $EST"
                counter=`echo "$EST" |wc -l|sed "s/ //g"`
                if [ -n "$counter" ]
                        then
                        echo "counter: $counter"
                        i=1
                        while [ $i -le $counter ]
                                do
                                NO_EST=`echo $EST|awk '{print $1}'|head -$i|tail -1`
                                attacker=`echo $EST|awk '{print $2}'|head -$i|tail -1`
                                if [ $NO_EST -gt $TH ]
                                        then
                                        echo "`date`: possible EST attack originating from: $attacker received $NO_EST EST on
Apache: $apache ($IP)" >> $EMAILFILE
                                fi
                                i=`expr $i + 1`
                        done
                fi
        fi

 
        echo "checking SYN_RCVD on IP: $IP  ............."
        SYN_RCVD=`netstat -an | grep "$IP" | grep SYN_RCVD | awk '{print $2}' | cut -d. -f1-4 |sort | uniq -c | sort -nr|head -10`
        if [ -n "$SYN_RCVD" ]
                then
                echo "SYN_RCVD: $SYN_RCVD"
                counter=`echo "$SYN_RCVD"|wc -l`
                if [ -n "$counter" ]
                        then
                        echo "counter: $counter"
                        i=1
                        while [ $i -le $counter ]
                                do
                                NO_SYN_RCVD=`echo $SYN_RCVD|awk '{print $1}'|head -$i|tail -1`
                                attacker=`echo $SYN_RCVD|awk '{print $2}'|head -$i|tail -1`
                                if [ $NO_SYN_RCVD -gt $TH ]
                                        then
                                        echo "`date`: possible attack originating from: $attacker received $NO_SYN_RCVD SYN_RCVD on Apache: $apache ($IP)"  >> $EMAILFILE
                                fi
                                i=`expr $i + 1`
                        done
                fi
        fi

        echo "============================"
        echo ""
        done
 

sendemail
