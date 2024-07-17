function grub::get_uuid(
  Stdlib::Unixpath $mountpoint,
) >> Optional[String[1]] {
  $facts['partitions'].values.filter |$parition| {
    $parition['mount'] == $mountpoint
  }.map |$parition| { $parition['uuid'] }[0]
}
