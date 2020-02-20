![Alt text](https://thumbnails-photos.amazon.com/v1/thumbnail/BoKZcnoqRbu1FA5S-pq0FQ?viewBox=860%2C430&ownerId=A3RL6H4CGV9EDF&groupShareToken=3nBmqRPHRkOSNoFCzXXJxA.g3lrRb25_s0FjHtiFfscnu "GOBii Project")

# GOBii Data Warehouse

GOBii's Genotype Data Manager (GDM) is very modular - and the data warehouse is not an exception. So it is important to make the distinction of when this module is on its own vs when its run inside the GOBii system.

For a quick system overview of where this module fit in GDM, see this [diagram](https://gobiiproject.atlassian.net/wiki/spaces/GD/pages/91717797/System+Architecture). The data warehouse live inside the database container, which at the time of this writing is running on Ubuntu 18.04 LTS with Postgres 9.5 pre-configured, but with plans to upgrade to Postgres 12 with optimizations in the next few weeks.

## Spinning up a stand-alone GOBii DB container

The basic container with this module installed is available in [this Dockerhub repository](https://hub.docker.com/r/gadm01/gobii_db_vanilla_ubuntu) (**gadm01/gobii_db_vanilla_ubuntu**). So you can simply set it up locally or in any server by doing:
####  

```bash  
docker pull gadm01/gobii_db_vanilla_ubuntu:tagname;
docker run --detach --name gobii-db-node -h db-node -v /data:/data -v gobiipostgresetcubuntu:/etc/postgresql -v \
gobiipostgreslogubuntu:/var/log/postgresql -v gobiipostgreslibubuntu:/var/lib/postgresql -p 5433:5432 \
--health-cmd="pg_isready -U postgres || exit 1" gadm01/gobii_db_vanilla_ubuntu:tagname;
```

For the rest of this readme, I will be talking about the data warehouse in its own context (no dependency to the rest of the GDM system).

## The ERD

You'll find an interactive HTML5 diagram of the data model here: [GOBii ERD](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/249200646/Entity+Relationship+Diagram)


## Database Versioning and Change Control Management

When we first started this project we only used raw SQL files and git for version control. We quickly found out it wasn't sufficient, especially when there are multiple contexts involved (add to that the complexity of managing seed data). So we decided to use [Liquibase](https://www.liquibase.org/) in tandem with git. 

#### Liquibase in GOBii

There are too many ways you can use Liquibase for database versioning and change control, I have written [a Confluence page on how we use it](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/248545594/Liquibase). If you are contributing to this repository, it is imperative that you read the linked document and conform to the standards we've put in place.


## Contents of this repository
 
### Design

This directory contains all the files we use to design the schema as well as the graphical representation of the schema for all versions of the data warehouse.

* **DBSchema** - DBSchema is a visual tool for database management. It has a lot of features that make data visualization, random data generation, data loading (mainly for testing), and reports and forms generation really easy. The HTML5 ERD you see linked above was generated using DBSchema. This directory contains the DBSchema project files. 
* **ERD** - This contains the HTML5 and JPEG versions of the ERD suffixed by version. We keep the files here up to date with the source code.


### Builder

This contains everything you need to build the schema from scratch. Note that if you are using one of our pre-configured containers, all these scripts were already ran for you.

If you need to create an instance of our database (ex. for development or testing), follow this guide: [Setting a Database for Development](https://gobiiproject.atlassian.net/wiki/spaces/GDW/pages/257523864/Setting+Up+a+Database+for+Development)


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

