#!/bin/bash
grep "Failed password for invalid user" /var/log/secure | awk '{print $13}' > SUSPECTED
grep "Failed password" /var/log/secure | grep -v "invalid user" | awk '{print $11}' >> SUSPECTED
cat SUSPECTED | sort > /tmp/tmplist
cat SUSPECTED | sort | uniq > /tmp/tmplist2

iptables -nL|awk '{print $4}'|grep "^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*" | sort | uniq > /tmp/iptableslist

for ip in $( cat /tmp/tmplist2 |awk '{print $1}' )
do
iptablescount=`grep $ip /tmp/iptableslist | wc -l`
failcount=`grep $ip /tmp/tmplist | wc -l`
if [ $failcount -gt 5 ]; then
	if [ $iptablescount -eq 0 ]; then
		iptables -A INPUT -s $ip -j DROP
		iptables -A INPUT -d $ip -j DROP
		iptables -A OUTPUT -s $ip -j DROP
		iptables -A OUTPUT -d $ip -j DROP
	fi
fi
done

iptables-save
service iptables save

rm -rf /tmp/tmplist*
rm -rf /tmp/iptableslist

