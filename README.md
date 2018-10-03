docker network create nginx-proxy
docker-compose up

This allows to run other containers if they pass VIRTUAL_HOST env to themselves
https://blog.ssdnodes.com/blog/host-multiple-websites-docker-nginx/