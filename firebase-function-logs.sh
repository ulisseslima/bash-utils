#!/bin/bash

source $(real require.sh)

project=$1
require project

firebase --project $project functions:log
