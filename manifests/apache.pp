class otrs::apache {

  include apache

  apache::vhost { $otrs::sitename:
    priority        => '01',
    docroot         => '/var/www',
    port            => '80',
    serveraliases   => [ $::fqdn ],
    template        => 'otrs/vhost-otrs.conf.erb',
  }
}
