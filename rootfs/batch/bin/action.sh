#!/bin/bash
#
# Der Start des Batches im Docker-Container

# Die Batch-Konfiguration einlesen
. /batch/bin/batch.properties

# Batch läuft mit dem falschen User
if [ $(id -un) != $EXEC_USER ]; then
	echo "Batch wird per sudo als Runtime-User $RUNAS neu gestartet";
	sudo -iu $EXEC_USER /bin/bash -c "$0" $*;
	exit $?;
fi;

echo "Der Batch wurde gestartet!";

exit 0;
