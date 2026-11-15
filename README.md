docker-compose file I use to run jwilder/nginx-proxy.

```
docker network create nginx-proxy
docker-compose up -d
docker run -d --name nginx-letsencrypt --restart=always -v /data/certificates:/etc/nginx/certs:rw -v /var/run/docker.sock:/var/run/docker.sock:ro --volumes-from nginx-proxy jrcs/letsencrypt-nginx-proxy-companion 
```

This allows to run other containers if they pass VIRTUAL_HOST env to themselves
https://blog.ssdnodes.com/blog/host-multiple-websites-docker-nginx/

After changing anything under `nginx-proxy/`, rebuild with `docker-compose up -d --build`.

## Additions to jwilder/nginx-proxy

- `00_client_max_body_size.conf`: request bodies up to 100 MB, for every site.
- The `com.github.perk11.nginx-proxy.proxy-timeout` container label sets
  `proxy_read_timeout` and `proxy_send_timeout` in that container's location
  block(s), next to upstream's own labels such as
  `com.github.nginx-proxy.nginx-proxy.keepalive`. Containers without it keep
  nginx's 60 s default. It is for sites whose connections stay idle longer
  than that, such as WebSockets:

  ```yaml
  labels:
    com.github.perk11.nginx-proxy.proxy-timeout: "960s"
  ```

  One value covers both directives. The value must be a number with an
  optional `s`, `m` or `h` (`^[0-9]+[smh]?$`); anything else is ignored and
  leaves a comment in the generated config, so a label cannot add
  configuration. Do not also set these two directives for the same host in a
  `vhost.d/<host>_location` file: nginx refuses a duplicate directive.

  Upstream's template has no such label, so the image patches
  `/app/nginx.tmpl` at build time (`nginx-proxy/proxy-timeout/`). The patch
  inserts its two snippets after two lines of the template, and the build fails
  if either line is missing or appears more than once.

The base image is pinned (`jwilder/nginx-proxy:1.11.6-alpine`), not the rolling
`:alpine` tag, which is rebuilt from upstream's main branch: the patch is
checked against a known template, and a rebuild gives the same proxy. The cost
is that nginx and Alpine updates arrive only when the tag in
`nginx-proxy/Dockerfile` is raised. To update, set a newer release tag and run
`docker-compose build --pull && docker-compose up -d`; if the template changed
under the patch, the build stops with a message saying so, and the running proxy
is left as it was.
