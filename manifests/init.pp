# This class manages /etc/at.allow and /etc/at.deny and the atd service.
#
# @param users
#   An array of additional at users, using the defiend type ``at::user``
#
# @param package_ensure
#   The value of ``ensure`` for package resources. The ``atd`` service is only
#   managed when the package is expected to be present (not ``absent`` or ``purged``).
#
class at (
  Array[String] $users = [],
  String        $package_ensure = 'installed'
) {
  $manage_service = !($package_ensure in ['absent', 'purged'])

  $users.each |String $user| {
    at::user { $user: }
  }
  at::user { 'root': }

  concat { '/etc/at.allow':
    order          => 'alpha',
    owner          => 'root',
    group          => 'root',
    mode           => '0600',
    ensure_newline => true,
  }

  file { '/etc/at.deny':
    ensure  => 'absent',
    require => Package['at'],
  }

  package { 'at': ensure => $package_ensure }

  if $manage_service {
    service { 'atd':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Package['at'],
    }
  }
}
