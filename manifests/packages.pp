class otrs::packages {

  package {
    "otrs-${otrs::release}":
      ensure => $otrs::ensure;
  }
}
