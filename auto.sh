#!/bin/bash
apt-get install nginx
rm –r /etc/nginx/nginx.conf
cp –r ./conf/NGINX/nginx.conf /etc/nginx
systemctl enable nginx
systemctl start nginx

apt-get install php php-fpm

apt-get install mariadb-server
systemctl enable mariadb
systemctl start mariadb

apt-get install php-mysql php-mysqli
systemctl restart php7.4-fpm

apt-get install memcached php-memcached
systemctl enable memcached
systemctl start memcached

apt-get install apache2 libapache2-mod-php

cp –r ./conf/apache2/ports.conf /etc/apache2/

cp –r ./conf/apache2/dir.conf /etc/apache2/mods-available/

cp –r ./conf/apache2/apache2.conf /etc/apache2/

sudo a2dismod mpm_event

sudo a2enmod mpm_prefork

sudo a2enmod setenvif

sudo systemctl enable apache2
sudo systemctl start apache2

cp –r ./conf/nginx/default /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

cp –r ./conf/apache2/ remoteip.conf  /etc/apache2/mods-available/

sudo a2enmod remoteip
sudo systemctl restart apache2

read –p “Enter the name of DB:” nameDB
read -p “Enter the name of user:” name_user
read –sp “Enter the password:” pass
sudo mysql –u root << EOF
CREATE DATABASE $nameDB;
CREATE USER $name_user@'localhost' IDENTIFIED BY '$pass';
GRANT ALL ON $nameDB.* TO $name_user@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
EOF

sudo cp –r wordpress /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/wordpress/
sudo chmod -R 755 /var/www/wordpress/

sudo cp –r ./conf/apache2/000-default.conf /etc/apache2/sites-enabled/

systemctl restart nginx
systemctl restart apache2


