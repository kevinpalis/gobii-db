import getopt
import logging
import os
import psycopg2
import re
import subprocess
import sys

from dotenv import load_dotenv
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from psycopg2 import sql

# Configure path for env file
config_folder = os.path.expanduser('.')
load_dotenv(os.path.join(config_folder, '../config/.env'))

# Configure logging
logging_path = os.getenv('logging_path') # can change the logging output dir
logging.basicConfig(
    filename=logging_path,
    filemode='a',
    format="%(asctime)s: user '%(name)s' %(message)s | Level: %(levelname)s",
    datefmt='%m/%d/%Y %I:%M:%S %p',
    level=logging.INFO
)


def addCrop(crop, databaseConfig):
    # This function is for creating a database, creating tables inside it,
    # and seeding it, given the proper user inputs

    try:
        connection, cursor = getDatabaseConnection(databaseConfig)

        database_name = 'gobii_' + crop # naming convention

        cursor.execute("CREATE DATABASE %s OWNER %s" %
                        (database_name, databaseConfig['user']))

        runSh(databaseConfig, database_name, "addCrop")

        print("Successfully created " + database_name + " database.")
        logging.info("added a new database named '%s'", database_name)

    except Exception as e:
        print(e)
        print("Failed to create" + database_name + " database.")
        sys.exit(1)

    finally:
        if connection:
            cursor.close()
            connection.close()
            print("PostgreSQL connection was closed.")
            sys.exit(1)



def checkIfCrop(crop):
    # This function is for validating the crop input by the user.
    # Only accepts one word and alpha characters

    CROP_PATTERN = "^[a-zA-Z]+$" # Alpha characters only and one word
    isCrop = re.match(CROP_PATTERN, crop)
    if isCrop is None:
        return False
    return True


def checkIfModule(module):
    # This function is for checking if the given module by the
    # user is actually part of the listed modules of the
    # program

    MODULES = ["addCrop", "deleteCrop", "listCrops"]
    if (module in MODULES):
        return True
    else:
        return False


def getDatabaseConnection(databaseConfig):
    # This function gets the database connection that will be used for queries.
    # The config used for connecting to Postgres is from the env file.

    try:
        connection = psycopg2.connect(
            database=databaseConfig['database'],
            user=databaseConfig['user'],
            password=databaseConfig['password'],
            host=databaseConfig['host'],
            port=databaseConfig['port']
        )
        connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = connection.cursor()

        return connection, cursor

    except (Exception, psycopg2.Error) as error:
        print("Error:", error)

def checkRows(crop, databaseConfig):
    # Will return a boolean upon checking the rows of the selected database
    # that will be deleted.
    hasEmptyRows = ""
    tableContainer = []

    try:
        database_name = 'gobii_' + crop

        # The database config from the env file will needed to be
        # changed so that it can connect to the selected database
        # and get check its rows.
        databaseConfigWithSelectedCrop = dict(databaseConfig) # preventing to mutate the original config
        databaseConfigWithSelectedCrop['database'] = database_name

        connection, cursor = getDatabaseConnection(databaseConfigWithSelectedCrop)

        # Required tables to check in the selected database
        tablesToCheck = [
                        "public.dataset",
                        "public.experiment",
                        "public.germplasm",
                        "public.marker",
                        "public.project"
                    ]

        for table in tablesToCheck:
            cursor.execute("SELECT COUNT(*) FROM %s" % (table))
            tableRowsCount = cursor.fetchone()

            # If the rows are not empty, this will be collected to
            # be returned, prompting the user that these rows
            # contains data and will be needing to use
            # --force if wanted to be deleted.
            if (tableRowsCount[0] != 0):
                table = {
                    "name": table,
                    "rowCount": tableRowsCount[0]
                }
                tableContainer.append(table)

        if (len(tableContainer)):
            hasEmptyRows = False
        else:
            hasEmptyRows = True

    except Exception as e:
        print(e)
        print("Failed to connect to database.")
        sys.exit(1)

    finally:
        if connection:
            cursor.close()
            connection.close()
            return hasEmptyRows, tableContainer


def deleteCrop(crop, databaseConfig):
    try:
        database_name = 'gobii_' + crop

        runSh(databaseConfig, database_name, "deleteCrop")

        connection, cursor = getDatabaseConnection(databaseConfig)
        cursor.execute("DROP DATABASE %s" % (database_name))

        print("Successfully deleted " + database_name + " database.")
        logging.critical("deleted a database named '%s'", database_name)

    except Exception as e:
        print(e)
        print("Failed to delete " + database_name + " database.")
        sys.exit(1)

    finally:
        if connection:
            cursor.close()
            connection.close()
            print("PostgreSQL connection was closed.")
            sys.exit(1)


def getDatabaseConfig():
    connection = {
        "database": os.getenv('database'),
        "user":     os.getenv('user'),
        "password": os.getenv('password'),
        "host":     os.getenv('host'),
        "port":     os.getenv('port')
    }

    return connection


def listCrops(databaseConfig):
    try:
        connection, cursor = getDatabaseConnection(databaseConfig)

        print("List of crops in database:")
        cursor.execute(
            "SELECT datname FROM pg_database where datname LIKE 'gobii_%'")
        crops = cursor.fetchall()

        # need to do this because the crops is an array of tuple
        for crop in crops:
            (name,) = crop
            print(name)

        logging.info("listed crops")

    except:
        print("Failed to list crops.")
        sys.exit(1)

    finally:
        if connection:
            cursor.close()
            connection.close()
            print("PostgreSQL connection was closed.")
            sys.exit(1)


