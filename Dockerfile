FROM melservice/ubuntu-server:latest

LABEL version="1.0" \
	description="Basis-Service auf Ubuntu-Basis für weitere Docker basierte Batch-Services" \
	maintainer="develop@melsaesser.de"

# Die bereitgestellten Skripte und Einstellungen kopieren
COPY rootfs /

# Die aktuellen Paketlisten laden, Updates holen und Initialisierung laufen lassen,
# danach wird wieder aufgeräumt
RUN /docker/init/create-ubuntu-batch-basis.sh

# Dies ist das Start-Kommando
CMD ["bash", "/batch/bin/start.sh"]
