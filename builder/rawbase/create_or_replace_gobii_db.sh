#!/usr/bin/env bash
#params: $1 = database_name; $2 = user_name
#trigger
echo $1 $2 $3 $4 $5
export PGPASSWORD=$5
psql -h "$3" -p $4 -U $2 postgres -c "drop database $1;"
psql -h "$3" -p $4 -U $2 postgres -c "create database $1 owner $2;"
psql -h "$3" -p $4 -U $2 $1 -f build_gobii_pg.sql
