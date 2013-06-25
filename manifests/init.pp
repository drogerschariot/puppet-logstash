# Class: logstash
#
# Installs logstash with init script and basic config options
#
# Params:
# ---------
#	$version		Logstash version you see on the jar
#	$logstash_home		Logstash root directory
#	$logstash_log_path	Logstash log directory
#	$logstash_config_path	Logstash config path
#	$owner			Owner to run logstash (use root for now)
#	$group 			Group to run logstash (optional)
#	$syslog 		Use common syslog inputs
#	$apache  		Use common apache inputs
#	$apcupsd 		Use common apcupsd inputs
#	$enable 		Enable/Diable logstash 
#	$install_java           Install Java
#	$redis_host 		IP to redis host
#
# Look over the params.pp file to change any defaults.
#
#
# Usage:
# --------
# - include logstash
#
# - class { "logstash":
#	logstash_home 	=> "/usr/local",
#	install_java	=> true,
#	redis 		=> '192.168.100.100',
# }
#
# - class { "logstash":
#	syslog	=> false,
#	apache 	=> true,
# }

class logstash(
	$version = $logstash::params::version,
	$logstash_home = $logstash::params::home,
	$logstash_log_path = $logstash::params::log_path,
	$logstash_config_path = $logstash::params::config_path,
	$owner = $logstash::params::owner,
	$group = $logstash::params::group,
	$syslog = $logstash::params::syslog,
	$syslog_path = $logstash::params::syslog_path,
	$apache = $logstash::params::apache,
	$apache_access_path = $logstash::params::apache_access_path,
	$apache_error_path = $logstash::params::apache_error_path,
	$apcupsd = $logstash::params::apcupsd,
	$apcupsd_path = $logstash::params::apcupsd_path,
	$enable = $logstash::params::enable,
	$install_java = $logstash::params::install_java,
	$redis_host = $logstash::params::redis_host,
	) inherits logstash::params {


	# if true, you will need oracle_java module installed: https://github.com/drogerschariot/puppet-oracle-java
	if $install_java == true{
		include oracle_java
	}

	# Make Logstash root directory
	file { "$logstash_home":
		ensure 		=> directory,
		owner		=> $owner,
		group 		=> $group,
		mode 		=> 755,
	}

	# Logstash log directory.
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

	# Main logstash jar
	file {"${logstash_home}/logstash-${version}-flatjar.jar":
		ensure		=> present,
		source		=> "puppet:///modules/logstash/logstash-${version}-flatjar.jar",
		owner		=> $owner,
		group 		=> $group,
		require		=> File[ "$logstash_home" ],
		mode 		=> 755,
	}

	# Logstash init script
	file { '/etc/init.d/logstash':
		ensure 		=> file,
		content 	=> template("logstash/logstash-shipper.erb"),
		owner		=> 'root',
		group  		=> 'root',
		mode 		=> 770,
	}

	# Logstash config file. You can edit after it's made for custom inputs.
	file { "${logstash_config_path}/shipper.conf":
		ensure		=> present,
		owner		=> $owner,
		group 		=> $group,
		content		=> template("logstash/shipper.conf.erb"),
		require		=> File[ "$logstash_config_path" ],
		notify		=> Service[ "logstash" ],
		mode 		=> 755,
	}

	# Start logstash
	service { "logstash":
	    enable 		=> $enable,
		ensure 		=> running,
		subscribe 	=> File[ "${logstash_config_path}/shipper.conf" ],
		require		=> [ 
			File[ "/etc/init.d/logstash" ], 
			File[ "${logstash_home}/logstash-${version}-flatjar.jar" ],
			File[ "$logstash_log_path" ],
			File[ "${logstash_config_path}/shipper.conf" ],
			$install_java ? {
				true 	=> Class[ "oracle_java" ],
				default	=> File[ "$logstash_config_path" ],
			}
		],
	}
}
