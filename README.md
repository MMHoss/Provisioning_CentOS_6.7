# Provisioning_CentOS_6.7
100% bash script to provision a CentOS 6.7 minimal with Tomcat 7.0.33 as container for java, Nginx 1.0.15 as reverse proxy forcing SSL conexions and MongoDB 3.2.1.
All the software keep running with their own users by default.

To run it, download the tar file or with git already installed run:
  
  git clone https://github.com/MMHoss/Provisioning_CentOS_6.7.git /home/prov 
  
  cd /home/prov
  
  chmod +x provisioning.sh

and then run 

./provisioning.sh 

with administrative rights (as root or with sudo for example).
