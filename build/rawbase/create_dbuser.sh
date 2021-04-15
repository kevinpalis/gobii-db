#!/usr/bin/env bash
#NOTE: This is the default GDM DB credentials for automation's purposes. It is implied that in production systems, it will be changed immediately after deployment.
sudo -u postgres psql -c "create user appuser with superuser password 'g0b11isw3s0m3' valid until 'infinity';"

#NOTE: This is the default Timescoper credentials for automation's purposes. It is implied that in production systems, it will be changed immediately after deployment.
sudo -u postgres psql -c "create user timescoper with superuser password 't1m3sc0p3dbusr' valid until 'infinity';"
