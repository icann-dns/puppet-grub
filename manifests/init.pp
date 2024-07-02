# == Class: grub
#
# @param protect_boot protect boot
# @param protect_advanced protect advanced options
# @param user the username to user
# @param the password to use
class grub (
  Boolean             $protect_boot     = false,
  Boolean             $protect_advanced = false,
  Optional[String]    $user             = undef,
  Optional[String]    $password         = undef,
  Optional[String[1]] $custom_content   = undef,
) {
  if $custom_source and $custom_content {
    fail('you can only provide one of `custom_source` or `custom_content`')
  }
  $_custom_content = @("CUSTOM"\L)
  #!/bin/sh
  exec tail -n +3 $0
  ${custom_content},
  | CUSTOM

  exec {'update_grub':
    command     => '/usr/sbin/update-grub',
    refreshonly => true,
  }
  file {
    default:
      notify  => Exec['update_grub'],
      mode   => '0755',
      ensure  => file;
    '/etc/default/grub':
      mode   => '0644',
      content => template('grub/etc/default/grub.erb');
    '/etc/grub.d/10_linux':
      content => template('grub/etc/grub.d/10_linux.erb'),
    '/etc/grub.d/40_custom':
      content => $_custom_content,
  }
  if $user and $password {
    file { '/etc/grub.d/01_superuser':
      ensure  => file,
      mode    => '0755',
      content => "/bin/cat << EOF\nset superusers=\"${user}\"\npassword_pbkdf2 ${user} ${password}\nexport superusers\nEOF\n",
      notify  => Exec['update_grub'],
    }
  } else {
    file { '/etc/grub.d/01_superuser':
      ensure => absent,
      notify => Exec['update_grub'],
    }
  }
}
