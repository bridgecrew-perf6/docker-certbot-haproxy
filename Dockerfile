FROM certbot:latest

COPY run.sh /

ENTRYPOINT ["/run.sh"]
