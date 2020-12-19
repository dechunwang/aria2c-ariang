 FROM nginx:1.19.2

COPY nginx.conf /etc/nginx/nginx.conf.template
COPY ./static /usr/share/nginx/html
COPY ./payload /payload
ADD start /start
RUN chmod +x /start && apt-get update && apt-get install -y wget  jq
CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf" && nginx -g 'daemon off;' > /dev/null 2>&1 & ./start
