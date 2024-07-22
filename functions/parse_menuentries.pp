# @summary Generate grub menuentries for each disk and menue set passed icannlib
#   The mountpoints are used to set the root fs
# @param menuentries a hash of menuitems
function grub::parse_menuentries (
  Hash[String[1], Grub::Menuentry] $menuentries,
) >> Optional[String[1]] {
  $menuentries.map |$title, $config| {
    $configfile = ('configfile' in $config).bool2str(
      "configfile ${config['configfile']}", ''
    )
    $args = $config.get('kernel_args', []).join(' ')
    $kernel = ('kernel' in $config).bool2str(
      "linux ${config['kernel']} ${args}", ''
    )
    $initrd = ('initrd' in $config).bool2str(
      "initrd ${config['initrd']}", ''
    )
    $loop_lines = 'iso_path' in $config ? {
      true => [
        "set iso_path=${config['iso_path']}",
        'loopback loop "$iso_path"',
        'root=(loop)',
      ],
      false => [],
    }

    $extra_lines = ($loop_lines + [$configfile, $kernel, $initrd]).filter |$x| {
      !$x.strip.empty
    }.join("\n  ")

    $uuid = grub::get_uuid($config['mountpoint'])
    $uuid ? {
      Undef   => '',
      default => @("MENU"/$)
        menuentry '${title}' {
          rmmod tpm
          search --no-floppy --fs-uuid --set=root ${uuid}
          ${extra_lines}
        }
        | MENU
    }
  }.join("\n")
}
