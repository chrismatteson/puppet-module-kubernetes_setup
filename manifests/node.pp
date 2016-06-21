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

#  transition { 'stop docker service':
#    resource   => Service['docker'],
#    attributes => { ensure => stopped },
#    prior_to   => File['/var/lib/docker'],
#  }

#  file { '/var/lib/docker':
#    ensure  => 'absent',
#    recurse => true,
#    purge   => true,
#    force   => true,
#    require => Package['docker'],
#    notify  => Service['docker'],
#  }

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

  file_line { 'KUBELET_ADDRESS':
    path    => '/etc/kubernetes/kubelet',
    ensure  => present,
    match   => '^KUBELET_ADDRESS=',
    line    => 'KUBELET_ADDRESS="--address=0.0.0.0"',
    require => Package['kubernetes-node'],
    notify  => Service['kubelet'],
  }

  file_line { 'KUBELET_HOSTNAME':
    path    => '/etc/kubernetes/kubelet',
    ensure  => present,
    match   => '^KUBELET_HOSTNAME=',
    line    => 'KUBELET_HOSTNAME=',
    require => Package['kubernetes-node'],
    notify  => Service['kubelet'],
  }

  File_line <<| tag == 'kubernetes-all' |>>
  File_line <<| tag == 'kubernetes-node' |>>
}
