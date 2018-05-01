require 'spec_helper'

describe 'puppet_device' do
  let(:pre_condition) do
    [
      'class cisco_ios {}',
      'class f5 {}',
    ]
  end

  context 'declared on a device' do
    let(:title)  { 'cisco.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'cisco_ios',
      }
    end
    let(:facts) do
      {
        :os => { :family => 'cisco_ios' },
      }
    end

    it { is_expected.to raise_error(%r{declared on a device}) }
  end

  context 'declared on Linux, running Puppet 5.0, with values for all device.conf parameters' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('F5') }
  end

  context 'declared on Windows, running Puppet 5.0, with values for all device.conf parameters' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :debug        => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppet_settings_confdir      => 'C:/ProgramData/PuppetLabs/puppet',
        :os                           => { :family => 'windows' },
        :env_windows_installdir       => 'C:\\Program Files\\Puppet Labs\\Puppet',
      }
    end

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('F5') }
  end

  context 'declared on Linux, running Puppet 4.10, with run_interval' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '4.10.0',
        :puppetversion                => '4.10.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('F5') }
    it { is_expected.to contain_puppet_device__run__via_cron__device(title) }
    it {
      is_expected.to contain_cron('run puppet_device').with(
        'command' => '/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root --verbose',
      )
    }
  end

  context 'declared on Linux, running Puppet 5.0, with run_interval' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('F5') }
    it { is_expected.to contain_puppet_device__run__via_cron__device(title) }
    it {
      is_expected.to contain_cron("run puppet_device target #{title}").with(
        'command' => "/opt/puppetlabs/puppet/bin/puppet device --waitforcert=0 --user=root --verbose --target=#{title}",
        'hour'    => '*',
      )
    }
  end

  context 'declared on Windows, running Puppet 5.0, with run_interval' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => 'C:/ProgramData/PuppetLabs/puppet/etc/device.conf',
        :puppet_settings_confdir      => 'C:/ProgramData/PuppetLabs/puppet',
        :os                           => { :family => 'windows' },
        :env_windows_installdir       => 'C:\\Program Files\\Puppet Labs\\Puppet',
      }
    end

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('F5') }
    it { is_expected.to contain_puppet_device__run__via_scheduled_task__device(title) }
    it {
      is_expected.to contain_scheduled_task("run puppet_device target #{title}").with(
        'command' => 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet',
      )
    }
  end

  # The puppet command is quoted in this Exec to support spaces in the path on Windows.

  context 'declared on Linux, running Puppet 5.0, with run_via_exec' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => 'present',
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_via_exec => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('F5') }

    it { is_expected.to contain_puppet_device__run__via_exec__device(title) }
    it {
      is_expected.to contain_exec("run puppet_device target #{title}").with(
        'command' => %("/opt/puppetlabs/puppet/bin/puppet" device --waitforcert=0 --user=root --verbose --target=#{title}),
      )
    }
  end

  context 'declared on Linux, running Puppet 5.0, with run_interval and run_via_exec parameters' do
    let(:title)  { 'f5.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'f5',
        :url          => 'https://admin:fffff55555@10.0.0.245/',
        :run_interval => 30,
        :run_via_exec => true,
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.0.0',
        :puppetversion                => '5.0.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to raise_error(%r{are mutually-exclusive}) }
  end

  context 'declared on Linux, running Puppet 5.5, with credentials' do
    let(:title)  { 'cisco.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'cisco_ios',
        :credentials  => { 'address' => '10.0.0.245', 'port' => 22, 'username' => 'admin', 'password' => 'cisco', 'enable_password' => 'cisco' },
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.5.0',
        :puppetversion                => '5.5.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end
    let(:device_yaml_file) { "/etc/puppetlabs/puppet/devices/#{title}.yaml" }

    it { is_expected.to contain_puppet_device(title) }
    it { is_expected.to contain_class('puppet_device::conf') }
    it { is_expected.to contain_class('puppet_device::fact') }
    it { is_expected.to contain_class('Cisco_ios') }

    # TODO: Identify the rspec syntax for matching an attribute value containing newlines.
    # Or, Identify the rspec syntax for substring matching an attribute value.
    # it {
    #   is_expected.to contain_concat_fragment("puppet_device_conf [#{title}]").with('content').including("url file://#{device_yaml_file}")
    # }

    it {
      is_expected.to contain_hocon_setting("#{title}_address").with(
        'path'    => device_yaml_file,
        'setting' => 'default.node.address',
        'value'   => '10.0.0.245',
      )
    }
    it {
      is_expected.to contain_hocon_setting("#{title}_port").with(
        'path'    => device_yaml_file,
        'setting' => 'default.node.port',
        'value'   => '22',
      )
    }
    it {
      is_expected.to contain_hocon_setting("#{title}_username").with(
        'path'    => device_yaml_file,
        'setting' => 'default.node.username',
        'value'   => 'admin',
      )
    }
    it {
      is_expected.to contain_hocon_setting("#{title}_password").with(
        'path'    => device_yaml_file,
        'setting' => 'default.node.password',
        'value'   => 'cisco',
      )
    }
    it {
      is_expected.to contain_hocon_setting("#{title}_enable_password").with(
        'path'    => device_yaml_file,
        'setting' => 'default.node.enable_password',
        'value'   => 'cisco',
      )
    }
  end

  context 'declared on Linux, running Puppet 5.5, with credentials and url parameters' do
    let(:title)  { 'cisco.example.com' }
    let(:params) do
      {
        :ensure       => :present,
        :type         => 'cisco_ios',
        :credentials  => { 'address' => '10.0.0.245', 'port' => 22, 'username' => 'admin', 'password' => 'cisco', 'enable_password' => 'cisco' },
        :url          => 'https://admin:cisco@10.0.0.245/',
      }
    end
    let(:facts) do
      {
        :aio_agent_version            => '5.5.0',
        :puppetversion                => '5.5.0',
        :puppet_settings_deviceconfig => '/etc/puppetlabs/puppet/device.conf',
        :puppet_settings_confdir      => '/etc/puppetlabs',
        :os                           => { :family => 'redhat' },
      }
    end

    it { is_expected.to raise_error(%r{are mutually-exclusive}) }
  end
end
