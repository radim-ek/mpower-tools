#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

sleep 30

echo 0 > /proc/led/freq

log "MQTT listening for LED..."
$BIN_PATH/mosquitto_sub -I $clientID -h $mqtthost $auth -v -t $topic/led/+/set \
--will-topic $topic/\$online --will-retain --will-qos 1 --will-payload 'false' \
| while read line; do
    rxtopic=`echo $line| cut -d" " -f1`
    inputVal=`echo $line| cut -d" " -f2`
    
    property=`echo $rxtopic | sed 's|.*/led/\([a-z]*\)/set$|\1|'`
    
    if [ "$property" == "freq" ] || [ "$property" == "status" ]
    then
    
        log "MQTT request received. $property control for LED with value" $inputVal
        `echo $inputVal > /proc/led/$property`
        echo 5 > $tmpfile
    fi        
done
