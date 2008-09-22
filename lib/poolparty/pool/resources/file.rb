module PoolParty    
  module Resources
    
    def file(opts={}, &block)
      resource(:file) << PoolParty::Resources::File.new(opts, &block)
    end
    
    add_has_and_does_not_have_methods_for(:file)
    
    class File < Resource
      
      default_options({
        :ensure => "present",
        :mode => 644,
        :owner => "poolparty",
        :content => ""
      })
      
      def source
        File.join(Base.fileserver_base, name)
      end
      
    end
    
  end
end