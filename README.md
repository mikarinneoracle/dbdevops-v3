Have created scripts to facilitate APEX and DB development on Oracle Cloud (OCI) with Autonomous database using git, Terraform and Liquibase.

## Instructions:

* Fork the repo
* Create Developer Image vm instance (from Cloud UI) to OCI and setup oci cli on the vm once created and running; access with “ssh opc@ -A”
* Clone the git repo to the vm over ssh from the GitHub fork
* Create a bucket in Object Storage for the TF statefiles and a respective preauth with read/write permissions
* Go to /scripts
* Run config.sh; this requires a few things in the Cloud tenancy:

## Available scripts:

* `create.sh` to create a new Autonomous db dev instance for a task-id
* `pull.sh` to get changes from “dev” database to a feature branch with a task-id in git that can be then merged to master using a pull request, for example
* `push.sh` optionally create a dev env to "dev" database with a task-id with APEX and copy contents from git master branch to it
* `destroy.sh` to destroy all resources (mainly the autonomous database instance) for the “dev” with a task-id

Happy coding!
