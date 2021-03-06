module PoolParty
  module DependencyResolutions
    module Puppet
      
      def pretty_print_resources(pre=" ")
        returning Array.new do |out|
          resources.each do |name, res|
            out << "#{pre}#{name}"
            out << "#{pre*2}#{res.map {|a| a.name}}"
            res.each do |r|
              out << "#{pre*2}#{r.pretty_print_resources(pre*2)}"
            end
          end
        end.join("\n")
      end
      
      # Generic to_s
      # Most Resources won't need to extend this
      def to_string(pre="")
        opts = get_modified_options
        returning Array.new do |output|
          unless cancelled?
            output << @prestring || ""
          
            if resources && !resources.empty?
              @cp = classpackage_with_self(self)
              output << @cp.to_string
              output << "include #{@cp.name.sanitize}"
            end
            
            unless virtual_resource?
              output << "#{pre}#{class_type_name.downcase} {"
              output << "#{pre}\"#{self.key}\":"
              output << opts.flush_out("#{pre*2}").join(",\n")
              output << "#{pre}}"            
            end
          
            output << @poststring || ""
          end
        end.join("\n")
      end
      
      def to_s
        "#{class_type_name.capitalize}['#{key}']"
      end
      
    end
  end
end