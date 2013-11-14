#!/usr/bin/env bash

action=$1
service=$2
echo "Arg1 is $action and arg2 is $service"
#
# Daemons and corresponding port(s)
#
sshd="22"
easyscp="7777 7778"
httpd="80 443"
smtp="25 587 465"
imap="143 993"
pop="110 995"
bind="53"
#
# service group and corresponding ports which can be from multiple daemons 
#
web="$httpd $easyscp"
mail="$smtp $imap $pop"
ssh="$sshd"
dns="$bind"
#
# Associative array with services as keys and their corresponding ports as value.
#
declare -A daemonports
daemonports=(
[web]="$web"
[mail]="$mail"
[ssh]="$ssh"
[dns]="$dns"
)
#
# Print the whole key->value
#
#for i in ${daemonports[@]}; do echo $i;done

#First switch to determine rule action, i.e initial/add/remove
case $action in
intial)
echo "Adding rules"
#
# iptables example configuration script
#
# Flush all current rules from iptables
#
iptables -F

#Allow SSH on tcp port 22
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#
# Set access for localhost
#
iptables -A INPUT -i lo -j ACCEPT
#
# Accept packets belonging to established and related connections
#
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
# Save settings
#
/sbin/service iptables save
#
#List rules
#
#iptables -L -v
;;
add|remove)
# Switch inside action add to determine service to add rules for, i.e web/mail/ftp etc
#                                                                                                                                                                   # Delete a rule                                                                                                                                                     #   
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
esac

;;
esac


