module PoolParty
  class Tasks
    include Callbacks
    
    # Setup and define all the tasks
    def initialize
      yield self if block_given?
    end
    # Define the tasks in the rakefile
    # From the rakefile
    def define_tasks
      # Run the command on the local system
      def run(cmd)
        system(cmd.runnable)
      end
      # Basic setup action
      def setup_application
        PoolParty.options({:config_file => (ENV["CONFIG_FILE"] || ENV["config"]) })
      end
      
      # Require the poolparty specific tasks
      Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].each { |t| eval open(t).read }
      
      Dir["#{PoolParty.plugin_dir}/*/Rakefile"].each {|t| load File.expand_path(PoolParty.root_dir + "/" + t) }
      
      true
    end    
  end
end