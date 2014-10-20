class tilde::irc ($hostname, $rootoperpass) inherits charybdis {

  # substituted in in the irssi default config file for users
  $channel = regsubst($tilde::hostname, '\.', '')

  class { 'charybdis::serverinfo':
    server_name => "${hostname}",
    server_id => '99Z',
    server_description => 'tilde charybdis server',
    network_name => 'tilde.club',
    network_description => 'your very own network!',
    hub => true,
    ssl_cert => '/etc/charybdis/test.cert',
    ssl_private_key => '/etc/charybdis/test.key',
    ssl_dh_params => '/etc/charybdis/dh.pem',
    ssld_count => '1',
    max_clients => '1024',
    restartpass => "notused",
    diepass => "notused"
  }
  class { 'charybdis::admin':
    adminname => 'Tilde Node Administrator',
    description => 'node IRC administrator',
    email => 'admin@node'
  }
  charybdis::listen { 'default':
    port => '6665 .. 6669',
    sslport => '6697'
  }
  charybdis::operator { 'root':
    users => [ 'root@127.0.0.0/8' ],
    privset => 'admin',
    password => "${rootoperpass}",
    snomask => '+Zbfkrsuy',
    flags => [ '~encrypted' ]
  }
  class { 'charybdis::cluster':
    clustername => '*.tilde.club'
  }

  # set up our auth sections
  charybdis::auth { 'localhostusers':
    order => '2',
    users => '*@127.0.0.0/8',
    authclass => 'users'
  }

  include charybdis::log
  include charybdis::default::alias
  include charybdis::default::channel
  include charybdis::default::general
  include charybdis::default::modules
  include charybdis::default::privset
  include charybdis::default::serverhide

  # set up our user classes
  charybdis::class { 'users':
    ping_time => '2 minutes',
    number_per_ident => '10',
    number_per_ip => '1024',
    number_per_ip_global => '1024',
    cidr_ipv4_bitlen => '24',
    cidr_ipv6_bitlen => '64',
    number_per_cidr => '1024',
    max_number => '3000',
    sendq => '400 kbytes'
  }
  charybdis::class { 'opers':
    ping_time => '5 minutes',
    number_per_ip => '256',
    max_number => '1024',
    sendq => '1 megabyte'
  }
  charybdis::class { 'server':
    ping_time => '5 minutes',
    connectfreq => '5 minutes',
    max_number => '24',
    sendq => '4 megabytes'
  }

  charybdis::exempt { 'default': }
  charybdis::shared { 'default': }

}
