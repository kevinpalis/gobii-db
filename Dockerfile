FROM ubuntu:18.04
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
EXPOSE 22
RUN useradd gadm -s /bin/bash -m --password $(echo G0biiVM | openssl passwd -1 -stdin)
RUN adduser gadm sudo
RUN groupadd gobii
RUN usermod -aG gobii gadm
RUN usermod -g gobii gadm
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
RUN service ssh restart
#install Java
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'
RUN apt install -y zulu-13
#install postgres
COPY config.sh /root
RUN chmod 755 /root/config.sh
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-12 postgresql-contrib postgresql-server-dev-12 postgresql-client-12
RUN apt-get install postgresql-plpython3-12
RUN usermod -aG gobii postgres
EXPOSE 5432
ENTRYPOINT ["/root/config.sh"]
