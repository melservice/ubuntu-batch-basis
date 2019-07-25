#!/bin/bash
#
# Der Start des Batches im Docker-Container
# ==========================================================================================================

set -o pipefail

# ---------------------------------------------------------------------------------------------------

# Die Batch-Konfiguration einlesen
. /batch/bin/batchuser.properties

# Die Library nachladen und Skript ggf. im Runtime-User starten
melDir="/docker/lib";
. "${melDir}/melLibrary.sh"

# ---------------------------------------------------------------------------------------------------

# Start des Batches
runBatch="/batch/bin/action.sh";
if [ -x "$runBatch" ]; then
	/bin/bash -c $runBatch;
	rc=$?;
else
	echo "Batch '$runBatch' nicht vorhanden oder nicht ausführbar";
	rc=0;
fi;

exit $rc;
