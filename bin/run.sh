#!/bin/sh

# docker run -d \
#   --name mongodump-s3 \
#   --env-file config.env \
#   --mount type=bind,source=/Users/sean/.aws,target=/root/.aws \
#   recipedude/bullseye-mongodb-s3:latest sleep 999999

docker run \
  --name mongodump-s3 \
  --env-file config.env \
  --mount type=bind,source=/Users/sean/.aws,target=/root/.aws \
  recipedude/bullseye-mongodb-s3:latest 

