#!/usr/bin/env ruby
require 'optparse'
require 'pp'
require 'ipaddr'
require 'fileutils'


##IMPORT VARS
load './defaults.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Example: \n
    Add a single A Record:    nsupdate.rb -a -n <hostname> -i <ipaddress> 
    Delete a single A Record: nsupdate.rb -d -n <hostname> -i <ipaddress> 
    Add A Records from file:    nsupdate.rb -a -f <filename>
    Delete A Records from file: nsupdate.rb -d -f <filename>
    Verbose:            nsupdate.rb -a -n <hostname> -i <ipaddress> -s <dnsserver> -t <ttl> -k <keylocation> \n\n"

  opts.on("-a", "--add", "Add a host") do |v|
    options[:add] = v
  end

  opts.on("-d", "--delete", "Delete a host") do |v|
    options[:del] = v
  end

  opts.on("-n", "--hostname hostname", "Specify Hostname") do |v|
    options[:host] = v
  end

  opts.on("-i", "--ip ip", "Specify IP Address") do |v|
    options[:ip] = v 
  end

  opts.on("-f", "--from-file file", "Input from file") do |v|
    options[:file] = v
  end

  opts.on("-s", "--server server", "Specify DNS server") do |v|
    options[:server] = v
  end

  opts.on("-k", "--key-location key", "Specify DNS key location") do |v|
    options[:key] = v
  end

  opts.on("-t", "--ttl ttl", "Set Time To Live") do |v|
    options[:ttl] = v
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end

#  opts.on("-c", "--cname", "Create CNAME") do |v|
#    options[:cname] = v
#  end
end.parse!

#options = OptparseExample.parse(ARGV)


##CHECK VARS
#Check server - set to default if empty
if !options[:server]
  options[:server]=$defaultserver
end

#Check key - set to default if empty
if !options[:key]
  options[:key]=$defaultkeylocation
end

#Check neither add and delete
if !options[:add] && !options[:del]
  abort("ERROR: Need Add or Delete switch.  Run with -h for help")
end

#Check not both add and delete
if options[:add] && options[:del]
  abort("ERROR: Add and Delete switches cannot be used together")
end

#Check ttl - set to default if empty
if !options[:ttl]
  options[:ttl]=$defaultttl
end

#Check if add - check ip
if !options[:file] && !options[:ip]
  abort("ERROR: No IP - Specify IP with -i <ipaddress>")
end

##CLASSES
class Nsupdate
  def create_reverse(ip)
    reverse=IPAddr.new(ip).reverse
    reverse+="."
    return reverse
  end

  def check_hostname(host)
    if host[-1, 1]!="."
      #puts "Appending \".\" to hostname"
      host+="."
    end
    return host
  end

  def add_a_record(hostname, ip, ttl, server, key)
    IO.popen("nsupdate -k #{key} -v", 'r+') do |f|
    f << <<-EOF
      server #{server}
      update add #{hostname} #{ttl} A #{ip}
      show
      send
    EOF
    f.close_write
    puts f.read
  end
  end

  def del_a_record(hostname, ip, ttl, server, key)
    IO.popen("nsupdate -k #{key} -v", 'r+') do |f|
      f << <<-EOF
        server #{server}
        update delete #{hostname} #{ttl} A #{ip}
        show
        send
      EOF
      f.close_write
      puts f.read
    end
  end

  def add_reverse_record(hostname, reverse, ttl, server, key)
    IO.popen("nsupdate -k #{key} -v", 'r+') do |f|
    f << <<-EOF
      server #{server}
      update add #{reverse} #{ttl} IN PTR #{hostname}
      show
      send
      EOF
      f.close_write
      puts f.read
    end
  end

  def del_reverse_record(hostname, reverse, ttl, server, key)
    IO.popen("nsupdate -k #{key} -v", 'r+') do |f|
      f << <<-EOF
        server #{server}
        update delete #{reverse}
        show
        send
      EOF
      f.close_write
      puts f.read
    end
  end
end
  
#CLEANUP
if !options[:file]
  hostname= Nsupdate.new.check_hostname(options[:host])
  server = options[:server]
  key = options[:key]
  ip = options[:ip]
  ttl = options[:ttl]
  reverse = Nsupdate.new.create_reverse(options[:ip])
end


#CODE
if options[:add] && !options[:file]
  Nsupdate.new.add_a_record(hostname, ip, ttl, server, key)
  Nsupdate.new.add_reverse_record(hostname, reverse, ttl, server, key)
elsif options[:del] && !options[:file]
  Nsupdate.new.del_a_record(hostname, ip, ttl, server, key)
  Nsupdate.new.del_reverse_record(hostname, reverse, ttl, server, key)
elsif options[:file]
  file = File.open(options[:file]).each do |line|
    line=line.chomp!.split(/\.?\s+/)
    options[:host]=line[0]
    options[:ip]=line[1]
    hostname = Nsupdate.new.check_hostname(options[:host])
    server = options[:server]
    key = options[:key]
    ip = options[:ip]
    ttl = options[:ttl]
    reverse = Nsupdate.new.create_reverse(options[:ip])
    if options[:add]
      Nsupdate.new.add_a_record(hostname, ip, ttl, server, key)
      Nsupdate.new.add_reverse_record(hostname, reverse, ttl, server, key)
    elsif options [:del]
      Nsupdate.new.del_a_record(hostname, ip, ttl, server, key)
      Nsupdate.new.del_reverse_record(hostname, reverse, ttl, server, key)
    end
  end
end
