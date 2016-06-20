class kubernetes_setup {

  package { 'kubernetes-node':
    ensure => installed,
  }

}

