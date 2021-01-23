#!/bin/bash

# IP Address of TV (go to TV settings to find this).
ip="192.168.0.156"
# MAC Address of the TV (go to TV settings to find this).
tvMAC="7C:B3:7B:76:77:D4"
# MAC Address of device paired to the TV through the RemoteNOW app.
pairedMAC="8C:84:01:20:57:18"

if [ "$1" = "Get" ]; then
  case "$3" in

    On )
      # Polls the TV over your network to see if it is still active.
      if [ $(timeout 2 /bin/bash -c "(echo > /dev/tcp/"$ip"/36669) > /dev/null 2>&1 && echo 1 || echo 0")  = '1' ]; then
        echo 1
      else
        echo 0
      fi
      ;;

    esac
fi

if [ "$1" = "Set" ]; then
  case "$3" in

    On )
      if [ "$4" = "true" ]; then
        # TV can only be turned back on by WOL using your TV MAC ADDRESS.
        wakeonlan "$tvMAC"
      else
        # TV can turn off using MQTT.
        mosquitto_pub --cafile /home/pi/hisense.crt --insecure -h $ip -p 36669 -P multimqttservice -u hisenseservice -t "/remoteapp/tv/remote_service/"$pairedMAC"$normal/actions/sendkey" -m "KEY_POWER"
      fi
      ;;

   esac
fi

exit 0
