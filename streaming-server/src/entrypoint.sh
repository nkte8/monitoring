#!/bin/bash
service nginx start
service nginx status
raspistill --nopreview -o /var/www/html/img.jpg \
    -rot 270 -w 640 -h 480 -q 20 -tl 200 -t 3600000 -th 0:0:0