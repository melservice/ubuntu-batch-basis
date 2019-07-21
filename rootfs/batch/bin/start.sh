#!/bin/bash
#
# Der Start des Batches im Docker-Container

# Die Batch-Konfiguration einlesen
. /batch/bin/batch.properties

# Start des Batches
sudo -iu $EXEC_USER /bin/bash -c /batch/bin/action.sh;
