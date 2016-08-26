FROM php:5-apache

MAINTAINER DNX DragoN "ratthee.jar@hotmail.com"

ENV MYSQLPASS password
	
RUN apt-get update && apt-get install -y nano wget git \
	&& rm -rf /var/lib/apt/lists/*

# copy in code
ADD src/ /var/www/html/

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db \
&& add-apt-repository 'deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/10.1/debian jessie main'

RUN echo mariadb-server-10.1 mysql-server/root_password password $MYSQLPASS | debconf-set-selections;\
echo mariadb-server-10.1 mysql-server/root_password_again password $MYSQLPASS | debconf-set-selections;

RUN apt-get update \
&& apt-get install -y mariadb-server supervisor \
&& rm -rf /var/lib/apt/lists/*

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN /usr/bin/mysqld_safe & sleep 10s \
&& echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql -uroot -p$MYSQLPASS

# Add Scripts
ADD scripts/start.sh /start.sh

COPY conf/supervisord.conf /etc/supervisord.conf

EXPOSE 80 3306

CMD [ "/bin/bash", "/start.sh", "start" ]