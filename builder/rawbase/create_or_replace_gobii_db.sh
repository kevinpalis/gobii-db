#!/usr/bin/env bash
#params: $1 = database_name; $2 = user_name
export PGPASSWORD="$6"
psql -h $3 -p $4 -U $2 postgres -c "drop database $1;"
psql -h $3 -p $4 -U $2 postgres -c "create database $1 owner $2;"
psql -h $3 -p $4 -U $2 $1 -f build_gobii_pg.sql
