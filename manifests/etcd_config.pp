class kubernetes_setup::etcd_config {

  file_line { 'ETCD_LISTEN_CLIENT_URLS':
    path   => '/etc/etcd/etcd.conf',
    ensure => present,
    match  => '^ETCD_LISTEN_CLIENT_URLS=',
    line   => 'ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"',
  }

  file_line { 'ETCD_LISTEN_PEER_URLS':
    path   => '/etc/etcd/etcd.conf',
    ensure => present,
    match  => '^ETCD_LISTEN_PEER_URLS=',
    line   => 'ETCD_LISTEN_PEER_URLS="http://localhost:2380"',
  }

  file_line { 'ETCD_ADVERTISE_CLIENT_URLS':
    path   => '/etc/etcd/etcd.conf',
    ensure => present,
    match  => '^ETCD_ADVERTISE_CLIENT_URLS=',
    line   => 'ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"',
  }

  file_line { 'KUBE_MASTER':
    path   => '/etc/kubernetes/config',
    ensure => present,
    match  => '^KUBE_MASTER=',
    line   => "KUBE_MASTER='--master=http://$fqdn:8080'",
  }

  file_line { 'KUBE_API_ADDRESS':
    path   => '/etc/kubernetes/apiserver',
    ensure => present,
    match  => '^KUBE_API_ADDRESS=',
    line   => 'KUBE_API_ADDRESS="--address=0.0.0.0"',
  }

  file_line { 'KUBE_ETCD_SERVERS':
    path   => '/etc/kubernetes/apiserver',
    ensure => present,
    match  => '^KUBE_ETCD_SERVERS=',
    line   => 'KUBE_ETCD_SERVERS="--etcd_servers=http://0.0.0.0:2379"',
  }
}
