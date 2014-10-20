# puppet-tilde

This is an experimental, alpha Puppet module for setting up an ubuntu server in
the style of [tilde.club](http://tilde.club).

What is in master is generally guaranteed to have been tested casually
on an ec2 micro running Ubuntu 14.04 at [tilde.town](http://tilde.town), but aside from that, there are
no guarantees about the code. YMMV. I'm trying to keep the README up
to date as I change things / add features.

## Installation

 _All of these steps assume you are running as the root user._

 * Install puppet and puppetmaster (they can be on the same
   server). 3.4.x+ is required.
 * `puppet module install hunner-charybdis` *on the puppetmaster*
 * `puppet module install jfryman-nginx`
 * `puppet module install camptocamp-postfix`
 * Set up hiera:
  * add a [hiera.yaml](https://github.com/nathanielksmith/puppet-tilde/tree/master/examples/hiera.yaml) to `/etc/puppet/`
  * `ln -s /etc/puppet/hiera.yaml /etc/hiera.yaml`
  * `mkdir /etc/puppet/hieradata`
  * add and **configure** [common.yaml](https://github.com/nathanielksmith/puppet-tilde/tree/master/examples/common.yaml) to `/etc/puppet/hieradata/`
  * also add and **configure** [common.yaml](https://github.com/nathanielksmith/puppet-tilde/tree/master/examples/common.yaml) to `/etc/puppet/hierdata/node/[yourhostfqdn].yaml`
 * `cd /etc/puppet/modules`
 * `git clone https://github.com/nathanielksmith/puppet-tilde.git tilde`
 * edit [site.pp](https://github.com/nathanielksmith/puppet-tilde/tree/master/examples/site.pp) and save to `/etc/puppet/manifests/site.pp`
 * `puppet agent -t`

## Adding Users

To add users to your tilde server, add them to your common.yaml (or whatever) like so:

    tilde::users:
      vilmibm:
        pubkey: '...'
      cmr:
        pubkey: '...'
      datagrok:
        pubkey: '...'

The module purges any non-system users not managed by puppet; in other words,
to ban a user, simply delete them from the tilde::users hash in common.yaml.

You can also specify `pubkey_type` in the user hash if the user is
fancy and not using `ssh-rsa`. The supported types are whatever is
supported by puppet's
[authorized key type](https://docs.puppetlabs.com/references/latest/type.html#sshauthorizedkey)

Password based logins are not currently supported. You'll have to
manually enable that if you want it.

## /etc/skel

/etc/skel is managed as a set of files in the module. If you'd like to
modify these, make a local branch on the module and edit away. You can
add or remove files from the directory (note, old users will not
retroactively get changes to /etc/skel).

## Nginx

Currently, the module looks for `tilde::hostname` (e.g. _tilde.town_
or _tilde.farm_ or _drawbridge.club_) and sets up an nginx vhost with:


 * a homepage for your tilde server (`/var/www/<your
 domain>/index.html`)
 * user directories (`/~<username>`) which map to /home/<username>/public_html
 * server names $hostname and www.$hostname

## IRC

The module sets up the charybdis IRC server for you.

 * "irc" alias added to users' .bashrc
 * per-user irssi config this will auto-connect to the server and auto-join #<hostname> where hostname is a .-less string substitution of the hostname you specified as `tilde::hostname`.

Your localhost root user will have OPER privileges in IRC, using the password you configured in your `[yourhostfqdn].yaml` or `common.yaml` file.

## Mail

The module sets up postfix for you. Just like tilde.club, it's local
mail only. Alpine and mutt are installed by default.

## MotD

There is basic Message of the Day support. To customize the motd, make
a branch of the checked out puppet module and edit
`templates/motd.erb`. The default template just has a basic cowsay
with a few instructions (and shows your server's hostname).

A `motd` alias that just runs `cat /etc/motd` is also added by the
aliases file in skel.

## NNTP

`inn2` is set up and configured for local access. the client `slrn` is
installed by default. The following groups are installed:

 * local.tilde
 * local.html
 * local.music

Admins can add more groups with `ctlinnd newgroup local.tilde`.

**WARNING** I have barely tested the NNTP stuff with slrn. I would
love for a seasoned usenet user to come to
[tilde.town](http://tilde.town) and help me test things. As far as I
can tell, however, things are working okay.

## Quota support

This module enables 3mb user quotas for all non-system users. You'll
need to add the usrquota option to your / mount with something like
this in your `site.pp`, though, for it to work:

    mount { '/':
        ensure  => 'mounted',
        device  => 'LABEL=cloudimg-rootfs',
        dump    => '0',
        fstype  => 'ext4',
        options => 'defaults,discard,usrquota',
        pass    => '0',
        target  => '/etc/fstab',
      }
    }

If you **do not want disk quotas**, include the tilde class like this
in your `site.pp`:

    class { 'tilde':
        use_quota => false,
    }

or configure common.yaml with

    tilde::use_quota: false

## TODO

 * A "customization" section in this README on how to modify things
   like the server's homepage or /etc/skel.
 * Flags for switching on/off various services from common.yaml (if
   you don't want NTTP, for example).

## Authors

 * Nathaniel Smith <nks@lambdaphil.es>
 * Chris Roddy <cmr@mdc2.org>
 * Jason Levine <jason@queso.com>

## License

This module is licensed under the terms of the GNU Public License version 3
(GPLv3)
