#!/bin/bash -e
# https://stackoverflow.com/questions/43931986/how-to-upgrade-angular-cli-to-the-latest-version
# https://angular.dev/cli/update

ng version

npm uninstall -g @angular/cli
npm install -g @angular/cli@latest
npm install @angular/cli@latest

rm -rf node_modules
npm uninstall --save-dev @angular/cli
npm install --save-dev @angular/cli@latest
npm install

ng version

ng update @angular/core
