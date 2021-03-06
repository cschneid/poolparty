require File.dirname(__FILE__) + "/resource"

module PoolParty
  def available_custom_resources
    $available_custom_resources ||= []
  end
  module DefinableFact
    def define_fact(name, string="")
      
    end
  end

  module Resources
    
    def call_function(str, opts={}, &block)
      returning PoolParty::Resources::CallFunction.new(str, opts, &block) do |o|
        resource(:call_function) << o
      end
    end
                
    # Resources for function call
    class CallFunction < Resource
      def initialize(str="", opts={}, parent=self, &block)
        @str = str
        # super(opts, parent, &block)
      end
      def to_string(pre="")
        returning Array.new do |arr|
          arr << "#{pre}#{@str}"
        end.join("\n")
      end
    end
        
    class CustomResource < Resource
      def initialize(name=:custom_method, opts={}, parent=self, &block)
        @name = name
        super(opts, parent, &block)
      end
      
      def self.inherited(subclass)
        PoolParty::Resources.available_custom_resources << subclass
        super(subclass)
      end
      
      def to_string(pre="")
        returning Array.new do |output|
          output << "#{pre} # Custom Functions\n"
          output << self.class.custom_functions_to_string(pre)
        end.join("\n")        
      end
    end
    
    # Stub methods
    # TODO: Find a better solution
    def custom_function(*args, &block)
    end
    def self.custom_function(*args, &block)
    end      
    
  end    
end