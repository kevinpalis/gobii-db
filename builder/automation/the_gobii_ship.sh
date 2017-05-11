#!/usr/bin/env bash
#usage: bash.sh <path-of-parms-file> <dockerhubpassw> <gobii_release_version>
#This a stand-alone equivalent of my THE_GOBII_SHIP Bamboo plan
#Requirements:
#1. The user that will run this script needs to be a sudoer and under the gobii and docker groups. So preferably the user 'gadm'.
#2. The working directory needs to be where the gobiiconfig_wrapper.sh is as well, typically <gobii_bundle>/conf/
#3. Run this on a server that has access on all 3 nodes, if this is not possible, break up the script into the 3 main nodes and run individually
#NOTE: In case you need to break up this script in 3 nodes, you may need to restart Tomcat again at the end of the installation process.
#NOTE2: The order of execution is important.
#@author: (palace) kdp44@cornell.edu


#--------------------------------------------------#
### ALL NODES ###
#--------------------------------------------------#
set -u
set -e
#load parameters
source $1
DOCKER_HUB_PASSWORD=$2
GOBII_RELEASE_VERSION=$3
#GOBII_RELEASE_VERSION="release-0.3-73" #FOR TESTS
echo "The GOBII Ship is sailing..."

#--------------------------------------------------#
### ANY NODE ###
#--------------------------------------------------#
#create a symlink for the loader UI to work
sudo ln -sfn $BUNDLE_PARENT_PATH /data

#--------------------------------------------------#
### DB NODE ###
#--------------------------------------------------#
echo "Installing the DB node..."
#Stop and remove DB docker container [DISABLED IN PRODUCTION SYSTEMS - ONLY ENABLE IF DOING A FRESH INSTALL]
#WARNING: THIS WILL REPLACE YOUR DATABASE DOCKER NODE
docker stop $DOCKER_DB_NAME || true && docker rm $DOCKER_DB_NAME || true
#Pull and start the DB docker image
docker login -u $DOCKER_HUB_USERNAME -p $DOCKER_HUB_PASSWORD;
docker pull $DOCKER_HUB_USERNAME/$DOCKER_HUB_DB_NAME:$GOBII_RELEASE_VERSION;
docker run -i --detach --name $DOCKER_DB_NAME -e "gobiiuid=$GOBII_UID" -e "gobiigid=$GOBII_GID" -e "gobiiuserpassword=${DOCKER_GOBII_ADMIN_PASSWORD}"  -v ${BUNDLE_PARENT_PATH}:/data -v gobiipostgresetcubuntu:/etc/postgresql -v gobiipostgreslogubuntu:/var/log/postgresql -v gobiipostgreslibubuntu:/var/lib/postgresql -p $DOCKER_DB_PORT:5432 $DOCKER_HUB_USERNAME/$DOCKER_HUB_DB_NAME:$GOBII_RELEASE_VERSION;
docker start $DOCKER_DB_NAME;

#set the proper UID and GID and chown the hell out of everything (within the docker, of course)
echo "Matching the docker gadm account to that of the host's and changing file ownerships..."
docker exec $DOCKER_DB_NAME bash -c '
usermod -u $GOBII_UID gadm;
groupmod -g $GOBII_GID gobii;
find / -user 1000 -exec chown -h $GOBII_UID {} \;
find / -group 1001 -exec chgrp -h $GOBII_GID {} \;
';

#clear the target directory of any old gobii_bundle
echo "Copying the GOBII_BUNDLE to the shared directory/volume..."
docker exec $DOCKER_DB_NAME bash -c 'rm -rf /data/$DOCKER_BUNDLE_NAME';
docker exec $DOCKER_DB_NAME bash -c 'cd /var; cp -R ${bamboo.docker.bundle.name} /data/$DOCKER_BUNDLE_NAME';
docker exec $DOCKER_DB_NAME bash -c 'chown -R gadm:gobii /data/$DOCKER_BUNDLE_NAME';


