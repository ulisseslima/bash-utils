#!/bin/bash

set -e

SAMBA_HOST=smb.murah
SAMBA_SHARE=teste
PASSW=6des7@murah
PASSW_SSH=murah
WORKGROUP=Murah
PROXY_USER=ulisses
PROXY=$PROXY_USER@$PROXY_USER.murah.com
USER=ulisseslima

TMP_DIR_PROXY=/home/$PROXY_USER/samba
TMP_DIR_CLIENT=/home/wonka/samba
SCP_DIR=$PROXY:$TMP_DIR_PROXY

TAR=_.tar

cleanup() {
	rm -rf *
}

gohome() {
	cd $TMP_DIR_CLIENT
}

tarwd() {
	rm -f $TAR
	if [[ -n "$1" ]]; then
		tar cf $TAR $1
	else
		tar cf $TAR *
	fi
	sshpass -p $PASSW_SSH scp $TAR $SCP_DIR
	rm $TAR
}

mvsmb() {
	share="$1"
	dir="$2"

	sshpass -p $PASSW_SSH ssh $PROXY "smbproxy.sh put $share $dir"
}

# Remove os diretórios do samba, deixando apenas o arquivo requisitado
normalize() {
	mv `pwd`/$1/* `pwd`
	rm -r `echo $1 | cut -d/ -f1`
}

doget() {
	share="$1"
	dir="$2"
	file="$3"

	sshpass -p $PASSW_SSH ssh $PROXY "smbproxy.sh get $share $dir $file"
	sshpass -p $PASSW_SSH scp $SCP_DIR/$TAR `pwd`
	tar xf $TAR
	rm $TAR
	normalize $2
}

doput() {
	tarwd "$3"
	mvsmb "$1" "$2"
}

dointeractive() {
	share="$1"
	smbclient //$SAMBA_HOST/"$share"/ $PASSW -W $WORKGROUP -U $USER
}

mode=$1
case $mode in
	get) doget "$2" "$3" "$4"
	;;
	put) doput "$2" "$3" "$4"
	;;
	--interactive|-i) dointeractive "$2"
	;;
esac
