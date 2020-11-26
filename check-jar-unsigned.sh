#!/bin/bash

jar="$1"
#jarsigner -verify -verbose -keystore exampleruthstore sContract.jar
jarsigner -verify -verbose $jar | grep unsigned
