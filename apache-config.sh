# referência principal: https://community.jboss.org/wiki/UsingModjk12WithJBoss?_sscc=t

APACHE_HOME=/etc/apache2

sudo apt-get update
sudo apt-get install apache2-prefork-dev
sudo apt-get install g++
sudo apt-get install libtool

# compilando mod_jk...

# Considerando $APACHE_HOME como $APACHE_HOME
sudo mkdir $APACHE_HOME/modules
sudo mkdir $APACHE_HOME/conf
sudo mkdir $APACHE_HOME/logs
sudo mkdir $APACHE_HOME/run

# baixando source do mod_jk
cd ~/Downloads
wget http://ftp.unicamp.br/pub/apache//tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.37-src.tar.gz

# considerando versão 1.2.37
cd tomcat-connectors-1.2.37-src/native

# considerando apxs2 em /usr/bin/apxs2
./configure --with-apxs=/usr/bin/apxs2
make
sudo cp apache-2.0/mod_jk.so $APACHE_HOME/modules/

echo "Include conf/mod-jk.conf" >> apache2.conf

sudo cp ~/Downloads/mod-jk.conf ~/Downloads/worker.properties ~/Downloads/uriworkermap.properties $APACHE_HOME/conf

