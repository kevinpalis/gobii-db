#!/bin/bash
sed -i "s/local   all             all                                     peer/local   all             all                                     $postgres_local_auth_method/" /etc/postgresql/12/main/pg_hba.conf
sed -i "s/host    all             all             127\.0\.0\.1\/32            md5/host    all             all             0\.0\.0\.0\/0            	$postgres_host_auth_method/" /etc/postgresql/12/main/pg_hba.conf
sed -i "s/\#listen_addresses = 'localhost'/listen_addresses = '$postgres_listen_address'/" /etc/postgresql/12/main/postgresql.conf
sed '$ a default_statistics_target = 100' /etc/postgresql/12/main/postgresql.conf
service postgresql restart
service ssh restart
/bin/bash
