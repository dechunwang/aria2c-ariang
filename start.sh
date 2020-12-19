#!/bin/bash
mv payload/* .
ls -lart
if [ -f env.encode ]; then
    base64 -d env.encode > .env
    echo ".env file found, sourcing it"
	set -o allexport
	source .env
	set +o allexport
fi
chmod +x delete
chmod +x on-complete

export PATH=$PWD:$PATH

# Tracker
tracker_list=`curl -Ns https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | awk '$1' | tr '\n' ',' | cat`
cat > conf << EOF
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
max-concurrent-downloads=5
continue=true
remote-time=true
max-connection-per-server=16
min-split-size=10M
split=10
max-overall-download-limit=0
max-download-limit=0
max-overall-upload-limit=0
max-upload-limit=0
dir=downloads
input-file=session
save-session=session
file-allocation=prealloc
referer=*
http-accept-gzip=true
content-disposition-default-utf8=true
save-session-interval=60
force-save=false
log-level=notice
log=aria2c.log
allow-overwrite=true
seed-time=0
seed-ratio=1.0
enable-dht=true
enable-dht6=true
dht-file-path=dht.dat
dht-file-path6=dht6.dat
dht-listen-port=6881-6999
dht-entry-point=dht.transmissionbt.com:6881
dht-entry-point6=dht.transmissionbt.com:6881
user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36
bt-remove-unselected-file=true
bt-load-saved-metadata=true
bt-hash-check-seed=true
bt-enable-lpd=true
save-session-interval=1
auto-save-interval=1
bt-max-peers=0
enable-peer-exchange=true
bt-force-encryption=true
peer-agent=qBittorrent/4.2.5
peer-id-prefix=-qB4250-
retry-wait=10
retry-on-400=true
retry-on-403=true
retry-on-406=true
retry-on-unknown=true
rpc-listen-port=5001
bt-tracker=${tracker_list}
EOF
# DHT
wget -q https://github.com/P3TERX/aria2.conf/raw/master/dht.dat
wget -q https://github.com/P3TERX/aria2.conf/raw/master/dht6.dat
base64 -di worker.zip > worker
base64 -di clone.zip > clone
chmod +x worker
chmod +x clone
preventIdling(){
	while :
	do
		RPC_RESULT=$(curl http://127.0.0.1:5001/jsonrpc -H "Content-Type: application/json" -H "Accept: application/json" --data '{"jsonrpc": "2.0","id":"preventIdling", "method": "aria2.getGlobalStat", "params":["token:'${SECRET}'"]}' | jq '.result' ) 
		NUM_ACTIVE=$(echo $RPC_RESULT | jq '.numActive | tonumber')
		NUM_WAITING=$(echo $RPC_RESULT | jq '.numWaiting | tonumber')
		NUM_UPLOAD=$(cat numUpload)
		TOTAL=$(($NUM_ACTIVE + $NUM_WAITING + $NUM_UPLOAD))
		echo "numbers: ${NUM_ACTIVE} ${NUM_WAITING} ${NUM_UPLOAD} total: ${TOTAL}"
		if [ $TOTAL -gt 0 ]
		then
			curl http://${HEROKU_APP_NAME} | tail
		fi
		sleep 1m
		
	done
}


if [[ -n $CLONE_CONFIG && -n $CLONE_DESTINATION ]]; then
	echo "Rclone config detected"
	echo -e "[DRIVE]\n$CLONE_CONFIG" > clone.conf
	echo "on-download-stop=./delete" >> conf
	echo "on-download-complete=./on-complete" >> conf

fi
mkdir -p downloads
echo "rpc-secret=$SECRET" >> conf
worker --conf-path=conf&
sleep 5; rm conf dht.dat dht6.dat&
preventIdling&
sleep 999d

