#!/bin/bash

# Leemos archivos con lista de VPNs y URLs
vpns=vpns.txt
urls=urls.txt
declare -a vpnsArray
declare -a urlsArray
vpnsArray=(`cat "$vpns"`)
urlsArray=(`cat "$urls"`)

cd /etc/openvpn
echo "Iniciando script..."

originalIP=`curl ipinfo.io/ip`
echo "Tu IP original es: $originalIP"

for url in ${!urlsArray[@]}; do

    # Seleccionamos VPN al azar y realizamos la conexión
    echo "Seleccionando VPN..."
    selectedVpn=${vpnsArray[$RANDOM % ${#vpnsArray[@]} ]}
    openvpn ovpn_udp/$selectedVpn &>/dev/null &
    sleep 15

    vpnIP=`curl ipinfo.io/ip`

    if [ $originalIP == $vpnIP ]
    then
        echo "+++ERROR: No se pudo conectar al VPN $selectedVpn..."
        # Descartamos VPN
        sleep 10
        echo "Descartando VPN $selectedVpn..."
        conexion=`ifconfig | grep ^tun | awk '{ print $1 }'`
        nmcli con down id ${conexion//[:]/} &>/dev/null &
        ifconfig ${conexion//[:]/} down &>/dev/null &
        echo "........................................................................."
        sleep 3
    else
        echo "Conectado a VPN $selectedVpn..."
        echo "Nueva IP asignada: $vpnIP"

        # Abrimos navegador en modo incógnito
        echo "Abriendo navegador en modo incógnito con URL ${urlsArray[$url]}..."
        google-chrome ${urlsArray[$url]} --incognito --no-sandbox &>/dev/null &

        # Cerramos navegador en tiempo aleatorio luego de registrar la visita
        visitTime=`shuf -i 30-60 -n 1`
        sleep $visitTime
        echo "Cerrando el navegador incógnito con URL ${urlsArray[$url]} tras $visitTime segundos..."
        wmctrl -c "Google Chrome"
        echo "................................."
        sleep 3

        # Desconectamos VPN
        sleep 10
        echo "Desconectando VPN $selectedVpn..."
        conexion=`ifconfig | grep ^tun | awk '{ print $1 }'`
        nmcli con down id ${conexion//[:]/} &>/dev/null &
        ifconfig ${conexion//[:]/} down &>/dev/null &
        echo "........................................................................."
        sleep 3
    fi

done

# Finalizamos script
sleep 3
echo "Finalizando script..."