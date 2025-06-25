# Add the user $name to /etc/at.allow
#
# @param name
#   The user to add to /etc/at.allow
#
define at::user {
  include 'at'

  $_name = strip($name)
  $_safe_name = regsubst($_name,'/','__')

  concat_fragment { "at+${_safe_name}.user":
    target  => '/etc/at.allow',
    content => $_name,
  }
}
