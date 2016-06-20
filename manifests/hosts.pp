class kubernetes::hosts {

  @@host { $hostname:
    ensure     => present,
    host_alias => $fqdn,
    ip         => $ipaddress,
  }

  Host <<| |>>
}
