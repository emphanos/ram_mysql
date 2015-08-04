sudo /etc/init.d/mysql stop
sudo umount /var/ramfs
sudo mkdir /var/ramfs
mount | grep "/var/ramfs" && echo "PROGRESS: looks like /var/ramfs is already mounted, something is fishy"; umount /var/ramfs;sudo mount -t ramfs -o size=1G ramfs /var/ramfs/ || sudo mount -t ramfs -o size=5G ramfs /var/ramfs/
#sudo service mysql-server stop
sudo /etc/init.d/mysql stop
sudo cp -R /var/lib/mysql /var/ramfs/
sudo chown -R mysql:mysql /var/ramfs/
#in file /etc/mysql/my.cnf
#Find line with 'datadir' definition(it will look something like datadir = /var/lib/mysql) and change it to
#datadir = /var/ramfs/mysql
#sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf-orig
sudo sed -i'-orig' 's/datadir.*.=.*/datadir = \/var\/ramfs\/mysql/g' /etc/mysql/my.cnf
sudo sed -i'-orig' 's/tmpdir.*.=.*/tmpdir = \/var\/ramfs/g' /etc/mysql/my.cnf

#Next step is to tune apparmor settings:

#sudo vim /etc/apparmor.d/usr.sbin.mysqld
##Add the following few lines just before the closing curly braces:
#/var/ramfs/mysql/ r,
#/var/ramfs/mysql/*.pid rw,
#/var/ramfs/mysql/** rwk,
#echo "  /var/ramfs/mysql/ r,
#  /var/ramfs/mysql/*.pid rw,
#  /var/ramfs/mysql/** rwk," > mod_apparmor_usr.sbin.mysqld
#sudo grep -q '/var/ramfs/mysql' /etc/apparmor.d/usr.sbin.mysqld && echo "PROGRESS: apparmor profile already modified nothing to do here " || sudo sed -i'-orig' '/  \/var\/lib\/mysql\/\*\* rwk,/r mod_apparmor_usr.sbin.mysqld' /etc/apparmor.d/usr.sbin.mysqld
#
#Looks like we're done with settings, let's see if it will work:

#sudo /etc/init.d/apparmor restart
#disable sanity checking using df which will fail for ramfs
sudo grep -q '#if LC_ALL=C BLOCKSIZE= df' /etc/init.d/mysql && echo "PROGRESS: already using modified mysql init.d script bypassing diskspace check" || sudo cp /etc/init.d/mysql /etc/init.d/dis.mysql; sudo cp init.mysql /etc/init.d/mysql
sudo /etc/init.d/mysql start
mysql -e "show variables where Variable_name = 'datadir';"
mysql -e "show variables where Variable_name = 'tmpdir';"

#If mysql daemon starts(double check /var/log/mysql.err for any errors)
#and you can connect to it, most likely now we're running fully off of a RAM device.
#To double check it, run this from mysql client:
#mysql -e "show variables where Variable_name = 'datadir';"
