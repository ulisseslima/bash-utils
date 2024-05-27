#!/bin/bash

echo "enter email:"
read email
git config user.email "$email"

echo "enter name:"
read name
git config user.name "${name}"
