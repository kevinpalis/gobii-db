## Description

A simple Python program that create (with seeding), delete, and list databases.
Created with [psychopg2](https://pypi.org/project/psycopg2/) and Bash scripts.

## Installation

1. Make sure [pip](https://pypi.org/project/pip/) is installed in the system.
2. Go to the main directory and run `pip install -r requirements.txt` to install the needed packages.
3. Run `cp env-example .env` inside the **config** folder and update the `.env` created with the proper config.
4. Go to **src** folder and run some modules.

## Modules and Usage

**List crops**

- Creates a database given a crop from the user.
- Sample usage:
  `python sastre.py -m listCrops`

**Add crop**

- Creates a database given a crop from the user.
- _TODO:_
  - finish seeding newly created tables within the created database using the Java script
  - finish the use of `contacts.txt`/using of file
- Sample usage:
  `python sastre.py -m addCrop -c corn`

**Delete crop**

- Creates a database given a crop from the user.
- _TODO: use --force feature_
- Sample usage:
  `python sastre.py -m deleteCrop -c corn`
