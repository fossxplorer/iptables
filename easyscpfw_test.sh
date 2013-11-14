#!/usr/bin/env bash
action=$1
service=$2
echo "Arg1 is $action and arg2 is $service"
# Daemons and corresponding port(s)
sshd="22"
easyscp="7777 7778"
httpd="80 443"
smtp="25 587 465"
imap="143 993"
pop="110 995"
bind="53"
proftpd="21"
# service group and corresponding ports which can be from multiple daemons 
web="$httpd $easyscp"
mail="$smtp $imap $pop"
ssh="$sshd"
dns="$bind"
ftp="$proftpd"
# Associative array with services as keys and their corresponding ports as value.
declare -A daemonports
daemonports=(
[web]="$web"
[mail]="$mail"
[ssh]="$ssh"
[dns]="$dns"
[ftp]="$ftp"
)
#First switch to determine rule action, i.e initial/add/remove
case $action in
intial)
echo "Adding rules"
# iptables example configuration script
# Flush all current rules from iptables
iptables -F
#Allow SSH on tcp port 22
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# Set default policies for INPUT, FORWARD and OUTPUT chains
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
# Set access for localhost
iptables -A INPUT -i lo -j ACCEPT
# Accept packets belonging to established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Save settings
/sbin/service iptables save > /dev/null

# END initial rules
;;

add|remove)
# Switch inside action add/remove to determine service to add rules for, i.e web/mail/ftp etc
# Delete rules for given service
if [[ $action == "add" ]]
then
    switch="A"
    actiontext="Adding"
elif [[ $action == "remove" ]]
then
    switch="D"
    actiontext="Removing"
fi

case $service in
web)

echo "$actiontext $service and ports ${web[@]}"
for port in ${web[@]}
do
#iptables -A INPUT -p tcp --dport $port -j ACCEPT
iptables -$switch INPUT -p tcp --dport $port -j ACCEPT
done
;;

mail)
for port in ${mail[@]}
do
#iptables -A INPUT -p tcp --dport $port -j ACCEPT                                                                                                                   
iptables -$switch INPUT -p tcp --dport $port -j ACCEPT
done
;;

dns)
for port in ${dns[@]}
do
#iptables -A INPUT -p tcp --dport $port -j ACCEPT                                                                                                                   
iptables -$switch INPUT -p tcp --dport $port -j ACCEPT
done
;;




ftp)
for port in ${ftp[@]}
do
#iptables -A INPUT -p tcp --dport $port -j ACCEPT                                                                                                                   
iptables -$switch INPUT -p tcp --dport $port -j ACCEPT
done
;;

esac

/sbin/service iptables save > /dev/null
;;

esac


