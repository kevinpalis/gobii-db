#author: Kevin Palis <kdp44@cornell.edu>

FROM ubuntu:18.04
#update and install utility packages
RUN apt-get update -y && apt-get install -y \
 sudo \
 wget \
 openssh-client \
 openssh-server \
 openssl \
 gnupg2 \
 software-properties-common \
 vim
EXPOSE 22 5432

#set all environment variables needed to initialize the database - these can all be overriden during container run
ENV postgres_local_auth_method=trust
ENV postgres_host_auth_method=trust
ENV postgres_listen_address=*
ENV db_user=ebsuser
ENV db_pass=3nt3rpr1SE!
ENV db_name=templatedb
ENV pg_driver=postgresql-42.2.10.jar
ENV lq_contexts=general,seed_general,seed_cornell
ENV lq_labels=''
ENV os_user=gadm
ENV os_pass=g0b11Admin
ENV os_group=gobii

#Create default user and group. NOTE: change the gadm password on a production system
RUN useradd $os_user -s /bin/bash -m --password $(echo $os_pass | openssl passwd -1 -stdin) && adduser $os_user sudo && \
groupadd $os_group && \
usermod -aG $os_group $os_user && \
usermod -g $os_group $os_user

#allow password-based SSH
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
RUN service ssh restart

#copy the entrypoint/config file and make sure it can execute
COPY config.sh /root
RUN chmod 755 /root/config.sh

#install Java so we can run liquibase
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 && \
apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main' && \
apt install -y zulu-13


#Create the file repository configuration
#Import the repository signing key
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
apt-get -y update

#Install Postgresql13
#NOTE: Include contrib only if you really need it, for GOBii, the high-speed bulk loading requires the file_fdw
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
postgresql-13 \
postgresql-client-13 \
postgresql-plpython3-13 \
postgresql-contrib

#Make sure the postgres user is part of the gobii group to avoid permission issues
RUN usermod -aG $os_group postgres

COPY build build

ENTRYPOINT ["/root/config.sh"]







