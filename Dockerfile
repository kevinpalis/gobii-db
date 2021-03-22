FROM ubuntu:18.04
#update and install utility packages
RUN apt-get update -y && apt-get install -y \
 sudo \
 make \
 curl \
 git \
 tree \
 openssh-client \
 openssh-server \
 openssl \
 gnupg2 \
 software-properties-common \
 vim
EXPOSE 22 5432

#Create default user and group. NOTE: change the gadm password on a production system
RUN useradd gadm -s /bin/bash -m --password $(echo g0b11Admin | openssl passwd -1 -stdin) && adduser gadm sudo
RUN groupadd gobii
RUN usermod -aG gobii gadm && usermod -g gobii gadm

#allow password-based SSH
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
RUN service ssh restart

#copy the entrypoint/config file and make sure it can execute
COPY config.sh /root
RUN chmod 755 /root/config.sh

#install Java so we can run liquibase
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'
RUN apt install -y zulu-13

#install postgres
#Create the file repository configuration
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
#Import the repository signing key
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
#Update the package lists
RUN apt-get -y update


#Install Postgresql13
#NOTE: Include contrib only if you really need it, for GOBii, the high-speed bulk loading requires the file_fdw
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
postgresql-13 \
postgresql-server-dev-13 \
postgresql-client-13 \
postgresql-plpython3-13 \
postgresql-contrib

#Make sure the postgres user is part of the gobii group to avoid permission issues
RUN usermod -aG gobii postgres

#TODO: Add steps to initialize database and run liquibase

ENTRYPOINT ["/root/config.sh"]
