#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

INSTANCE_TYPES = ["t1.micro", "m1.small", "m1.large", "m1.xlarge", "m2.xlarge", "m2.2xlarge", "m2.4xlarge", "c1.medium", "c1.xlarge", "cc1.4xlarge", "cg1.4xlarge", ]
ROLES = ["iab_server", ]

DEFAULT_AMI = 'ami-405c6934'
DEFAULT_INSTANCE_TYPE = INSTANCE_TYPES[0]
DEFAULT_ROLES = [ROLES[0]]

options = {
  :name => '',
  :ami => DEFAULT_AMI,
  :instance_type => DEFAULT_INSTANCE_TYPE,
  :roles => DEFAULT_ROLES,
}

OptionParser.new do |opts|
  opts.banner = "Usage: ec2_create.rb [options]"
  opts.on("-n", "--name [NAME]", "NAME of chef node to be created (default is a generated name)") do |o|
    options[:name] = o
  end
  opts.on("-a", "--ami [AMI]", "ID of AMI to launch (default #{DEFAULT_AMI})") do |o|
    options[:ami] = o
  end
  opts.on("-i", "--instance_type [TYPE]", INSTANCE_TYPES, "TYPE of EC2 instance (default '#{DEFAULT_INSTANCE_TYPE}' from: #{INSTANCE_TYPES.join(', ')})") do |o|
    options[:instance_type] = o
  end
  opts.on("-r", "--role x,y,z", Array, "List of roles to assign to the new node (default '#{DEFAULT_ROLES.join(',')}' from: #{ROLES.join(', ')})") do |o|
    options[:roles] = o
  end
  opts.separator ""
  opts.separator "Common options:"
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

p options

role_spec = options[:roles].map {|r| "role[#{r}]"}.join(',')
if role_spec.include? "desktop"
  puts '*'*80
  puts "To connect VNC to this instance, do: ssh -L9000:localhost:5901 -i ../credentials/aws/euro-ifapps.pem ubuntu@HOST"
  puts "then ./start_vnc.sh via SSH and point a VNC client to localhost:9000"
  puts '*'*80
end

# Depends on:
#   ssh keypair euro-ifapps
#   security group (firewall config) 'euro-ifapps', which allows SSH
command = "knife ec2 server create --run-list '#{role_spec}' --image #{options[:ami]} --flavor #{options[:instance_type]} --node-name '#{options[:name]}' --config .chef/knife.rb --availability-zone eu-west-1a --region eu-west-1 --groups euro-ifapps --ssh-user ubuntu --ssh-key euro-ifapps --identity-file ../credentials/aws/euro-ifapps.pem"
puts command
exec command

