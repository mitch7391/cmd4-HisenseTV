<span align="center">
  
[![buy-me-a-coffee](https://badgen.net/badge/icon/BuyMeACoffee/orange?icon=buymeacoffee&label)](https://www.paypal.com/donate/?business=FWN5P4BP7NJT4&no_recurring=1&item_name=Shout+me+a+coffee+%3A%29&currency_code=AUD)
[![reddit](https://badgen.net/badge/icon/Mitch7391/red?icon=reddit&label)](https://www.reddit.com/user/Mitch7391/)
  
</span>

<!-- prettier-ignore -->
> [!NOTE]
> An archived repository means that all users will still be able to use the project, but you will not be able to submit issues or requests, and it will no longer be updated. I strongly advise the use of [homebridge-hisense-tv-remotenow](https://github.com/MrAsterisco/homebridge-hisense-tv).
>
> For the first time ever I will be adding a donate link to my pages. This is just if anyone would like to shout me a coffee :) I have also added a link to my Reddit account if anyone does need to get hold of me for any reason.
> 

# cmd4-HisenseTV
Shell script to integrate Hisense TVs using the RemoteNOW app with Homebridge through the homebridge-cmd4 plug-in.

<h3 align="center">
  <img src="https://github.com/mitch7391/cmd4-HisenseTV/blob/main/Screenshots/HisenseTV.PNG">
</h3>

<h3 align="center">
  <img src="https://github.com/mitch7391/cmd4-HisenseTV/blob/main/Screenshots/TVInputSources.png">
</h3>

## Installation:
1. Download the RemoteNow app for the TV and pair it to your smart phone. I cant remember if I had pulled this off on my iPhone or the Android tablet I have at home. Home Assistant forums suggest you use an Android device for this. You will need to retrieve the MAC Address of the device you have paired to the TV.
2. To make sure you have the correct MAC Address (as I had issues on my first attempt), you can download the following program on your laptop to 'work out' the commands the TV sends; here you will see the definite MAC Address being used to send the commands. [MQTT Explorer](http://mqtt-explorer.com/):

<h3 align="center">
  <img src="https://github.com/mitch7391/cmd4-HisenseTV/blob/main/Screenshots/MQTTExplorer.png">
</h3>

<h3 align="center">
  <img src="https://github.com/mitch7391/cmd4-HisenseTV/blob/main/Screenshots/PairedDeviceMAC.png">
</h3>

3. Inside this program you will see the commands captured as you use the device you paired to control the TV. This is what I have used to collect the commands to create this TV Accessory. You should by now have both your TV IP Address, TV MAC Address and the MAC Address for the paired device.
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

9. Copy the two certificates, create a new file from your terminal `sudo nano hisense.crt` and paste the two certifications as found inside. This will have created the certificate file in your home file path (`/home/pi/hisense.crt`).
10. Edit `HisenseTV.sh` with the IP address of your TV, the MAC Address of your TV, the MAC Address of the paired device from earlier (the one you got from MQTT Explorer) and the file path of the certificate you just created.
11. Copy `HisenseTV.sh` to a subdirectory of your `.homebridge` directory; e.g. `.homebridge/Cmd4Scripts/HisenseTV.sh`. Mine is located in `/home/pi/HisenseTV.sh` as I find that easier. 
12. <B><I>OR</B></I> if you are less savvy like me, you can create the script in the homedrive of your raspberry pi using `sudo nano HisenseTV.sh` and pasting the contents inside, then saving. Its pathway will be `/home/pi/HisenseTV.sh`. <B><I>NOTE:</B></I> For HOOBS users this would create your shell scripts at the lcation: `/home/hoobs/.hoobs/HisenseTV.sh`.
13. Install [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4) plug-in through config-ui-x or via command: `sudo npm install -g --unsafe-perm homebridge-cmd4`. <B><I>NOTE:</B></I> you do not need to follow the extra installation steps on cmd4's page for this.
14. Add to your Homebridge `config.json` file (easiest done through `homebridge-confi-ui-x` web UI); use the `config_sample.json` file. This file contains all potential input sources, personally I would only add the ones you use as there are 24. <B><I>NOTE:</B></I> do not change the values of `"identifier"` for each input source or they will no longer work.
15. Restart Homebridge and all should be well... Unless you are me and everything I do goes wrong several times before it goes right haha.

## Known Bug:
The following Hisense TV Apps added as input sources do not seem to work:
- ABC IVIEW
- YouTube Kids
- SBS ON DEMAND
- Kidoodle.TV
- Game Center

## Troubleshooting:
- After `Step 9` and before `Step 10`; you can run the following two commands to see that you have the certs and your MAC Address correct. If the following commands do not work, then you have done something wrong with the certificatess or the MAC Addressfor the paired device and it is the not a problem the shell script or `homebridge-cmd4`. 
- To turn on the TV execute `wakeonlan XX:XX:XX:XX:XX:XX` (replace with the MAC Address of your TV) from your terminal.
- To turn off the TV execute `mosquitto_pub --cafile /home/pi/hisense.crt --insecure -h IP_ADDRESS -p 36669 -P multimqttservice -u hisenseservice -t "/remoteapp/tv/remote_service/XX:XX:XX:XX:XX:XX$normal/actions/sendkey" -m "KEY_POWER"` (replace with the certificate file path, the IP Address of your TV and the MAC Address of your paired device). I can't remember if these commands needs a `sudo` in front or not.

## Special Thanks:
1. None of this would have been possible without the patience and kindness of [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4) developer John Talbot; who did not have to help me at all, but worked through my script and errors, and put up with my stupid questions.
2. My wife who has put up with what has become an obsession to get yet another device in Homekit.
