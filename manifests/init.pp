# == Class: grub
#
# @param protect_boot protect boot
# @param protect_advanced protect advanced options
# @param enable_apparmor if true enable app armor
# @param timeout how long to show the grub menu
# @param default the default boot entry
# @param user the username to user
# @param password the password to use
# @param extra_mods a list of additional modules to install
# @param menuentries custom text to add to the menu
class grub (
  Boolean                            $protect_boot     = false,
  Boolean                            $protect_advanced = false,
  Boolean                            $enable_apparmor  = true,
  Integer[1,60]                      $timeout          = 3,
  Variant[Enum['saved'], Integer[0]] $default          = 0,
  Optional[String[1]]                $user             = undef,
  Optional[String[1]]                $password         = undef,
  Array[String[1]]                   $extra_mods       = [],
  Hash[String[1], Grub::Menuentry]   $menuentries      = {},
) {
  $custom_menus = grub::parse_menuentries($menuentries)
  $_custom_content = @("CUSTOM"/$)
    #!/bin/sh
    exec tail -n +3 \$0
    ${custom_menus}
    | CUSTOM
  $super_content = @("CONTENT"/$)
    #!/bin/sh
    exec tail -n +3 \$0
    set superusers="${user}"
    password_pbkdf2 ${user} ${password}
    export superusers
    | CONTENT
  $apparmor = $enable_apparmor.bool2str('1','0')

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
