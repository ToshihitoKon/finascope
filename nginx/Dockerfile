FROM nginx:1

COPY conf.d /etc/nginx/conf.d
RUN rm /etc/nginx/conf.d/default.conf

RUN nginx -t
