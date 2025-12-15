#!/bin/bash

source $(real require.sh)

project=$1
require project

gcloud run services list --platform managed --project $project
