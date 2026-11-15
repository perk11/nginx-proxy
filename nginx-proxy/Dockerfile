# Pinned, not :alpine (a rolling build of upstream main): proxy-timeout/
# patches this release's nginx.tmpl. To upgrade, change the tag and rebuild;
# the build fails if the template moved under the patch.
FROM jwilder/nginx-proxy:1.11.6-alpine
COPY 00_client_max_body_size.conf /etc/nginx/conf.d/00_client_max_body_size.conf
COPY proxy-timeout/ /app/proxy-timeout/
RUN sh /app/proxy-timeout/patch-template.sh /app/nginx.tmpl
