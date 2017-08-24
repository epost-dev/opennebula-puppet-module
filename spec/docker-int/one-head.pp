class { 'one':
  oned => true,
  node => false,
  sunstone => true,
  one_version => $one_version,
  package_ensure_latest => false,
}
