type Grub::Menuentry = Struct[
  {
    mountpoint              => Stdlib::UnixPath,
    Optional['iso_path']    => Stdlib::UnixPath,
    Optional['configfile']  => Stdlib::Unixpath,
    Optional['kernel']      => Stdlib::Unixpath,
    Optional['kernel_args'] => Array[String[1]],
    Optional['initrd']      => Stdlib::Unixpath,
  }
]
