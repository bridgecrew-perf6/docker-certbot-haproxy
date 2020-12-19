FROM certbot/certbot:latest

COPY run.sh /

ENTRYPOINT ["/bin/sh", "/run.sh"]
