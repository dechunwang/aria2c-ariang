 FROM nginx:1.19.2

COPY nginx.conf /etc/nginx/nginx.conf.template
COPY ./static /usr/share/nginx/html
ADD payload .
ADD start /start
RUN chmod +x /start
CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf" && nginx -g 'daemon off;' & ./start
