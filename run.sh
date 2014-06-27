#!/bin/sh
sudo docker run -p 0.0.0.0:20080:8090 -v /data/confluence-antalika:/confluence:rw dgtl/confluence

# debug
# sudo docker run -i -t -p 127.0.0.1:20022:22 -p 127.0.0.1:20080:8090 -v /data/confluence:/confluence:rw dgtl/confluence /bin/bash
