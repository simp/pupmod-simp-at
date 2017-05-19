# This class manages /etc/at.allow and /etc/at.deny and the
# atd service.
#
# @param users
#   An array of additional at users, using the defiend type at::user.
#
class at (
  Array[String] $users = [],
  String        $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  $users.each |String $user| {
    at::user { $user: }
  }
  at::user { 'root': }

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
    subscribe => Simpcat_build['at']
  }

  file { '/etc/at.deny':
    ensure  => 'absent',
    require => Package['at']
  }

  package { 'at': ensure => $package_ensure }

  service { 'atd':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['at']
  }
}
