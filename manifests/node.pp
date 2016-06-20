class kubernetes_setup::node {

  service { 'firewalld':
    enable => false,
    ensure => stopped,
  }

  package { ['docker','kubernetes-node','flannel']:
    ensure => installed,
  }

  service { ['docker','flanneld','kubelet','kube-proxy']:
    enable => true,
    ensure => running,
  }

  transition { 'stop docker service':
    resource   => Service['docker'],
    attributes => { ensure => stopped },
    prior_to   => File['/var/lib/docker'],
  }

  file { '/var/lib/docker':
    ensure  => 'absent',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['docker'],
    notify  => Service['docker'],
  }

  file_line { 'DOCKER_OPTIONS':
    path   => '/etc/sysconfig/docker',
    ensure => present,
    match  => '^OPTIONS=',
    line   => "OPTIONS='--selinux-enabled=false'",
    require => Package['docker'],
    notify => Service['docker'],
  }

  file_line { 'DOCKER_STORAGE_OPTIONS':
    path    => '/etc/sysconfig/docker',
    ensure  => present,
    match   => '^DOCKER_STORAGE_OPTIONS=',
    line    => 'DOCKER_STORAGE_OPTIONS=-s overlay',
    require => Package['docker'],
    notify  => Service['docker'],
  }

  file_line { 'KUBE_MASTER':
    path    => '/etc/kubernetes/config',
    ensure  => present,
    match   => '^KUBE_MASTER=',
    line    => 'KUBE_MASTER="--master=http://kube-master:8080"',
    require => Package['kubernetes-node'],
    notify  => Service['kube-proxy'],
  }

  file_line { 'KUBELET_ADDRESS':
    path    => '/etc/kubernetes/kubelet',
    ensure  => present,
    match   => '^KUBELET_ADDRESS=',
    line    => 'KUBELET_ADDRESS="--address=0.0.0.0"',
    require => Package['kubernetes-node'],
    notify  => Service['kubelet'],
  }

  file_line { 'KUBELET_API_SERVER':
    path    => '/etc/kubernetes/kubelet',
    ensure  => present,
    match   => '^KUBELET_API_SERVER=',
    line    => 'KUBELET_API_SERVER="--api_servers=http://kube-master:8080"',
    require => Package['kubernetes-node'],
    notify  => Service['kubelet'],
  }

  File_line <<| tag == 'kubernetes' |>>
}
