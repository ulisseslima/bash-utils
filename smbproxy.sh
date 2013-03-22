#!/bin/sh

set -e

SAMBA_HOST=smb.murah
SAMBA_SHARE=teste
PASSW=6des7@murah
WORKGROUP=Murah
PROXY_USER=ulisses
PROXY=$PROXY_USER@murah.com
USER=ulisseslima

TMP_DIR_PROXY=/home/$PROXY_USER/samba
TMP_DIR_CLIENT=/home/wonka/samba

TAR=_.tar
mode=$1

cleanup() {	
	rm -r *
}

gohome() {
	cd $TMP_DIR_PROXY
}

doget() {
	share="$1"
	dir="$2"
	file="$3"
	
	gohome
	cleanup
	smbclient //$SAMBA_HOST/"$share"/ $PASSW -W $WORKGROUP -U $USER -D "$dir" -Tc $TAR "$file"
}

doput() {
	share="$1"
	dir="$2"

	gohome
	smbclient //$SAMBA_HOST/"$share"/ $PASSW -W $WORKGROUP -U $USER<<EOC
cd "$dir"
put $TAR
tar x $TAR
rm $TAR
EOC
	cleanup
}

dointeractive() {
	share=$1	
	smbclient //$SAMBA_HOST/"$share"/ $PASSW -W $WORKGROUP -U $USER
}

case $mode in
	get) doget "$2" "$3" "$4"
	;;
	put) doput "$2" "$3"
	;;
	--interactive|-i) dointeractive "$2"
	;;
esac

