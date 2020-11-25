#!/usr/bin/env

# Parameters:
# $1 - database name
# $2 - username
# $3 - host
# $4 - port
# $5 - password

export PGPASSWORD=$5
echo "Killing existing sessions for $1 if any..."
psql -h "$3" -p $4 -U $2 postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$1'  AND pid <> pg_backend_pid();"