define otrs::customization {
  file{
    "/opt/otrs-${otrs::release}/Custom/":
      ensure  => directory,
      recurse => true,
      source  => ["puppet:///modules/otrs/customizations/${name}/${otrs::release}/", "puppet:///modules/otrs/customizations/${name}/otrs-default/"],
      group   => 'www-data',
      mode    => '2755',
      owner   => 'otrs';
  }
}
