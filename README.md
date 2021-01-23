# cmd4-HisenseTV
Shell script to integrate Hisense TVs using the RemoteNOW app with Homebridge through the homebridge-cmd4 plug-in.

## Installation:
1. Download the RemoteNow app for the TV and pair it to your smart phone. I cant remember if I had pulled this off on my iPhone or the Android tablet I have at home. Home Assistant forums suggest you use an Android device for this. You will need to retrieve the MAC Address of the device you have paired to the TV.
2. To make sure you have the correct MAC Address (as I had issues on my first attempt), you can download the following program on your laptop to 'work out' the commands the TV sends; here you will see the definite MAC Address being used to send the commands. [MQTT Explorer](http://mqtt-explorer.com/):

![image](https://user-images.githubusercontent.com/40288237/104183468-f5062380-544c-11eb-9335-bf21928d0af5.png)

3. Inside this program you will see the commands captured as you use the device you paired to control the TV. This is what I have used for my work-in-progress version for a TV accessory (to come eventually). You should by now have both your IP Address and the MAC Address for the paired device.
4. From your Homebridge command terminal do the following:
5. Install `mosquitto`: `sudo apt-get install mosquitto`
6. Install `wakeonlan`: `sudo apt-get install wakeonlan`
7. Install `openssl`: `sudo apt-get install openssl`
8. Get the security certificates from your TV using `openssl`(add your IP address in here): `openssl s_client -host TV_IP_ADDRESS -port 36669 -showcerts` . It should spit out a bunch of information, you need to grab only the following area of code that looks like this:
```
-----BEGIN CERTIFICATE-----
qmierjfpaoisdjmçfaisldjcçfskdjafcaçskdjcçfmasidcf (etc. etc. etc)
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
7ferusycedaystraedyasredyatrdsecdtrseydtraESYDTRASCY (etc. etc. etc)
-----END CERTIFICATE-----
```
9. Copy the two certificates, create a new file from your terminal `sudo nano hisense.crt` and paste the two certifications as found inside. Press `ctrl+x` to exit and press `y` to save. This will have created the certificate file in your home file path (`/home/pi/hisense.crt`); if you want it elsewhere you will need to change it in `line 29` of the shell script I will provide further down.
10. Create your shell script for the Switch accessory: `sudo nano HisenseSwitch.sh`
11. Paste the following inside. Before doing so, change the IP Address on `line 3` and `line 10`, change the MAC Address on `line 26` to the MAC Address of your TV (get this from the settings menu on your TV) and change the MAC Address on `line 29` to the MAC Address of the device you paired to the TV (the one you got from MQTT Explorer). Sorry I had not had a chance to neaten this up to make it easier to use for other people yet:
```
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
```
12. Press `ctrl+x` to exit and press `y` to save. This will have created the shell script in your home file path (`/home/pi/HisenseSwitch.sh`); if you want it elsewhere you will need to change it in the `homebridge-cmd4` config I will provide further down.
13. Install `homebridge-cmd4` fi you have not already done so.
14. Add to your Homebridge `config.json` file (easiest done through `homebridge-confi-ui-x` web UI) the following config:
```
{
            "platform": "Cmd4",
            "name": "Cmd4",
            "outputConstants": true,
            "accessories": [
                {
                    "type": "Switch",
                    "displayName": "My_Switch",
                    "on": "FALSE",
                    "name": "Hisense",
                    "stateChangeResponseTime": 1,
                    "state_cmd": "bash /home/pi/HisenseSwitch.sh",
                    "polling": [
                        {
                            "on": "FALSE",
                            "interval": 50,
                            "timeout": 5000
                        }
                    ]
                }
            ]
        },
```
15. Restart Homebridge and all should be well... Unless you are me and everything I do goes wrong several times first haha.

## Troubleshooting:
After `Step 9` and before `Step 10`; you can run the following two commands to see that you have the certs and your MAC Address correct. If the following commands do not work, then you have done something wrong with the certs or MAC Address and it is the not a problem with how you have set up your shell script or `homebridge-cmd4`. To turn on the TV use `wakeonlan XX:XX:XX:XX:XX:XX` (replace with the MAC Address of your TV) and to turn off the TV use `mosquitto_pub --cafile /home/pi/hisense.crt --insecure -h IP_ADDRESS -p 36669 -P multimqttservice -u hisenseservice -t "/remoteapp/tv/remote_service/XX:XX:XX:XX:XX:XX$normal/actions/sendkey" -m "KEY_POWER"` (replace with the IP Address of your TV and the MAC Address of your paired device). I can't remember if these commands needs a `sudo` in front or not.

## Special Thanks:
1. None of this would have been possible without the patience and kindness of [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4) developer John Talbot; who did not have to help me at all, but worked through my script and errors, and put up with my stupid questions.
2. My wife who has put up with what has become an obsession to get yet another device in Homekit.
