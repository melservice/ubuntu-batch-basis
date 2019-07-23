#!/bin/bash
#
# Das Skript erstellt das Docker-Image
# ###########################################################################

# Sicherheitshalber
. ~/.profile

# Der Name des Docker-Images, das gebaut werden soll
DOCKER_NAME=${1:-"melservice/ubuntu-batch-basis"};

# Aktuelles Verzeichnis merken und auf das Verzeichnis des Skriptes umschalten
oldPWD=$(pwd);
cd "$(dirname $0)";

# Das Image bauen
docker build --no-cache -t $DOCKER_NAME:latest .;
rc=$?;

# Bei Erfolg wird das Image bei Docker-Hub hochgeladen
#if [ $rc -eq 0 ]; then
#	docker push $DOCKER_NAME:latest
#fi;
