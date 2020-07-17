#!/bin/bash
apt update
echo "Install NGINX"
#install nginx
apt-get install nginx -y

#cp our config
cp -r ./conf/NGINX/nginx.conf /etc/nginx
systemctl enable nginx
systemctl start nginx
#install php
apt-get install php php-fpm -y

#install MYSQL
sudo apt-get install mariadb-server mariadb-client -y
systemctl enable mariadb
systemctl start mariadb

#install php-mysql and php-mysqli
apt-get install php-mysql php-mysqli
systemctl restart php7.4-fpm

#install memcached
apt-get install memcached php-memcached -y
systemctl enable memcached
systemctl start memcached

echo "Install Apache2"
#install apache2
apt-get install apache2 libapache2-mod-php -y
#copy our config files for apache2
cp -r ./conf/apache2/ports.conf /etc/apache2/

cp -r ./conf/apache2/dir.conf /etc/apache2/mods-available/

cp -r ./conf/apache2/apache2.conf /etc/apache2/

sudo a2dismod mpm_event
sudo systemctl enable apache2
sudo systemctl start apache2
#delete default config
rm /etc/nginx/sites-enabled/default
#copy our new config
cp -r ./conf/nginx/wordpress /etc/nginx/sites-enabled/
#create the link
ln -s /etc/nginx/sites-enabled/wordpress /etc/nginx/sites-available/
#cheak
nginx -t
systemctl restart nginx

cp -r ./conf/apache2/remoteip.conf  /etc/apache2/mods-available/

sudo a2enmod remoteip
sudo systemctl restart apache2

read -p "Enter the name of DB:" nameDB
read -p "Enter the name of user:" name_user
read -sp "Enter the password:" pass
#create DB
sudo mysql -u root << EOF
CREATE DATABASE $nameDB;
CREATE USER $name_user@'localhost' IDENTIFIED BY "$pass";
GRANT ALL ON $nameDB.* TO $name_user@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
#delete defoult folder
rm -r /var/www/html/
sudo cp -r wordpress /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod -R 755 /var/www/wordpress/

sudo cp -r ./conf/apache2/000-default.conf /etc/apache2/sites-enabled/

systemctl reload nginx
systemctl reload apache2

