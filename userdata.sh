 ## Update system  
 apt-get update -y  
   
 ## Install Apache  
 sudo apt-get install apache2 apache2-utils -y  
 systemctl start apache2  
 systemctl enable apache2  
   
 ## Install PHP  
 apt-get install php libapache2-mod-php php-mysql -y  

 ## install mysql

 apt-get install mysql-server mysql-client -y 
 
 
 ## create databases
 
mysql -e "CREATE DATABASE kirandb;"
mysql -e "CREATE USER 'kiran'@'%' IDENTIFIED BY 'kiran123';"
mysql -e "GRANT ALL PRIVILEGES ON kirandb.* TO 'kiran'@'%';"
mysql -e "FLUSH PRIVILEGES;"

  ## Install Latest WordPress  
 rm /var/www/html/index.*  
 wget -c http://wordpress.org/latest.tar.gz  
 tar -xzvf latest.tar.gz  
 rsync -av wordpress/* /var/www/html/  
   
 ## Set Permissions  
 chown -R www-data:www-data /var/www/html/  
 chmod -R 755 /var/www/html/  
 
 #create wp config
mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#set database details with perl find and replace
perl -pi -e "s/database_name_here/kirandb/g" /var/www/html/wp-config.php
perl -pi -e "s/username_here/kiran/g" /var/www/html/wp-config.php
perl -pi -e "s/password_here/kiran123/g" /var/www/html/wp-config.php