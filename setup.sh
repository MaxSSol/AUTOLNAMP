#!/bin/bash
apt-get install nginx -y

cp -r./conf/NGINX/nginx.conf /etc/nginx
systemctl enable nginx
systemctl start nginx

apt-get install php php-fpm -y

sudo apt-get install mariadb-server mariadb-client -y
systemctl enable mariadb
systemctl start mariadb

apt-get install php-mysql php-mysqli
systemctl restart php7.4-fpm

apt-get install memcached php-memcached -y
systemctl enable memcached
systemctl start memcached

apt-get install apache2 libapache2-mod-php -y

cp -r ./conf/apache2/ports.conf /etc/apache2/

cp -r ./conf/apache2/dir.conf /etc/apache2/mods-available/

cp -r ./conf/apache2/apache2.conf /etc/apache2/

sudo a2dismod mpm_event

sudo a2enmod mpm_prefork

sudo a2enmod setenvif

sudo systemctl enable apache2
sudo systemctl start apache2

rm /etc/nginx/sites-enabled/default
cp -r./conf/nginx/wordpress /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-enabled/wordpress /etc/nginx/sites-available/
nginx -t
systemctl restart nginx

cp ./conf/apache2/remoteip.conf  /etc/apache2/mods-available/

sudo a2enmod remoteip
sudo systemctl restart apache2

read -p "Enter the name of DB:" nameDB
read -p "Enter the name of user:" name_user
read -sp "Enter the password:" pass
sudo mysql -u root << EOF
CREATE DATABASE $nameDB;
CREATE USER $name_user@'localhost' IDENTIFIED BY "$pass";
GRANT ALL ON $nameDB.* TO $name_user@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
rm -r /var/www/html/
sudo cp -r wordpress /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod -R 755 /var/www/wordpress/

sudo cp ./conf/apache2/000-default.conf /etc/apache2/sites-enabled/

systemctl restart nginx
systemctl restart apache2
