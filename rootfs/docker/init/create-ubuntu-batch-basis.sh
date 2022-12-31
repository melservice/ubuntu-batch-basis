#!/bin/bash
#
# Initialisierung des Service beim Erstellen des Images

# Die Batch-Konfiguration einlesen
BatchProperties="/batch/bin/batchuser.properties"
if [ -r $BatchProperties ]; then
	. $BatchProperties
fi

# -----------------------------------------------------------------------------

# Die Berechtigungen auf Verzeichnissen werden für die Batches gesetzt
# 
# Parameter:
# $1 - ein oder mehrere Pfade - mehrere per Leerzeichen getrennt
# $2 - User, dem die Verzeichnisse gehören sollen
# $3 - Gruppe, der die Verzeichnisse zugeordnet werden sollen

function setACL {
	local _paths="$1"
	local _user="$2"
	local _gruppe="$3"
	
	echo "Berechtigungen setzen für Pfade: $_paths"
	chown -R $_user:$_gruppe $_paths
	find "$_paths/" -type d -exec chmod 2750 "{}" \;
	find "$_paths/" -type f -exec chmod 0640 "{}" \;
	find "$_paths/" -type f -name "*.sh" -exec chmod 0755 "{}" \;
}

# -----------------------------------------------------------------------------

function saveValue {
	local _valueName="$1"
	local _fileName="$2"
	
	if [ -f "${_fileName}" ] && [ ! -z $(egrep "^[ \t]*${_valueName}" "${_fileName}") ]; then
		sed -i "s/^[ \t]*${_valueName}=.*/${_valueName}=${!_valueName}/" "${_fileName}"
	else
		echo "${_valueName}=${!_valueName}" >>"${_fileName}"
	fi
}

# -----------------------------------------------------------------------------

# Namen für Runtime-User und -Gruppen generieren
EXEC_USER="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1 | tr -d '\n')"
CONF_GROUP="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1 | tr -d '\n')"
DATA_GROUP="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1 | tr -d '\n')"
LOGS_GROUP="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1 | tr -d '\n')"
EXEC_UID="1$(cat /dev/urandom | tr -dc '0-9' | fold -w 3 | head -n 1 | tr -d '\n')"

# Die generierten User und Gruppen in batchuser.properties notieren
saveValue "EXEC_USER" "$BatchProperties"
saveValue "EXEC_UID" "$BatchProperties"
saveValue "CONF_GROUP" "$BatchProperties"
saveValue "DATA_GROUP" "$BatchProperties"
saveValue "LOGS_GROUP" "$BatchProperties"

# Der Runtime-User $EXEC_USER mit den Gruppen $CONF_GROUP (Configuration), $DATA_GROUP (Daten) und $LOGS_GROUP (Logfiles) wird erstellt.
addgroup $CONF_GROUP
addgroup $DATA_GROUP
addgroup $LOGS_GROUP
adduser --uid $EXEC_UID --home "/batch" --shell /bin/bash --ingroup $LOGS_GROUP --disabled-login --disabled-password --quiet $EXEC_USER;
adduser $EXEC_USER $CONF_GROUP
adduser $EXEC_USER $DATA_GROUP
adduser $EXEC_USER $LOGS_GROUP

# Die Verzeichnisse für den Batch erstellen und Berechtigungen setzen
mkdir -p /batch/.ssh /batch/bin /batch/config /batch/input /batch/output /batch/logs /batch/archiv
touch /batch/bin/action.sh

# Skripte und Konfiguration - gehören root und sind für Gruppe CONF_GROUP lesbar
setACL "/batch/.ssh /batch/bin/ /batch/config/" "root" "$CONF_GROUP"

# Logfiles gehoren dem Batch und sind für Gruppe LOGS_GROUP lesbar
setACL "/batch/logs/" "$EXEC_USER" "$LOGS_GROUP"

# Datenverzeichnisse gehören EXEC_USER und sind für DATA_GROUP lesbar
setACL "/batch/input/ /batch/output/ /batch/archiv/" "root" "$DATA_GROUP"

# Das Start-Skript darf jeder ausführen
chmod 0755 /batch/bin/start.sh
