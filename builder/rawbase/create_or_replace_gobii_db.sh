#!/usr/bin/env bash
#params: $1 = database_name; $2 = user_name
psql -U $2 postgres -c "drop database $1;"
psql -U $2 postgres -c "drop database $1;"
psql -U $2 postgres -c "create database $1 owner $2;"
psql -U $2 $1 -f build_gobii_pg.sql
