puppet-logstash
===============

Installs logstash via puppet with init-script, Java, and basic config options.

### Install ###

- Clone to your modules directory.
- Change name from puppet-logstash to logstash.

### Usages ###

The following are examples for what to add to your manifests. Don't forget to look over the params.pp file and change any defaults.

<pre>
<code>
include puppet-logstash
</code>
</pre>
 
<pre>
<code>
class { "puppet-logstash":
  syslog			=> false,
  apache 			=> true,
}
</code>
</pre>

<pre>
<code>
class { "puppet-logstash":
  logstash_home => "/usr/local",
  install_java	=> true,
  redis         => '192.168.100.100',
}
</code>
</pre>

###Contrib
 
 Fork and request!
 

