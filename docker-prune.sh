#!/bin/bash
# https://docs.docker.com/engine/manage-resources/pruning/

docker system df -v
docker image prune
docker system df

# remove ALL stopped containers (risky, double check)
# docker container prune

# EVERYTHING
# docker system prune -a -f

# sort containers by size
# docker ps -a --size --format "table {{.ID}}\t{{.Image}}\t{{.Size}}" | sort -k3 -h

# Detailed Inspection of One Container
# docker inspect --size <container_id>

# quick overview
# docker ps -a --size
