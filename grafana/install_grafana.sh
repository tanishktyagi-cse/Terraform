#!/bin/bash

echo "#### Installing Grafana Server"
yum update -y
echo "[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
" > /etc/yum.repos.d/grafana.repo
yum install grafana -y
systemctl daemon-reload

echo "#### Installing Mysql"
amazon-linux-extras install epel -y 
yum install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm -y
yum install mysql-community-server -y
systemctl start mysqld

echo "#### Updating Root Password & Creating Grafana Database"  
mysql_password=$(cat /var/log/mysqld.log | grep "A temporary password" | awk '{print $NF}')
new_password="EW31@Oe9bMqX"
mysql -uroot -p${mysql_password} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_password}';" --connect-expired-password
mysql -uroot -p${new_password} -e "CREATE DATABASE grafana;"
mysql -uroot -p${new_password} -e "CREATE USER 'grafana'@'localhost' IDENTIFIED BY '${new_password}';"
mysql -uroot -p${new_password} -e "grant all privileges on grafana.* to 'grafana'@'localhost';"
mysql -uroot -p${new_password} -e "flush privileges;"

echo "#### Updating Grafana Configuration For Mysql"
sed -i 's/;type = sqlite3/type = mysql/' /etc/grafana/grafana.ini
sed -i 's/;host = 127.0.0.1:3306/host = localhost/' /etc/grafana/grafana.ini
sed -i 's/;name = grafana/name = grafana/' /etc/grafana/grafana.ini
sed -i 's/;user = root/user = grafana/' /etc/grafana/grafana.ini
sed -i "s/;password =/password = ${new_password}/g" /etc/grafana/grafana.ini

echo "#### Restarting Grafana Server"
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server
systemctl restart grafana-server