#!/bin/sh
docker build -t php7.4.x .
docker push detorresrctesting/php7.4.x:latest
docker tag php7.4.x detorresrctesting/php7.4.x
docker push detorresrctesting/php7.4.x:latest
