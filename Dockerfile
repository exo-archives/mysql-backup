FROM mysql:5.7

RUN apt-get update && apt-get install pbzip2 && rm -rf /var/lib/apt

COPY backup.sh /backup.sh

RUN mkdir /backups && chmod a+x /backup.sh

ENTRYPOINT /backup.sh
