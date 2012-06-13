class otrs::conf {

  file {
    "/opt/otrs-${otrs::release}/var/tmp":
      ensure => directory,
      owner  => 'otrs',
      group  => 'www-data',
      mode   => '2775';
    "/opt/otrs-${otrs::release}/var/tmp/CacheFileStorable":
      ensure => directory,
      owner  => 'otrs',
      group  => 'www-data',
      mode   => '2775';
    '/opt/otrs':
      ensure  => link,
      target  => "/opt/otrs-${otrs::release}";
    "/opt/otrs-${otrs::release}/Kernel/GenericAgent.pm":
      ensure  => present,
      owner   => 'otrs',
      group   => 'www-data',
      mode    => '0664',
      content => template($otrs::generic_agent_template);
    "/opt/otrs-${otrs::release}/Kernel/Config.pm":
      ensure  => present,
      owner   => 'otrs',
      group   => 'www-data',
      mode    => '0664',
      content => template($otrs::configpm_template);


  }

}
