class kubernetes_setup::master {

  service { 'firewalld':
    enable => false,
    ensure => stopped,
  }

  package { ['etcd','kubernetes-master','flannel']:
    ensure => installed,
  }

  file_line { 'ETCD_LISTEN_CLIENT_URLS':
    path    => '/etc/etcd/etcd.conf',
    ensure  => present,
    match   => '^ETCD_LISTEN_CLIENT_URLS=',
    line    => 'ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"',
    require => Package['etcd'],
    notify  => Service['etcd'],
  }

  file_line { 'ETCD_LISTEN_PEER_URLS':
    path    => '/etc/etcd/etcd.conf',
    ensure  => present,
    match   => '^ETCD_LISTEN_PEER_URLS=',
    line    => 'ETCD_LISTEN_PEER_URLS="http://localhost:2380"',
    require => Package['etcd'],
    notify  => Service['etcd'],
  }

  file_line { 'ETCD_ADVERTISE_CLIENT_URLS':
    path    => '/etc/etcd/etcd.conf',
    ensure  => present,
    match   => '^ETCD_ADVERTISE_CLIENT_URLS=',
    line    => 'ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"',
    require => Package['etcd'],
    notify  => Service['etcd'],
  }

  @@file_line { 'KUBE_MASTER':
    path    => '/etc/kubernetes/config',
    ensure  => present,
    match   => '^KUBE_MASTER=',
    line    => "KUBE_MASTER='--master=http://$fqdn:8080'",
    tag     => 'kubernetes-node',
  }

  file_line { 'KUBE_API_ADDRESS':
    path   => '/etc/kubernetes/apiserver',
    ensure => present,
    match  => '^KUBE_API_ADDRESS=',
    line   => 'KUBE_API_ADDRESS="--address=0.0.0.0"',
    require => Package['kubernetes-master'],
    notify  => Service['kube-apiserver'],
  }

  file_line { 'KUBE_ETCD_SERVERS':
    path   => '/etc/kubernetes/apiserver',
    ensure => present,
    match  => '^KUBE_ETCD_SERVERS=',
    line   => "KUBE_ETCD_SERVERS='--etcd_servers=http://$fqdn:2379'",
    require => Package['kubernetes-master'],
    notify  => Service['kube-apiserver'],
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
    tag    => 'kubernetes-all',
  }

  @@file_line { 'FLANNEL_ETCD':
    path   => '/etc/sysconfig/flanneld',
    ensure => present,
    match  => '^FLANNEL_ETCD=',
    line   => "FLANNEL_ETCD='http://$::fqdn:2379'",
    tag    => 'kubernetes-all',
  }

  @@file_line { 'KUBELET_API_SERVER':
    path    => '/etc/kubernetes/kubelet',
    ensure  => present,
    match   => '^KUBELET_API_SERVER=',
    line    => "KUBELET_API_SERVER='--api_servers=http://$fqdn:8080'",
    require => Package['kubernetes-node'],
    notify  => Service['kubelet'],
    tag     => 'kubernetes-node',
  }

  File_line <<| tag == 'kubernetes-all' |>>
}
