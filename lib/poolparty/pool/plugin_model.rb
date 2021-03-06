require File.join(File.dirname(__FILE__), "resource")

module PoolParty    
  module PluginModel
    
    def plugin(name=:plugin, cloud=nil, &block)
      plugins.has_key?(name) ? plugins[name] : (plugins[name] = PluginModel.new(name, cloud, &block))
    end
    alias_method :register_plugin, :plugin
    
    def plugins
      $plugins ||= {}
    end
    
    class PluginModel      
      attr_accessor :name, :klass
      attr_reader :parent
      include MethodMissingSugar
      include Configurable
      include PrettyPrinter      
      
      def initialize(name,cld,&block)
        @name = name
        @parent = cld
        class_string_name = "#{name}"
        
        # Create the class to evaluate the plugin on the implemented call
        klass = class_string_name.class_constant(PoolParty::Plugin::Plugin)
        klass.extend PoolParty::Resources
        klass.send :include, PoolParty::Resources

        # Create the block inside the instantiated plugin
        klass.module_eval &block if block
        
        # Store the name of the class for pretty printing later
        klass.name = name
        # Add the plugin definition to the cloud as an instance method
        Cloud::Cloud.module_eval <<-EOE
          def #{name}(parent=self, &block)
            @#{class_string_name.downcase} ||= #{class_string_name.class_constant}.new(parent, &block)
          end
        EOE
      end
      
    end
    
  end
end