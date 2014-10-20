class tilde ($use_quota = true, $addtl_packages = [], $users, $hostname) {

  include tilde::packages
  include tilde::mail
  include tilde::skel
	
	class {'tilde::irc':
		hostname => $hostname
	}

  class {'tilde::nntp':
    hostname => $hostname,
  }

  class {'tilde::webserver':
    hostname => $hostname,
  }

  if ($use_quota) {
    include tilde::quota
  }

  group { 'town':
    ensure => present,
  }

  resources { 'user':
    purge => true,
    unless_system_user => true,
  }

  package { $addtl_packages:
    ensure => present,
  }

  file { "/etc/motd":
    ensure => file,
    owner => root,
    group => root,
    mode => '0665',
    content => template("${module_name}/motd.erb")
  }

  create_resources(tilde::user, $users)
}
