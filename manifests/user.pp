# Add the user $name to /etc/at.allow
#
# @param name
#   The user to add to /etc/at.allow
#
define at::user {
  include '::at'

  $_name = regsubst($name,'/','__')

  simpcat_fragment { "at+${_name}.user":
    content =>  "${name}\n"
  }

}
