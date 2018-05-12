#!/bin/bash

vpns=vpns.txt
urls=urls.txt
declare -a vpnsArray
declare -a urlsArray
vpnsArray=(`cat "$vpns"`)
urlsArray=(`cat "$urls"`)

cd /etc/openvpn
echo "Opening script..."

for vpn in ${!vpnsArray[@]}; do

    openvpn ovpn_udp/${vpnsArray[$vpn]} &>/dev/null &
    sleep 15
    echo "Connecting to VPN ${vpnsArray[$vpn]}..."

    for url in ${!urlsArray[@]}; do

        echo "Opening browser (incognito mode) @ URL ${urlsArray[$url]}..."
        google-chrome ${urlsArray[$url]} --incognito --no-sandbox &>/dev/null &

        sleep 30
        echo "Closing browser (incognito mode) @ URL ${urlsArray[$url]}..."
        wmctrl -c "Google Chrome"
        sleep 3

    done

    sleep 10
    echo "Closing VPN ${vpnsArray[$vpn]}..."
    conexion=`ifconfig | grep ^tun | awk '{ print $1 }'`
    nmcli con down id $conexion &>/dev/null &
    sleep 3

done

sleep 3
echo "Closing script..."