#--------------------------------------------------#
### WEB NODE ###
#--------------------------------------------------#
echo "Installing the WEB node..."
#Stop and remove the web docker container if it exists -- this will not throw an error if the dockers are not there, to enable it to work on fresh installs
docker stop $DOCKER_WEB_NAME || true && docker rm $DOCKER_WEB_NAME || true
#Pull and start the WEB docker image
docker pull $DOCKER_HUB_USERNAME/$DOCKER_HUB_WEB_NAME:$GOBII_RELEASE_VERSION;
docker run -i --detach --name $DOCKER_WEB_NAME  -v $BUNDLE_PARENT_PATH:/data -p $DOCKER_WEB_PORT:8080 $DOCKER_HUB_USERNAME/$DOCKER_HUB_WEB_NAME:$GOBII_RELEASE_VERSION;
docker start $DOCKER_WEB_NAME;

#set the proper UID and GID and chown the hell out of everything (within the docker, of course)
echo "Matching the docker gadm account to that of the host's and changing file ownerships..."
docker exec $DOCKER_WEB_NAME bash -c '
usermod -u $GOBII_UID gadm;
groupmod -g $GOBII_GID gobii;
find / -user 1000 -exec chown -h $GOBII_UID {} \;
find / -group 1001 -exec chgrp -h $GOBII_GID {} \;
';

echo "Updating gobii-web.xml..."
#Update the gobii-web.xml file with installation params. The (not-so) fun part.
docker exec $DOCKER_WEB_NAME bash -c '
cd $DOCKER_BUNDLE_NAME/config; 
bash gobiiconfig_wrapper.sh $CONFIGURATOR_PARAM_FILE
';

echo "Restarting tomcat under user gadm..."
#Restart tomcat with the proper ownership
#Stop tomcat and start with the gadm user
docker exec $DOCKER_WEB_NAME bash -c '
cd /usr/local/tomcat/bin/;
sh shutdown.sh;
';
docker exec --user gadm $DOCKER_WEB_NAME bash -c '
cd /usr/local/tomcat/bin/;
sh startup.sh;
';

#--------------------------------------------------#
### COMPUTE NODE ###
#--------------------------------------------------#
echo "Installing the COMPUTE node..."
#Stop and remove COMPUTE docker container
docker stop $DOCKER_COMPUTE_NAME || true && docker rm $DOCKER_COMPUTE_NAME || true
#Pull and start the COMPUTE docker image
docker pull $DOCKER_HUB_USERNAME/$DOCKER_HUB_COMPUTE_NAME:$GOBII_RELEASE_VERSION;
docker run -i --detach --name $DOCKER_COMPUTE_NAME  -v $BUNDLE_PARENT_PATH:/data -p $DOCKER_COMPUTE_SSH_PORT:22 $DOCKER_HUB_USERNAME/$DOCKER_HUB_COMPUTE_NAME:$GOBII_RELEASE_VERSION;
docker start $DOCKER_COMPUTE_NAME;

#set the proper UID and GID and chown the hell out of everything (within the docker, of course)
echo "Matching the docker gadm account to that of the host's and changing file ownerships..."
docker exec $DOCKER_COMPUTE_NAME bash -c '
usermod -u $GOBII_UID gadm;
groupmod -g $GOBII_GID gobii;
find / -user 1000 -exec chown -h $GOBII_UID {} \;
find / -group 1001 -exec chgrp -h $GOBII_GID {} \;
';

#Grant permissions and set cronjobs
echo "Granting permissions and setting cronjobs..."
docker exec $DOCKER_COMPUTE_NAME bash -c '
chmod -R +rx /data/$DOCKER_BUNDLE_NAME/loaders/;
chmod -R +rx /data/$DOCKER_BUNDLE_NAME/extractors/;
chmod -R g+rwx /data/$DOCKER_BUNDLE_NAME/crops/*/files;
';

#Sets the cron jobs for 2 crops, if there is no 2nd crop, no error will be thrown. This allows the script to be useful for CGs with 2 crops too, without any modifications.
docker exec --user gadm $DOCKER_COMPUTE_NAME bash -c '
cd /data/$DOCKER_BUNDLE_NAME/loaders/etc;
crontab -r;
sh addCron.sh /data/$DOCKER_BUNDLE_NAME $DOCKER_CROP1_NAME $DOCKER_CRON_INTERVAL $DOCKER_CRON_FILE_AGE;
sh addCron.sh /data/$DOCKER_BUNDLE_NAME $DOCKER_CROP2_NAME $DOCKER_CRON_INTERVAL $DOCKER_CRON_FILE_AGE || true; 
' || true;








