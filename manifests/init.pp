# This class manages /etc/at.allow and /etc/at.deny and the
# atd service.
#
# @param users
#   An array of additional at users, using the defiend type at::user.
#
class at (
  Array[String] $users = []
) {

  $users.each |String $user| {
    ::at::user { $user: }
  }
  ::at::user { 'root': }

  simpcat_build { 'at':
    order            => ['*.user'],
    clean_whitespace => 'leading',
    target           => '/etc/at.allow'
  }

  file { '/etc/at.allow':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    subscribe => Simpcat_build['at'],
    audit     => 'content'
}

  file { '/etc/at.deny':
    ensure => 'absent'
  }

  package { 'at': ensure => latest }

  service { 'atd':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['at']
  }
}
