Have created scripts to facilitate APEX and DB development on Oracle Cloud (OCI) with Autonomous database using Terraform and Liquibase.

## Instructions:

* Fork the repo
* Create Developer Image vm instance (from Cloud UI) to OCI and setup oci cli on the vm once created and running; access with “ssh opc@ -A”
* Clone the git repo to the vm over ssh from the GitHub fork
* Go to /scripts
* Run config.sh; this requires a few things in the Cloud tenancy:
* A bucket in Object Storage for the TF statefiles and a respective preauth with read/write permissions
* The “prod” (master) database wallet to be stored in the Object Storage (same or separate as above) with a respective preauth

## Available scripts:

* `clone.sh` to copy the “prod” (master) database contents to local git (e.g. tables and APEX app) to a temp branch that can be merged to master
* `dev.sh` to create a new “dev” Autonomous db instance with optional APEX for a task-id
* `devcopy.sh` to copy contents from git master branch to the instance above (or another) with a task-id
* `branch.sh` to get changes from “dev” database to a feature branch in git with a task-id that can be merged to master
* `merge.sh` to copy the contents from git master to “prod” (master) database
* `destroy.sh` to destroy all resources (mainly the autonomous database instance) for the “dev” with a task-id

The script names are a bit funny, but hope it is ok - you can change them to wahtever you like

Happy coding!
