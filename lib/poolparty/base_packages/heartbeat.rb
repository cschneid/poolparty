module PoolParty
  class Base
    plugin :heartbeat do
      
      def enable
        execute_if("$hostname", "master") do
          has_package(:name => "heartbeat-2", :ensure => "installed") do
            # These can also be passed in via hash
            has_remotefile(:name => "/etc/ha.d/ha.cf") do
              mode 444
              notify 'Service["heartbeat"]'
              template File.join(File.dirname(__FILE__), "..", "templates/ha.cf")
            end

            has_remotefile(:name => "/etc/ha.d/authkeys") do
              mode 400
              notify 'Service["heartbeat"]'
              template File.join(File.dirname(__FILE__), "..", "templates/authkeys")
            end

            has_remotefile(:name => "/etc/ha.d/cib.xml") do
              mode 444
              notify 'Exec["heartbeat-update-cib"]'
              template File.join(File.dirname(__FILE__), "..", "templates/cib.xml")
            end
            
            has_service(:name => "heartbeat", :hasstatus => true)
          end          
        
          has_exec(:name => "heartbeat-update-cib", :command => "/usr/sbin/cibadmin -R -x /etc/ha.d/cib.xml", :refreshonly => true)
          
          if @parent.provisioning?
            variable(:name => "ha_nodenames", :value => "#{list_of_running_instances.map{|a| "#{a.send :name}" }.join("\t")}")
            variable(:name => "ha_node_ips",  :value => "#{list_of_running_instances.map{|a| "#{a.send :ip}" }.join("\t")}")
          else
            # variables for the templates
            variable(:name => "ha_nodenames", :value => "generate('/usr/bin/env', '/var/lib/gems/1.8/bin/server-list-active', '-c', 'name')")
            variable(:name => "ha_node_ips",  :value => "generate('/usr/bin/env', '/var/lib/gems/1.8/bin/server-list-active', '-c', 'ip')")
          end
          
          has_variable({:name => "ha_timeout",  :value => (self.respond_to?(:timeout) ? timeout : "5s")})
          has_variable({:name => "ha_port", :value => (self.respond_to?(:port) ? port : Base.port)})
          
        end
        
        execute_if("$hostname", "master") do
          if list_of_node_names.size > 1
            has_exec(:name => "update pem for heartbeat", :refreshonly => true) do
              command "scp /etc/puppet/ssl/ca/ca_crl.pem #{user || Base.user}@#{list_of_node_ips[1]}:/etc/puppet/ssl/ca"
            end
          end
        end
        
      end
    end  
  end
end