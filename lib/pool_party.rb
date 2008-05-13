=begin rdoc
  The main file, contains the client and the server application methods
=end
$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

# rubygems
require 'rubygems'
require "aws/s3"
require "sqs"
require "EC2"
require "rack"
require 'thread'
begin
  require 'fastthread'
  require 'thin'
rescue LoadError
end

## Load PoolParty
pwd = File.dirname(__FILE__)

%w(core modules s3 pool_party).each do |dir|  
  Dir["#{pwd}/#{dir}"].each do |dir|
    begin
      require File.join(dir, "init")
    rescue LoadError => e
      Dir["#{pwd}/#{File.basename(dir)}/**"].each {|file| require File.join(dir, File.basename(file))}
    end
  end
end

module PoolParty
  extend self
  
  module Version
    MAJOR = '0'
    MINOR = '0'
    REVISION = '2'
    def self.combined
      [MAJOR, MINOR, REVISION].join('.')
    end
  end
  
  # Starts a new attendee without launching a new instance
  # def client(conf="../config/config.yml", opts={})
  #   Organizer.options(opts)
  #   Organizer.config_file=conf
  #   Attendee.new(:dont_run => true).monitor! unless Organizer.development?
  # end
  # Starts the new server host to monitor the instances
  def server(opts={})
    [Host.new, Application.options(opts)]
  end
  
  def client
    LocalInstance.new.start!
  end
  
end