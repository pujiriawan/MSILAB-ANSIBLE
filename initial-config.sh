#!/bin/bash
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
systemctl restart sshd

if [ "$HOSTNAME" == "node1" ];
then
hostnamectl set-hostname control.local
yum -y install epel-release
yum install -y ansible
echo "P@55w0rd.1" | passwd --stdin root
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
systemctl restart sshd
else
echo "P@55w0rd.1" | passwd --stdin root
fi

echo "P@55w0rd.1" | passwd --stdin automation
cat <<'AUTO-SHUTDOWN' > /home/automation/auto-shutdown.sh
#!/bin/bash
#
# This is scheduled in CRON using ROOT, it runs every 5 minutes 
# and uses who -a to determine user activity. Once the idle time is
# more than the threshold value it shuts the system down.
#
echo "Start of sidle.shl"

threshold=5
log=/root/sidle.log
userid=automation
inactive=`who -a | grep $userid | cut -c 45-46 | sed 's/ //g'`

if [ "$inactive" != "" ]; then

echo "Idle time is: " $inactive

if [ "$inactive" -gt "$threshold" ]; then
echo "Threshold met so issuing shutdown command"
/sbin/shutdown -h now
else
echo "Bellow threshold"
fi
else
echo "Idle time is: 0"
fi 
echo "Ending"
AUTO-SHUTDOWN
chmod +x /home/automation/auto-shutdown.sh

(crontab -l 2>/dev/null; echo "*/10 * * * * /home/automation/auto-shutdown.sh -with args") | crontab -
(crontab -l 2>/dev/null; echo "59 23 * * * /sbin/shutdown -h now") | crontab -
(crontab -l 2>/dev/null; echo "59 11 * * * /sbin/shutdown -h now") | crontab -
(crontab -l 2>/dev/null; echo "59 15 * * * /sbin/shutdown -h now") | crontab -
echo "Successfully deploy Hand-on Labs Ansible Environtment for RHCE 8 EX294"