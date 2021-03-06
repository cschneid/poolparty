module PoolParty
  module Provisioner
    class Master < ProvisionerBase
      
      def initialize(cloud=self, os=:ubuntu)
        super(cloud.master, cloud, os)
        @master_ip = cloud.master.ip
      end

      def valid?
        !(@cloud.nil? || @cloud.master.nil?)
      end

      def error
        raise RemoteException.new(:could_not_install, "Your cloud does not have a master")
      end

      def install_tasks
        [
          install_haproxy,
          install_heartbeat,
          create_local_hosts_entry,
          setup_basic_structure,
          setup_configs,        
          setup_fileserver,
          setup_autosigning,          
        ] << configure_tasks
      end

      def configure_tasks
        [
          # start_puppetmaster,
          create_local_node,
          move_templates,
          create_poolparty_manifest,
          restart_puppetd,
          start_poolparty_messenger
        ]
      end
      
      # If the master is not in the hosts file, then add it to the hosts file
      def create_local_hosts_entry
        <<-EOS
if [ -z \"$(grep -v '#' /etc/hosts | grep 'master')" ]; then echo '#{@master_ip}           puppet master' >> /etc/hosts; fi
        EOS
      end

      def setup_basic_structure
        <<-EOS
puppetmasterd --mkusers
mkdir -p #{Base.remote_storage_path}
echo "import 'nodes/*.pp'" > /etc/puppet/manifests/site.pp
echo "import 'classes/*.pp'" >> /etc/puppet/manifests/site.pp
mkdir -p /etc/puppet/manifests/nodes 
mkdir -p /etc/puppet/manifests/classes
cp #{Base.remote_storage_path}/namespaceauth.conf /etc/puppet/namespaceauth.conf
        EOS
      end

      def setup_configs
        <<-EOS
echo "#{open(File.join(template_directory, "puppet.conf")).read}" > /etc/puppet/puppet.conf
        EOS
      end

      def setup_fileserver
        <<-EOS
echo "
[files]
  path #{Base.remote_storage_path}
  allow *" > /etc/puppet/fileserver.conf
mkdir -p /var/poolparty/facts
mkdir -p /var/poolparty/files
mkdir -p /etc/poolparty
        EOS
      end
      # Change this eventually for better security supportsetup_fileserver
      def setup_autosigning
        <<-EOS
echo "*" > /etc/puppet/autosign.conf
        EOS
      end

      def create_local_node
        str = <<-EOS
node default {
  include poolparty
}
        EOS
         @cloud.list_of_running_instances.each do |ri|
           str << <<-EOS           
node "#{ri.name}" inherits default {}
           EOS
         end
"echo '#{str}' > /etc/puppet/manifests/nodes/nodes.pp"
      end

      def move_templates
        <<-EOS
mkdir -p #{Base.template_path}
cp #{Base.remote_storage_path}/#{Base.template_directory}/* #{Base.template_path}
        EOS
      end
      
      def create_poolparty_manifest
        <<-EOS
cp #{Base.remote_storage_path}/poolparty.pp /etc/puppet/manifests/classes/poolparty.pp
cp #{Base.remote_storage_path}/#{Base.key_file_locations.first} "#{Base.base_config_directory}/.ppkeys"
cp #{Base.remote_storage_path}/#{Base.default_specfile_name} #{Base.base_config_directory}/#{Base.default_specfile_name}
#{copy_ssh_app}
        EOS
      end
      
      def copy_ssh_app
        if @cloud.remote_keypair_path != "#{Base.remote_storage_path}/#{@cloud.full_keypair_name}"
          "cp #{Base.remote_storage_path}/#{@cloud.full_keypair_name} #{@cloud.remote_keypair_path}"
        end
      end

      # ps aux | grep puppetmasterd | awk '{print $2}' | xargs kill
      # rm -rf /etc/puppet/ssl
      # puppetmasterd --verbose
      def start_puppetmaster
        <<-EOS
        EOS
      end

      # puppetd --listen --fqdn #{@instance.name}
      def restart_puppetd
        <<-EOS
          killall ruby
          rm -rf /etc/puppet/ssl/*
          puppetmasterd --verbose
          . /etc/profile && #{@instance.puppet_runner_command}
          server-start-master
        EOS
      end
    end
  end
end