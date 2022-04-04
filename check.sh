#!/bin/sh                                                                                                                                                                                                                                                                                           
echo "$(date +'%a %b %d %H:%M:%S %Y') Start Openvpn Check";                                                                                           
                                                                                                                                                  
OUT="$(ip a show hvh up 2>&1)";                                                                                                                   
                                                                                                                                                  
if [ "$OUT" != "${OUT/does not exist./}" ]; then                                                                                                  
                                                                                                                                                  
 pid="$(ps -ef |grep "[o]penvpn --config /mnt/data/split-vpn/openvpn/hvh/hvh-real.ovpn" | awk -F" " '{ print $1}')"                               
 if [ -z "$pid" ]; then                                                                                                                           
  echo "$(date +'%a %b %d %H:%M:%S %Y') No PID";                                                                                                  
 else                                                                                                                                             
  echo "$(date +'%a %b %d %H:%M:%S %Y') PID ID $pid"                                                                                              
 fi                                                                                                                                               
                                                                                                                                                  
                                                                                                                                                  
 ip="$(nslookup hvh.huisch.nl 1.1.1.1 | grep ^Name -A1 | grep ^Address | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")"                           
                                                                                                                                                  
 timeout 10 tcpdump -npi ppp0 port 1321 > /mnt/data/dump.txt                                                                                      
                                                                                                                                                  
 for i in `awk -F" " '{ print $3}' /mnt/data/dump.txt`                                                                                            
 do                                                                                                                                               
    port="$(echo $i | awk -F"." '{print $5}')"                                                                                                    
                                                                                                                                                  
    if [ "$ip.$port" = "$i" ]; then                                                                                                               
    myport="$(cat /run/hvh.port)"                                                                                                                 
    echo "$(date +'%a %b %d %H:%M:%S %Y') Found port: $port"                                                                                      
    if [ "$port" == "$myport" ] && [ -d "/proc/$pid)" ]; then                                                                                     
      echo "$(date +'%a %b %d %H:%M:%S %Y') Same port: $port"                                                                                     
      break                                                                                                                                       
    fi                                                                                                                                            
    sed 's/--remote.*/--remote '$ip' '$port'/' /mnt/data/split-vpn/openvpn/hvh/hvh.ovpn > /mnt/data/split-vpn/openvpn/hvh/hvh-real.ovpn           
    if [ -z "$pid" ]; then                                                                                                                        
     echo "$(date +'%a %b %d %H:%M:%S %Y') Nothing to do (No PID) "                                                                               
     else                                                                                                                                          
      if [ -d "/proc/$pid" ]; then                                                                                                                
        echo "$(date +'%a %b %d %H:%M:%S %Y') Stop server"                                                                                        
        kill -9 "$pid"                                                                                                                            
        sleep 5                                                                                                                                   
      fi                                                                                                                                          
    fi                                                                                                                                            
    echo "$(date +'%a %b %d %H:%M:%S %Y') Start HvH openvpn server"                                                                               
    >/run/hvh.port echo "$port"                                                                                                                   
    printf "done\n"                                                                                                                               
    break                                                                                                                                         
   fi                                                                                                                                             
                                                                                                                                                  
 done                                                                                                                                             
else                                                                                                                                              
 echo "$(date +'%a %b %d %H:%M:%S %Y') HvH is UP!";                                                                                               
fi  