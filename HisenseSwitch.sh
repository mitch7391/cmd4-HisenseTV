#!/bin/bash

ip="192.168.0.156"
port="36669"

if [ "$1" = "Get" ]; then
  case "$3" in

    On )
      if [ $(timeout 2 /bin/bash -c "(echo > /dev/tcp/192.168.0.156/36669) > /dev/null 2>&1 && echo 1 || echo 0")  = '1' ]; then
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
        #TV can only be turned back on by WOL using your TV MAC ADDRESS
        wakeonlan XX:XX:XX:XX:XX:XX
      else
        #TV can turn off using MQTT
        mosquitto_pub --cafile /home/pi/hisense.crt --insecure -h $ip -p $port -P multimqttservice -u hisenseservice -t "/remoteapp/tv/remote_service/XX:XX:XX:XX:XX:XX$normal/actions/sendkey" -m "KEY_POWER"
      fi
      ;;

   esac
fi

exit 0
