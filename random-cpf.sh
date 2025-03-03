#!/bin/bash

cpf=$(node $(real gen-cpf.js))
echo $cpf
echo $cpf | ctrlc.sh