def printTableContainer(tableContainer):
    # This is for printing the number of rows in the table,
    # and the table name. Called when the user does not
    # use --force in a must-use crop deletion.
    for table in tableContainer:
        trimmedTableName = table['name'].replace("public.", "")
        print(f"{table['rowCount']} {trimmedTableName}")


def printUsageHelp():
    print("\nUsage: python sastre.py [MODULE]")

    print("\nModules:")

    print("addCrop \t Add a new crop in the database")

    print("\t\t Required flags:")
    print(
        "\t\t \033[1m -m\033[0m or \033[1m --module \033[0m \t Operation that will be used with the database"
    )
    print(
        "\t\t \033[1m -c\033[0m or \033[1m --crop \033[0m \t Given crop name that will be used to name the database."
    )
    # TODO: confirm if only small letters only
    print("\t\t\t\t\t Must be alpha characters only (e.g. potato).")

    # TODO: add if this is required or optional
    # print(
    #     "\t\t \033[1m -u\033[0m or \033[1m --users \033[0m \t A file listing all users having initial access to the database"
    # )

    print("\t\t Usage:")
    print("\t\t  python sastre.py -m addCrop -c corn")

    print("\n")

    print("deleteCrop \t Delete a crop in the database")

    print("\t\t Required flags:")
    print(
        "\t\t \033[1m -m\033[0m or \033[1m --module \033[0m \t Operation that will be used with the database"
    )
    print(
        "\t\t \033[1m -c\033[0m or \033[1m --crop \033[0m \t Given crop name that will be used to delete the database."
    )
    # TODO: confirm if only small letters only
    print("\t\t\t\t\t Must be alpha characters only (e.g. potato).")

    print("\t\t Optional flag:")
    print(
        "\t\t \033[1m --force\033[0m \t\t Used if deleting a crop contains rows in the"
    )
    print("\t\t\t\t\t project, experiment, dataset, markers, or germplasm tables.")

    print("\t\t Usage:")
    print("\t\t  python sastre.py -m deleteCrop -c corn")
    print("\t\t  python sastre.py -m deleteCrop -c corn --force")

    print("\n")

    print("listCrops \t List all crop databases")

    print("\t\t Usage:")
    print("\t\t  python sastre.py -m listCrops")

    sys.exit(1)


def runSh(databaseConfig, database_name, module):
    # This is for passing the parameters and
    # running the sh files for running psql
    # or Java commands

    (database,)=databaseConfig['database'],
    (user,)=databaseConfig['user'],
    (password,)=databaseConfig['password'],
    (host,)=databaseConfig['host'],
    (port,)=databaseConfig['port'],

    sastre_sh_path=os.getenv('sastre_sh_path')

    shFile = ""
    if (module == "addCrop"):
        shFile = 'sastre_add.sh'
    elif (module == "deleteCrop"):
        shFile = 'sastre_delete.sh'

    subprocess.run(
        [
            'sh',
            shFile,
            database_name,
            user,
            host,
            port,
            password
        ],
        cwd=sastre_sh_path
    )

def main():
    # Get the given command line arguments
    try:
        opts, args = getopt.getopt(
            sys.argv[1:],
            "h:m:c:u:",
            ["help", "module", "crop", "user", "force"]
        )
    except getopt.GetoptError:
        print("Error: wrong usage syntax.")
        printUsageHelp()

    # Set the given command line arguments from the user
    module = ""
    crop = ""
    user = ""
    force = ""
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            printUsageHelp()
        elif opt in ("-m", "--module"):
            module = arg
        elif opt in ("-c", "--crop"):
            crop = arg
        elif opt in ("--force"):
            force = True
        # TODO: add if this is required or optional
        elif opt in ("-u", "--user"):
            user = arg

    # Calling modules depending on user's input with validation
    if (module or crop):
        isModule = checkIfModule(module)
        isCrop = checkIfCrop(crop)

        if (not isModule):
            print("Invalid given module.")
            printUsageHelp()
            sys.exit(1)
        elif (isModule and module == "listCrops"):
            databaseConfig = getDatabaseConfig()
            listCrops(databaseConfig)
            sys.exit(1)
        elif (not isCrop):
            print("Invalid given crop.")
            printUsageHelp()
            sys.exit(1)
        elif (isModule and module == "addCrop" and isCrop):
            databaseConfig = getDatabaseConfig()
            addCrop(crop, databaseConfig)
        elif (isModule and module == "deleteCrop" and isCrop):
            databaseConfig = getDatabaseConfig()

            # check first if needed to use --force or not
            notUseForceDelete, tableContainer = checkRows(crop, databaseConfig)
            if (notUseForceDelete):
                deleteCrop(crop, databaseConfig)
            else:
                # Check if the user provided --force flag if the rows needed to use --force
                if (force):
                    deleteCrop(crop, databaseConfig)
                else:
                    print("The crop deletion cannot proceed as there are:")
                    printTableContainer(tableContainer)
                    print("\n")
                    print("Use --force to force deletion")

    else:
        print("Error: Missing required flags.")
        printUsageHelp()


if __name__ == "__main__":
    main()
