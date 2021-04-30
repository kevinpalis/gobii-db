![Alt text](https://thumbnails-photos.amazon.com/v1/thumbnail/jlO5R-FlQi2jc7XIDi0WIw?viewBox=1153%2C328&ownerId=A3RL6H4CGV9EDF&groupShareToken=BMjypj3yTjKYQZeEzFAEUw.WzZF0j057nuvZB9AjXgh1l "EBS Project")

![Alt text](https://thumbnails-photos.amazon.com/v1/thumbnail/BoKZcnoqRbu1FA5S-pq0FQ?viewBox=860%2C430&ownerId=A3RL6H4CGV9EDF&groupShareToken=3nBmqRPHRkOSNoFCzXXJxA.g3lrRb25_s0FjHtiFfscnu "GOBii Project")

# GOBii Data Warehouse

GOBii's Genotype Data Manager (GDM) is very modular - and the data warehouse is not an exception. So it is important to make the distinction of when this module is on its own vs when its run inside the GOBii system.

For a quick system overview of where this module fit in GDM, see this [diagram](https://gobiiproject.atlassian.net/wiki/spaces/GD/pages/91717797/System+Architecture). 

This project has been fully containerized. The commands to help you use this container is outlined below. When you run the container, the following will be done for you:

1. Ubuntu base image with utility tools installed
2. Postgres 13 installed and configured
3. Database engine tuned to run in a modest server
4. Database user created based on the passed variable or created from the default
5. Database created based on the passed variable or created from the defaults - this includes both the gobii_meta and one crop database
6. Liquibase migration against the created databases - effectively giving you the latest GOBii schema. Note that you can override the default contexts if you need fixture data, etc.



## The ERD

You'll find an interactive HTML5 diagram of the data model here: [GOBii ERD](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/249200646/Entity+Relationship+Diagram)


## Database Versioning and Change Control Management

When we first started this project we only used raw SQL files and git for version control. We quickly found out it wasn't sufficient, especially when there are multiple contexts involved (add to that the complexity of managing seed data). So we decided to use [Liquibase](https://www.liquibase.org/) in tandem with git. 

#### Liquibase in GOBii

There are too many ways you can use Liquibase for database versioning and change control, and as of 04/2021, we have put up a [guideline across EBS as to how a database project should be structured](https://ebsproject.atlassian.net/wiki/spaces/DB/pages/29006528708/EBS+Database+Project+Structure). If you are contributing to this repository, it is imperative that you read the linked document and conform to the standards we've put in place.


## Contents of this repository


#### Dockerfile and config.sh
Contains all the containerization steps. The config.sh is the entrypoint and you'll find all the database provisioning in there.

### Design

This directory contains all the files we use to design the schema as well as the graphical representation of the schema for all versions of the data warehouse.

* **DBSchema** - DBSchema is a visual tool for database management. It has a lot of features that make data visualization, random data generation, data loading (mainly for testing), and reports and forms generation really easy. The HTML5 ERD you see linked above was generated using DBSchema. This directory contains the DBSchema project files. 
* **ERD** - This contains the HTML5 and JPEG versions of the ERD suffixed by version. We keep the files here up to date with the source code.


### Build

This contains everything you need to build the schema from scratch. Note that if you are using one of our pre-configured containers, all these scripts were already ran for you.

* **Rawbase** - raw SQL files that will build the schema from an empty database. Running this will create GOBii's foundation schema.
* **Liquibase** - as mentioned in the "Database Versioning" section above, this directory contains all the Liquibase changelogs and changesets.

### Data Access Layer

To satisfy big data requirements, we implemented a thin data access layer (written in Python) that handle bulk loading and extraction with high speed and data volume.

#### GOBII_IFL (Intermmediate File Loader)

Python library that provides fast bulk loading of huge amounts of data.

* [IFL Architecture](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/257589467/IFL+Architecture)
* [IFL Mapping Files](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/257589483/IFL+Mapping+Files)
* [IFL User Guide](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/257589524/IFL+User+Guide)

#### GOBII_MDE (MetaData Extractor)

Python library that provides fast bulk extraction of huge amounts of data.

* [MDE User Guide](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/260178249/MDE+User+Guide)


## Using this container

Usage can be classified into two types: database development and general usage. The following environment variables/parameters are available (shown below with their respective default values) and can be set during `docker run` invocation:

```bash
postgres_local_auth_method=trust
postgres_host_auth_method=trust
postgres_listen_address=*
db_user=ebsuser
db_pass=3nt3rpr1SE!
db_name=templatedb
pg_driver=postgresql-42.2.10.jar
lq_contexts=general,seed_general,seed_cornell
lq_labels=''
os_user=gadm
os_pass=g0b11Admin
os_group=gobii
```


### Database Development

As mentioned above, the container will set up and configure everything you need. So you can focus on just writing SQL or database scripts. As long as they are in the build directory, the container will pick it up.

**Steps**


* Make sure your repository is up to date with remote (ie. `git pull --all`)
* Write your code, ex. for liquibase, make sure the SQL files are in build/liquibase/changesets directory and specified in a changelog XML (see [Database Management Guideline](https://ebsproject.atlassian.net/wiki/spaces/DB/pages/104235022/Database+Change+Management))
* Build the image. Make sure you are in the root directory of this repository, then run

```bash  
docker build --force-rm=true -t gobii-db .
```
* If the build succeeds, you should now have the docker image locally. You can then start and initialize the container. You have two options depending on wether or not you want the database data to persist. Change variable values as you see fit (-v).
	* Persist data across docker runs: 
	```bash 
	docker run --detach --name gobii-db -h gobii-db -p 5434:5432 --health-cmd="pg_isready -U postgres || exit 1" -e "db_name=gobii_db" -e "db_user=kevin" -e "lq_contexts=general,seed_general,seed_cornell" -v gobii_postgres_etc:/etc/postgresql -v gobii_postgres_log:/var/log/postgresql -v gobii_postgres_lib:/var/lib/postgresql -it gobii-db:latest
	```
	* Do not persist data (whenever container is removed via `docker rm`, the data goes away with it): 
	```bash
	docker run --detach --name gobii-db -h gobii-db -p 5434:5432 --health-cmd="pg_isready -U postgres || exit 1" -e "db_name=gobii_db" -e "db_user=kevin" -e "lq_contexts=general,seed_general,seed_cornell" -it gobii-db:latest
	```

* Wait a minute or two. Feel free to check the status of the schema migration via `docker logs gobii-db`.
* You now have a running Postgres 13 on port 5434 with all the latest changes. You can either connect to it to port 5434 from outside the container, or go inside the container and check via psql

```bash
docker exec -ti gobii-db bash
su - postgres
psql
```
* Lastly, you have the option to either **keep the container running** as long as you're making your database changes, then invoking liquibase within the container to test. This way you save time by not having to rebuild the image everytime. Once you are happy with your work, push your liquibase changesets to this repository.


### General Usage

Typically, for general usage, you do not need to modify any database scripts or add new SQL. So the steps are simpler. You don't even need to pull this repository.

#### Get the official docker image from **EBSProject Dockerhub**

> The official nightly build tag is **dev**. Release images are tagged according to version numbers. Check the Dockerhub Repository for current tags. [GOBii-DB Dockerhub](https://hub.docker.com/r/ebsproject/gobii-db)

**Steps**


* Run the container. You have two options depending on wether or not you want the database data to persist.

* Persist data across docker runs:
```bash
docker run --detach --name gobii-db -h gobii-db -p 5434:5432 --health-cmd="pg_isready -U postgres || exit 1" -e "db_name=gobii_db" -e "db_user=kevin" -e "lq_contexts=general,seed_general,seed_cornell" -v gobii_postgres_etc:/etc/postgresql -v gobii_postgres_log:/var/log/postgresql -v gobii_postgres_lib:/var/lib/postgresql -it ebsproject/gobii-db:dev
```
* Do not persist data (whenever container is removed via `docker rm`, the data goes away with it): 
```bash
docker run --detach --name gobii-db -h gobii-db -p 5434:5432 --health-cmd="pg_isready -U postgres || exit 1" -e "db_name=gobii_db" -e "db_user=kevin" -e "lq_contexts=general,seed_general,seed_cornell" -it ebsproject/gobii-db:dev
```
* Wait a minute or two. Feel free to check the status of the schema migration via `docker logs gobii-db`.

* You now have a running Postgres 13 on port 5434 with all the latest changes. You can either connect to it to port 5434 from outside the container, or go inside the container and check via psql

```bash
docker exec -ti gobii-db bash
su - postgres
psql
```

> The example commands above will create the container off of the nightly build (tag=dev). Change the tag as needed.
