sudo mkdir /var/ramfs
sudo mount -t ramfs -o size=1G ramfs /var/ramfs/
#sudo service mysql-server stop
sudo /etc/init.d/mysql stop
sudo cp -R /var/lib/mysql /var/ramfs/
sudo chown -R mysql:mysql /var/ramfs/mysql
#in file /etc/mysql/my.cnf
#Find line with 'datadir' definition(it will look something like datadir = /var/lib/mysql) and change it to
#datadir = /var/ramfs/mysql
#sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf-orig
sudo sed -i'-orig' 's/datadir.*.=.*/datadir = \/var\/ramfs\/mysql/g' /etc/mysql/my.cnf

#Next step is to tune apparmor settings:

#sudo vim /etc/apparmor.d/usr.sbin.mysqld
##Add the following few lines just before the closing curly braces:
#/var/ramfs/mysql/ r,
#/var/ramfs/mysql/*.pid rw,
#/var/ramfs/mysql/** rwk,
echo "  /var/ramfs/mysql/ r,
  /var/ramfs/mysql/*.pid rw,
  /var/ramfs/mysql/** rwk," > mod_apparmor_usr.sbin.mysqld
sudo grep -q '/var/ramfs/mysql' /etc/apparmor.d/usr.sbin.mysqld && echo "nothing to do already there" || sudo sed -i'-orig' '/  \/var\/lib\/mysql\/\*\* rwk,/r mod_apparmor_usr.sbin.mysqld' /etc/apparmor.d/usr.sbin.mysqld

#Looks like we're done with settings, let's see if it will work:

sudo /etc/init.d/apparmor restart
sudo /etc/init.d/mysql start

#If mysql daemon starts(double check /var/log/mysql.err for any errors)
#and you can connect to it, mostlikely now we're running fully off of a RAM device.
#To double check it, run this from mysql client:
