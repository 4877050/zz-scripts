Collins=collins-prod.den1.yieldex.com:8080

echo -n password:
read -s password


#Assign a hostname
#curl --basic -u `whoami`:$password --data-urlencode "attribute=hostname;$hostname" "http://${Collins}/api/asset/$tag"

#Assign an ip address
#curl --basic -u `whoami`:$password -X PUT -d pool=LEAF75 "http://${Collins}/api/asset/$tag/address"

# Move to an unallocated state

attribute=PRIMARY_ROLE
value=mapr-worker
reason="reinstalling the OS"


for hn in `cat hn`
do
    echo $hn;
    cd ~/git/chef/
    yes | knife node delete $hn 
    yes | knife client delete $hn 

    #curl --basic -u `whoami`:$password  -d action=rebootSoft "http://collins-prod.den1.yieldex.com:8080/api/asset/$tag/power"
    #curl --basic -u `whoami`:$password -d status=Unallocated --data-urlencode "reason=${reason}" "http://collins-prod.den1.yieldex.com:8080/api/asset/$tag/status"
done



