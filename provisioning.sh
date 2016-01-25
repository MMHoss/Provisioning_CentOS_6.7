#!/bin/bash
# script a ser ejecutado com usuario com permisos administrativos (permisos de root)

# instalamos Git e descargamos o repositorio dos arquivos de configuracao		
yum -y install git
mkdir /home/config-files
cd /home/config-files
git clone https://github.com/MMHoss/Provisioning_CentOS_6.7.git /home/

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

# creamos directorio para certificado do web server
mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl

# generamos uma passphrase para o certificado
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)
# creamos a chave privada
openssl genrsa -des3 -out ejemplo.key -passout env:PASSPHRASE 2048

# Generamos a informacao do Subject do certificado
subject="
C=BR
ST=MinasGerais
LocalityName=Uberlandia
O=Zup
OU=TI
CommonName=www.zup.com.br
EmailAddress=admin@zup.com.br
"
# generamos o CSR (certificate signing request)
openssl req -new -batch -subj "$(echo -n "$subject" | tr "\n" "/")" -key zup.key \
    -out zup.csr -passin env:PASSPHRASE

# Removemos a passphrase da chave
cp ejemplo.key ejemplo.key.bak
openssl rsa -in ejemplo.key.bak -out ejemplo.key -passin env:PASSPHRASE	
	
# generamos o certificado assinado com a chave creada antes
openssl x509 -req -in ejemplo.csr -signkey ejemplo.key -out ejemplo.crt

# copiamos o arquivo de configuracao do Nginx para a pasta dos sites ativos
cp /home/config-files/config/ejemplo.com.br.conf /etc/nginx/sites-enabled/ejemplo.com.br.conf

# Modificamos o nginx.conf para incluir a nova configuracao
sed -i.old 's/conf.d/sites-enabled/' /etc/nginx/nginx.conf
# fazemos reload do servicio nginx para aplicar os cambios na configuracao
nginx -s reload

# modificamos a configuracao do tomcat para recever trafego HTTPS do proxy reverso
sed -i.old 's/redirectPort="8443"/redirectPort="8443" scheme="https" proxyName="localhost" proxyPort="443"/' /etc/tomcat/server.xml

# reiniciamos o servicio do tomcat para aplicar os cambios
service tomcat restart

# Sumamos o repositorio da ultima verçao do MongoDB
cat > /etc/yum.repos.d/mongodb-org-3.2.repo <<EOF
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/6Server/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1
EOF

# Instalamos a ultima versao estable do MongoDB (outra opcao era instalar a versão do repositorio base, bastante mais antigua)
yum -y install mongodb-org-server-3.2.1 mongodb-org-shell mongodb-org-tools --disablerepo=base,epel,updates,extra 

# Habilitamos autenticacao modificando o mongodb.conf
sed -i.old 's/'#security:'/'security:'\n'"  authorization: enabled"'/' /etc/mongodb.conf

# comenzamos o servicio do MongoDB com as configuraçoes do arquivo .conf
mongod --fork -f /etc/mongodb.conf

# configuramos o servicio para iniciar automaticamente
chkconfig mongod on

# aplicamos js script para creaçao dos usuarios nas bases de datos (no MongoDB as bases nao precisam 
# ser creadas, elas comienzam a existir cuando alguma informacao e inserta nelas)
mongo < /home/config-files/mongo_user_creation.js

# flush of existing rules
iptables -F
# block of NULL packets
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# block syn-flood attacks
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
# block Christmas tree packets attacks
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables-save
service iptables restart

reboot now
