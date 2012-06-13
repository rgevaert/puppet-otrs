class otrs (  $release,
              $sitename               = $fqdn,
              $ensure                 = present,
              $cronjobs               = 'absent',
              $serveradmin            = "root@${::fqdn}",
              $generic_agent_template = 'otrs/GenericAgent.erb',
              $configpm_template      = 'otrs/Config.erb')
{

  class {'otrs::user':;} ~>
    class {'otrs::packages':;} ~>
    class {'otrs::apache':;} ~>
    class {'otrs::cron':;}

  class {'otrs::conf':;}
}
