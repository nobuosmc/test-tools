# #!/bin/bash

file="1node_dcmi_rccl.csv"

ip1="172.27.47.201"
ip2="172.27.47.202"
ip3="172.27.47.203"
ip4="172.27.47.204"
pwd1="AZTBXYIIOZ"
pwd2="EKCGXHHLKG"
pwd3="HHXQOMVVII"
pwd4="PHOETTTCKL"

[[ -e $file ]] && rm $file

touch $file

# # echo "Instant(W),Min.Sample(W),Max.Sample(W),Avg.Sample(W),IPMI_Time,Period(Sec.),State,Sys.Time" >> $file
echo "Sys.Time,Instant(W)" >> $file

function get_power(){
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
        # echo "$(date +"%Y-%m-%d %H:%M:%S")," "$(ipmitool -I lan -H $1 -U ADMIN -P $2 sdr elist | grep PW | awk '{print $10}')" >> $file;
        power=`ipmitool -I lan -H $1 -U ADMIN -P $2 sdr elist | grep PW | awk '{print $10}'`
        echo $power
    }
}


for i in {1..1000}
do 
    # pwr1=$(get_power $ip1 $pwd1)&&
    # pwr2=$(get_power $ip2 $pwd2)&&
    pwr3=$(get_power $ip3 $pwd3)&&
    # pwr4=$(get_power $ip4 $pwd4)
    
    # sum=`expr $pwr2 + $pwr3 + $pwr4`

    echo "$(date +"%Y-%m-%d %H:%M:%S"), $pwr3" >> $file

    sleep 1
done

