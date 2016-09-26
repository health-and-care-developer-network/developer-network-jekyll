FROM nginx:1.11.4-alpine
RUN useradd generator -s /bin/bash
RUN chown -R generator:generator /usr/share/nginx/html/
COPY site /usr/share/nginx/html/
USER generator
