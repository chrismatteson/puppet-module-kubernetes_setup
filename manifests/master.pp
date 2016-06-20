class kubernetes_setup::master {

  package { ['etcd','kubernetes-master','flannel']:
    ensure => installed,
  }

  class { 'kubernetes_setup::etcd_config':
    require => Package['etcd'],
    notify  => Service['etcd'],
  }

  service { ['etcd','flanneld','kube-apiserver','kube-controller-manager','kube-scheduler']:
    enable => true,
    ensure => running,
  }

  file { '/tmp/flannel-config.json':
    ensure => file,
    source => 'puppet:///modules/demomodule/flannel-config.json',
    require => Package['flannel'],
  }

  exec { '/bin/etcdctl set coreos.com/network/config < /tmp/flannel-config.json':
    refreshonly => true,
    subscribe   => [File['/tmp/flannel-config.json'],File_line['FLANNEL_ETCD_KEY'],File_line['FLANNEL_ETCD']],
    notify      => Service['flanneld'],
  }

  @@file_line { 'FLANNEL_ETCD_KEY':
    path   => '/etc/sysconfig/flanneld',
    ensure => present,
    match  => '^FLANNEL_ETCD_KEY=',
    line   => "FLANNEL_ETCD_KEY='/coreos.com/network'",
    tag    => 'kubernetes',
  }

  @@file_line { 'FLANNEL_ETCD':
    path   => '/etc/sysconfig/flanneld',
    ensure => present,
    match  => '^FLANNEL_ETCD=',
    line   => "FLANNEL_ETCD='http://$::fqdn:2379'",
    tag    => 'kubernetes',
  }

  File_line <<| tag == 'kubernetes' |>>
}
