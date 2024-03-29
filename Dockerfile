FROM ubuntu:12.04
MAINTAINER Dmitriy Scherbakov (DGTL LLC)

# locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

ENV VERSION 5.5.2

RUN echo "Etc/UTC" > /etc/timezone    
RUN dpkg-reconfigure -f noninteractive tzdata

# upstart on Docker
RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

# mount
# RUN cat /proc/mounts > /etc/mtab

# OS
# RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install vim curl pwgen unzip less supervisor ntpdate python-software-properties sudo

## timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime


# # install & setup
# # ssh
# RUN apt-get -y install ssh
# RUN update-rc.d ssh defaults
# RUN mkdir /var/run/sshd
# ADD ./supervisor/sshd.conf /etc/supervisor/conf.d/sshd.conf

## MySQL
RUN echo mysql-server mysql-server/root_password password '' | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password '' | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server
RUN service mysql stop
RUN update-rc.d mysql disable

RUN sed -i "/^innodb_buffer_pool_size*/ s|=.*|= 128M|" /etc/mysql/my.cnf
RUN sed -i "s/log_slow_verbosity/#log_slow_verbosity/" /etc/mysql/my.cnf
ADD ./supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf
ADD ./character_set.cnf /etc/mysql/conf.d/character_set.cnf

# Confluence
ADD http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-$VERSION-x64.bin /atlassian-confluence-x64.bin
ADD ./supervisor/confluence.conf /etc/supervisor/conf.d/confluence.conf
ADD http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.28.tar.gz /

## user
RUN useradd -d /home/admin -g users -k /etc/skel -m -s /bin/bash admin
RUN yes password | passwd admin
RUN echo "admin	ALL=(ALL:ALL) ALL" > /etc/sudoers.d/admin
RUN chmod 440 /etc/sudoers.d/admin

ADD ./start.sh /
ADD ./startup /startup

CMD ["/bin/sh", "/start.sh"]
