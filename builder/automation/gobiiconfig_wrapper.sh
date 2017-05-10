#!/usr/bin/env bash
#usage: sh config_wrapper.sh <path-of-gobii_install.properties>
#run this from the directory where gobiiconfig.jar is

source $1
echo "Path to bundle: " $BUNDLE_PATH/config
echo "Updating $CONFIG_XML..."
cd $BUNDLE_PATH/config;
#Set root gobii directory (global)
java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -gR "$BUNDLE_PATH";
#LDAP authentication options as well as "run as" user for digester/extractor.
java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -auT $AUTH_TYPE -ldUDN "$LDAP_DN" -ldURL $LDAP_URL -ldBUSR "$LDAP_BIND_USER" -ldBPAS $LDAP_BIND_PASSWORD -ldraUSR $LDAP_BACKGROUND_USER -ldraPAS $LDAP_BACKGROUND_PASSWORD;
#Configure email server (global)
java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -stE -soH $MAIL_HOST -soN $MAIL_PORT -soU $MAIL_USERNAME -soP $MAIL_PASSWORD -stT $MAIL_TYPE -stH $MAIL_HASH;

#Configure web server for crop1 - the following config lines should already be configured, only kept here for reference
#java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -c  ${bamboo.sys_int.crop1.name}  -stW  -soH ${bamboo.sys_int.web.host} -soN ${bamboo.sys_int.web.port} -soR ${bamboo.sys_int.crop1.context_path};
#Configure PostGRES server for crop1
#java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -c  ${bamboo.sys_int.crop1.name}  -stP -soH ${bamboo.sys_int.db.host} -soN ${bamboo.sys_int.db.port} -soU ${bamboo.gobii.db.appuser.name} -soP ${bamboo.gobii.db.appuser.password} -soR ${bamboo.sys_int.db.crop1.name};
#Configure MonetDB server for crop1
#java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -c  ${bamboo.sys_int.crop1.name} -stM  -soH ${bamboo.sys_int.monetdb.host} -soN ${bamboo.sys_int.monetdb.port} -soU ${bamboo.sys_int.monetdb.appuser.name} -soP ${bamboo.sys_int.monetdb.appuser.password} -soR ${bamboo.sys_int.db.crop1.name};
#Set default crop to crop1 (global)
#java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -gD ${bamboo.sys_int.crop1.name};

#Set log file directory (global)
java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -gL  $BUNDLE_PATH/logs;
#Create the crop directory structure, ex. /data/gobii_bundle/crops/rice/*
#java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -wdirs
#unfortunately, I can't get rid of this now. This is for setting the parameters for integration testing, which we don't need for production
java -jar gobiiconfig.jar -a -wfqpn $CONFIG_XML -gt  -gtcd $BUNDLE_PATH/test -gtcr  DEV  -gtcs  "java -jar gobiiconfig.jar"  -gtiu http://localhost:8080/gobii-dev -gtsf false -gtsh localhost -gtsp 22 -gtsu localhost -gtldu user2 -gtldp dummypass;
#validate the new gobii configuration xml
java -jar gobiiconfig.jar -validate -wfqpn $CONFIG_XML;

echo "Done."