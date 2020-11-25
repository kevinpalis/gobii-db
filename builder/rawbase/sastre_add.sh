#!/usr/bin/env

# Parameters:
# $1 - database name
# $2 - username
# $3 - host
# $4 - port
# $5 - password

export PGPASSWORD=$5
echo "Populating database $1..."
psql -h $3 -p $4 -U $2 $1 -f build_gobii_pg.sql
cd ~ && cd /Users/dom/Documents/Work/gobii.db/builder/liquibase # this will directory will change
java -jar bin/liquibase.jar --username=$2 --password=$5 --url=jdbc:postgresql://$3:$4/$1 --driver=org.postgresql.Driver --classpath=drivers/postgresql-42.2.10.jar --changeLogFile=changelogs/db.changelog-master.xml --contexts=general,seed_general update