*** This is the Postgresql Data Warehouse Repository ***

What you'll find here:
1. Intermediate File Loader scripts
2. Database Design
3. Builder scripts

Project Hierarchy:
	+ IFL     //The Intermediate File Loaders. Python project for loading the digester's output (intermediate files) directly to their corresponding database modules
	|--
	|--
	+ Design
	|-- DbSchema     //These files are basically just XML files that can be opened in DBSchema as a design project.
	|-- ERD     //Entity-Relationship-Diagram of GOBII's metadata schema
	+ Builder     //SQL Builder scripts
	+-- Preloaded     //Contains builder SQL preloaded with some projects from certain crops
		|-- gobii_rice
		|-- gobii_wheat
		+-- gobii_maize
