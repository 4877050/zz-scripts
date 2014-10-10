# Overview

nsupdate.rb - Dynamic add A Records and reverse lookups to your DNS Server
* Version [0.0.1]

### Examples 

    Add a single A Record:    
    
        yieldex_dns.rb -a -n <hostname> -i <ipaddress>

    Delete a single A Record: 
        
        yieldex_dns.rb -d -n <hostname> -i <ipaddress>

    Add A Records from file:    
        yieldex_dns.rb -a -f <filename>

    Delete A Records from file: 
    
        yieldex_dns.rb -d -f <filename>

    Verbose:            
        yieldex_dns.rb -a -n <hostname> -i <ipaddress> -s <dnsserver> -t <ttl> -k <keylocation>

### Requirements
Dynamic Bind setup

# Credits

Developed by [Zachary Zager](http://www.zeninfinity.com) at [Zen Infinity](http://www.zeninfinity.com)

