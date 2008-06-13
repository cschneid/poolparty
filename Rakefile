require 'rubygems'
require 'echoe'
require 'lib/poolparty'

task :default => :test

Echoe.new("poolparty") do |p|
  p.author = "Ari Lerner"
  p.email = "ari.lerner@citrusbyte.com"
  p.summary = "Run your entire application off EC2, managed and auto-scaling"
  p.url = "http://blog.citrusbyte.com"
  p.dependencies = %w(aws-s3 amazon-ec2 aska git)
  p.install_message =<<-EOM
    Thanks for installing PoolParty!
    
    Please check out the documentation for any questions or check out the google groups at
    http://groups.google.com/group/poolpartyrb
    
    Don't forget to check out the plugins for extending PoolParty!
    
    For more information, check http://poolpartyrb.com
    *** Ari Lerner @ <ari.lerner@citrusbyte.com> ***
  EOM
  p.include_rakefile = true
end

PoolParty.include_tasks