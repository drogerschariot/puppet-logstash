class puppet-logstash(
	$version = $puppet-logstash::params::version,
	$logstash_home = $puppet-logstash::params::home,
	$logstash_log_path = $puppet-logstash::params::log_path,
	$logstash_config_path = $puppet-logstash::params::config_path,
	$owner = $puppet-logstash::params::owner,
	$group = $puppet-logstash::params::group,
	$syslog = $puppet-logstash::params::syslog,
	$syslog_path = $puppet-logstash::params::syslog_path,
	$apache = $puppet-logstash::params::apache,
	$apache_access_path = $puppet-logstash::params::apache_access_path,
	$apache_error_path = $puppet-logstash::params::apache_error_path,
	$apcupsd = $puppet-logstash::params::apcupsd,
	$apcupsd_path = $puppet-logstash::params::apcupsd_path,
	$enable = $puppet-logstash::params::enable,
	) inherits puppet-logstash::params {

	include oracle_java

	# Make Logstash home directory
	file { "$logstash_home":
		ensure 		=> directory,
		owner		=> $owner,
		group 		=> $group,
		mode 		=> 755,
	}

	# Where logstash will store it's logfile.
	file { $logstash_log_path:
		ensure 		=> directory,
		owner		=> $owner,
		group 		=> $group,
		mode 		=> 770,
	}

	# Logstash config directory.
	file { $logstash_config_path:
		ensure 		=> directory,
		owner		=> $owner,
		group 		=> $group,
		mode 		=> 755,
	}

	file {"${logstash_home}/logstash-${version}-flatjar.jar":
		ensure		=> present,
		source		=> "puppet:///modules/puppet-logstash/logstash-${version}-flatjar.jar",
		owner		=> $owner,
		group 		=> $group,
		require		=> File[ "$logstash_home" ],
		mode 		=> 755,
	}

	file { '/etc/init.d/logstash':
		ensure 		=> file,
		content 	=> template("puppet-logstash/logstash-shipper.erb"),
		owner		=> 'root',
		group  		=> 'root',
		mode 		=> 770,
	}

	file { "${logstash_config_path}/shipper.conf":
		ensure		=> present,
		owner		=> $owner,
		group 		=> $group,
		content		=> template("puppet-logstash/shipper.conf.erb"),
		require		=> File[ "$logstash_config_path" ],
		notify		=> Service[ "logstash" ],
		mode 		=> 755,
	}

	service { "logstash":
	    enable 		=> $enable,
		ensure 		=> running,
		subscribe 	=> File[ "${logstash_config_path}/shipper.conf" ],
		require		=> [ File[ "/etc/init.d/logstash" ], Class[ "oracle_java" ], ]
	}


}