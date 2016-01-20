#!/bin/bash
# script a ser ejecutado com usuario com permisos administrativos

# Instalamos Java Container
yum -y install java

# Instalamos e iniciamos Tomcat
yum -y install tomcat6
service tomcat6 start
chkconfig --level 234 tomcat on

# Sumamos o repositorio EPEL que tem os binarios do Nginx
yum -y install epel-release

# Instalamos e iniciamos Nginx
yum -y install nginx
service nginx start
chkconfig --level 234 nginx on
