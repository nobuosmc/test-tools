#!/bin/bash

powerConsumption="powerConsumption.csv"
inletTemp="inletTemp.csv"
gpuTemp="gpuTemp.csv"
fanSpeed="fanSpeed.csv"

ipmiIp="172.27.47.7"
ipmiUser="ADMIN"
ipmiPasswd="ADMIN"

[[ -e $file ]] && rm $file

touch $powerConsumption $inletTemp $gpuTemp $fanSpeed
# echo "Instant(W),Min.Sample(W),Max.Sample(W),Avg.Sample(W),IPMI_Time,Period(Sec.),State,Sys.Time" >> $file
echo "Sys.Time,Instant(W)" >> $powerConsumption >> $inletTemp >> $gpuTemp >> $fanSpeed

function get_metrics(){
    # {
    #     # ipmitool dcmi power reading | 
    #     ipmitool -I lan -H $ip -U ADMIN -P PHOETTTCKL dcmi power reading |
    #     cut -c 47- | 
    #     awk '{$1=$1;print}' | 
    #     sed -e '1,10s/ Watts//g' | 
    #     sed -e '1,10s/ Seconds.//g' | 
    #     grep -v '^[[:space:]]*$' | 
    #     tr '\n' ',' | 
    #     awk '{$1=$1;print}' ; 
    #     date +"%Y-%m-%d %H:%M:%S"; 
    # } | paste -s >> $file;
    {
        # echo "$(date +"%Y-%m-%d %H:%M:%S")," "$(ipmitool -I lan -H $ip -U ADMIN -P PHOETTTCKL sdr elist | grep PW | awk '{print $10}')" >> $file;
        echo "$(date +"%Y-%m-%d %H:%M:%S")," "$(ipmitool -H ipmiIp -U ipmiUser -P ipmiPasswd sensor | grep "^Fan [1-9].*" | awk '{print $13}')" >> $fanSpeed;
        echo "$(date +"%Y-%m-%d %H:%M:%S")," "$(ipmitool -H ipmiIp -U ipmiUser -P ipmiPasswd sensor | grep "^GPU.*" | awk '{print $5}')" >> $gpuTemp;
        echo "$(date +"%Y-%m-%d %H:%M:%S")," "$(ipmitool -H ipmiIp -U ipmiUser -P ipmiPasswd sensor | grep "^Inlet.*" | awk '{print $4}')" >> $inletTemp;
        # echo "$(date +"%Y-%m-%d %H:%M:%S")," "$(ipmitool -H ipmiIp -U ipmiUser -P ipmiPasswd sensor | grep "" >> $powerConsumption;
    }
    
    sleep 1
}

for i in {1..1000}; do get_metrics ; done

