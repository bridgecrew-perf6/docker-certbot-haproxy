# Docker Certbot HAProxy

[![Build status](https://github.com/jacob-pro/docker-certbot-haproxy/actions/workflows/docker.yml/badge.svg)](https://github.com/jacob-pro/docker-certbot-haproxy/actions)

A docker container for LetsEncrypt certbot to use with a HAProxy server

# Usage

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
    certbot-haproxy:
        pid: "service:haproxy" # Need to share PID so it can trigger reload
        image: ghcr.io/jacob-pro/certbot-haproxy:latest
        volumes:
            - letsencrypt:/etc/letsencrypt:rw
        depends_on:
            - haproxy
        environment:
            - EMAIL= #Renewal email here
            - DOMAINS=domain1.com domain2.com
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

Include the certificates in HAProxy config:

```
bind *:443 ssl crt /etc/letsencrypt/haproxy alpn h2,http/1.1
```

Forward LetsEncrypt requests to the Certbot backend

```
frontend http_in
    bind :::80 v4v6
    acl letsencrypt path_beg /.well-known/acme-challenge/
    use_backend letsencrypt if letsencrypt
    
backend letsencrypt
    server certbot 172.16.238.10:80
```

## Chicken And Egg Problem

If you are seeing HAProxy error `no SSL certificate specified for bind` or `unable to stat SSL certificate from file` this is because:

- HAProxy cannot start a HTTPS bind without any certificates
- Certbot can't generate a certificate without HAProxy running

The solution is to either:

- Comment out your HTTPS binding until Certbot has run once
- Manually populate the /etc/letsencrypt/haproxy folder with a temporary certificate
