#!/bin/bash 

cd /home/spot

if ! [ -d foobar ]; then 
  tar xf /etc/ccs/foobar.tar
fi

chromium --proxy-server="http://192.168.0.101:80" --proxy-bypass-list="localhost;127.0.0.1;<local>;*.local;192.168.0.0/16;192.168.*;online.drivers-circle.co.za;*.drivers-circle.co.za;hermod;nana;herfjotur;freya;dc;hermoor;dco" --user-data-dir="/home/spot/foobar"
