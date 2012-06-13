define otrs::theme {
  file{
    "/opt/otrs-${otrs::release}/Kernel/Output/HTML/${name}":
      ensure  => directory,
      recurse => true,
      source  => ["puppet:///modules/otrs/themes/${otrs::release}/${name}", "puppet:///modules/otrs/themes/otrs-default/${name}"],
      group   => 'www-data',
      mode    => '2775',
      owner   => 'otrs';
  }
}
