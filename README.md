```
docker network create nginx-proxy
docker-compose up -d
docker run -d -v /data/certificates:/etc/nginx/certs:rw     -v /var/run/docker.sock:/var/run/docker.sock:ro --volumes-from nginx-proxy     jrcs/letsencrypt-nginx-proxy-companion --restart=always
```
This allows to run other containers if they pass VIRTUAL_HOST env to themselves
https://blog.ssdnodes.com/blog/host-multiple-websites-docker-nginx/
