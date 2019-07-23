#!/bin/bash
#
# Initialisierung des Service beim Erstellen des Images

# Die Batch-Konfiguration einlesen
. /batch/bin/batch.properties

# -----------------------------------------------------------------------------

# Die Berechtigungen auf Verzeichnissen werden für die Batches gesetzt
# 
# Parameter:
# $1 - ein oder mehrere Pfade - mehrere per Leerzeichen getrennt
# $2 - User, dem die Verzeichnisse gehören sollen
# $3 - Gruppe, der die Verzeichnisse zugeordnet werden sollen

function setACL {
	local _paths="$1";
	local _user="$2";
	local _gruppe="$3";
	
	echo "Berechtigungen setzen für Pfade: $_paths";
	chown -R $_user:$_gruppe $_paths;
	find $_paths -type d -exec chmod 2750 "{}" \;
	find $_paths -type f -exec chmod 0640 "{}" \;
	find $_paths -type f -name "*.sh" -exec chmod 0750 "{}" \;
}

# -----------------------------------------------------------------------------

function saveValue {
	local _valueName="$1";
	local _fileName="$2";
	
	if [ ! -z $(grep "${_valueName}" "${_fileName}") ]; then
		sed -i "s/${_valueName}=.*/${_valueName}=${!_valueName}/" "${_fileName}";
	else
		echo "${_valueName}=${!_valueName}" >>"${_fileName}";
	fi;
}

# -----------------------------------------------------------------------------

# Namen für Runtime-User und -Gruppen generieren
EXEC_USER="$(openssl rand -base64 200 | tr -d '[\n]' | tr '[:upper:]' '[:lower:]' | sed "s/[^a-z]//g" | cut -c1-8)";
CONF_GROUP="$(openssl rand -base64 200 | tr -d '[\n]' | tr '[:upper:]' '[:lower:]' | sed "s/[^a-z]//g" | cut -c1-8)";
DATA_GROUP="$(openssl rand -base64 200 | tr -d '[\n]' | tr '[:upper:]' '[:lower:]' | sed "s/[^a-z]//g" | cut -c1-8)";
LOGS_GROUP="$(openssl rand -base64 200 | tr -d '[\n]' | tr '[:upper:]' '[:lower:]' | sed "s/[^a-z]//g" | cut -c1-8)";
EXEC_UID="1$(openssl rand -base64 200 | tr -d '[\n]' | tr '[A-Za-x]' '[0-9][0-9][0-9][0-9][0-9]'  | sed "s/[^0-9]//g" | cut -c1-3)";

# Die generierten User und Gruppen in batch.properties notieren
saveValue "EXEC_USER" "/batch/bin/batch.properties";
saveValue "EXEC_UID" "/batch/bin/batch.properties";
saveValue "CONF_GROUP" "/batch/bin/batch.properties";
saveValue "DATA_GROUP" "/batch/bin/batch.properties";
saveValue "LOGS_GROUP" "/batch/bin/batch.properties";

# Der Runtime-User $EXEC_USER mit den Gruppen $CONF_GROUP (Configuration), $DATA_GROUP (Daten) und $LOGS_GROUP (Logfiles) wird erstellt.
addgroup $CONF_GROUP;
addgroup $DATA_GROUP;
addgroup $LOGS_GROUP;
adduser --uid $EXEC_UID --home "/batch" --shell /bin/bash --ingroup $LOGS_GROUP --disabled-login --disabled-password --quiet $EXEC_USER;
adduser $EXEC_USER $CONF_GROUP;
adduser $EXEC_USER $DATA_GROUP;
adduser $EXEC_USER $LOGS_GROUP;

# Die Verzeichnisse für den Batch erstellen und Berechtigungen setzen
mkdir -p /batch/.ssh /batch/bin /batch/config /batch/input /batch/output /batch/logs /batch/archiv
touch /batch/bin/action.sh

# Skripte und Konfiguration - gehören root und sind für Gruppe c_user lesbar
setACL "/batch/.ssh /batch/bin/ /batch/config/" "root" "$CONF_GROUP"

# Logfiles gehoren dem Batch und sind für Gruppe l_user lesbar
setACL "/batch/logs/" "$EXEC_USER" "$LOGS_GROUP"

# Datenverzeichnisse gehören x_user und sind für g_user lesbar
setACL "/batch/input/ /batch/output/ /batch/archiv/" "root" "$DATA_GROUP"

# Das Start-Skript darf jeder ausführen
chmod 0755 /batch/bin/start.sh
