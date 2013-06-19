# Class: puppet-logstash::params
#
#
class puppet-logstash::params {
	
	$version = '1.1.13'
	$home = "/opt/logstash"
	$log_path = '/var/log/logstash'
	$config_path = '/etc/logstash'
	$owner = 'root'
	$group = 'root'
	$enable = true

	#config options
	$syslog = true
	$apache = false
	$apcupsd = false

	case $osfamily {
		"Debian": {
			$syslog_path = '"/var/log/syslog", "/var/log/auth.log"'
			$apache_error_path = '"/var/log/apache2/error.log"'
			$apache_access_path = '"/var/log/apache2/access.log"'
			$apcupsd_path = '"/var/log/apcupsd.events"'
		}
		"RedHat": {
			$syslog_path = '"/var/log/messages"'
			$apache_error_path = '"/var/log/apache2/error_log.log"'
			$apache_access_path = '"/var/log/apache2/access_log.log"'
		}
	}
}