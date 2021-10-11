FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nginx libraspberrypi-bin && apt-get -y clean
COPY src/ /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY html/ /var/www/html/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]