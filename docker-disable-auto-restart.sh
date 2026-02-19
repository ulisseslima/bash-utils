#!/bin/bash

source $(real require.sh)

container=$1
require container "container id"

docker update --restart=no $container


