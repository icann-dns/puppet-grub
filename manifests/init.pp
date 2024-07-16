# == Class: grub
#
# @param protect_boot protect boot
# @param protect_advanced protect advanced options
# @param user the username to user
# @param password the password to use
# @param menuentries custom text to add to the menu
class grub (
  Boolean                          $protect_boot     = false,
  Boolean                          $protect_advanced = false,
  Optional[String[1]]              $user             = undef,
  Optional[String[1]]              $password         = undef,
  Hash[String[1], Grub::Menuentry] $menuentries      = {},
) {
  $custom_menus = grub::parse_menuentries($menuentries)
  $_custom_content = @("CUSTOM"/$)
    #!/bin/sh
    exec tail -n +3 \$0
    ${custom_menus}
    | CUSTOM
  $super_content = @("CONTENT")
    /bin/cat << EOF
    set superusers="${user}"
    password_pbkdf2 ${user} ${password}
    export superusers
    EOF
    | CONTENT

  exec { 'update_grub':
    command     => '/usr/sbin/update-grub',
    refreshonly => true,
  }
  file {
    default:
      ensure => file,
      mode   => '0755',
      notify => Exec['update_grub'];
    '/etc/default/grub':
      mode    => '0644',
      content => template('grub/etc/default/grub.erb');
    '/etc/grub.d/01_superuser':
      ensure  => stdlib::ensure($user and $password, 'file'),
      content => $super_content;
    '/etc/grub.d/10_linux':
      content => template('grub/etc/grub.d/10_linux.erb');
    '/etc/grub.d/40_custom':
      content => $_custom_content;
  }
}
