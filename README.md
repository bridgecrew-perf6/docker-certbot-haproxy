# Docker Certbot HAProxy

A docker container for LetsEncrypt certbot to use with a HAProxy server

Example usage:

```
version: '3.7'
services:
    haproxy:
        image: haproxy:2.3-alpine
        ports:
             - "80:80"
             - "443:443"
        volumes:
            - ./haproxy:/usr/local/etc/haproxy/:ro
            - letsencrypt:/etc/letsencrypt:ro
        networks:
            - default
        restart: unless-stopped
    certbot:
        pid: "service:haproxy" # Need to share PID so it can trigger reload
        build: ../docker-certbot-haproxy
        volumes:
            - letsencrypt:/etc/letsencrypt:rw
            - ./certbot:/certbot:ro
        depends_on:
            - haproxy
        environment:
            - DOMAINS=www.jhalsey.com mail.jhalsey.com
        networks:
            default:
                ipv4_address: 172.16.238.10 # Needs a static IP because we don't have enough time for DNS resolver to update
        restart: unless-stopped
volumes:
    letsencrypt:        # Shared volume to save certificates
networks:
    default:
        ipam:
            driver: default
            config:
                - subnet: "172.16.238.0/24"
```
