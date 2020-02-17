![Alt text](https://thumbnails-photos.amazon.com/v1/thumbnail/BoKZcnoqRbu1FA5S-pq0FQ?viewBox=860%2C430&ownerId=A3RL6H4CGV9EDF&groupShareToken=3nBmqRPHRkOSNoFCzXXJxA.g3lrRb25_s0FjHtiFfscnu "GOBii Project")

## GOBii Data Warehouse

GOBii's Genotype Data Manager (GDM) is very modular - and the data warehouse is not an exception. So it is important to make the distinction of when this module is on its own vs when its run inside the GOBii system.

For a quick system overview of where this module fit in GDM, see this [diagram](https://gobiiproject.atlassian.net/wiki/spaces/GD/pages/91717797/System+Architecture). The data warehouse live inside the database container, which at the time of this writing is running on Ubuntu 18.04 LTS with Postgres 9.5 pre-configured, but with plans to upgrade to Postgres 12 with optimizations in the next few weeks.

### Spinning up a stand-alone GOBii DB container

The basic container with this module installed is available in [this Dockerhub repository](https://hub.docker.com/r/gadm01/gobii_db_vanilla_ubuntu) (**gadm01/gobii_db_vanilla_ubuntu**). So you can simply set it up locally or in any server by doing:
####  

```bash  
docker pull gadm01/gobii_db_vanilla_ubuntu:tagname;
docker run --detach --name gobii-db-node -h db-node -v /data:/data -v gobiipostgresetcubuntu:/etc/postgresql -v \
gobiipostgreslogubuntu:/var/log/postgresql -v gobiipostgreslibubuntu:/var/lib/postgresql -p 5433:5432 \
--health-cmd="pg_isready -U postgres || exit 1" gadm01/gobii_db_vanilla_ubuntu:tagname;
```

For the rest of this readme, I will be talking about the data warehouse in its own context (no dependency to the rest of the GDM system).


