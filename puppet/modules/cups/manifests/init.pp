class cups {
	package {"cups":
		ensure 	=> latest
	}

	service {"cups":
		ensure     => running,
      	enable     => true,
      	hasstatus  => true,
      	hasrestart => true,
      	require    => Package['cups'],
	}

	#exec {"sed -i 's/^Listen localhost/#Listen localhost/' /etc/cups/cupsd.conf":
	#	user 		=> "root",
	#	require 	=> Package['cups'],
	#	notify 		=> Service['cups'],
	#}

	#exec {"sed -i '/Listen localhost/ i Port 631' /etc/cups/cupsd.conf":
	#	user		=> "root",
	#	require		=> Package['cups'],
	#	onlyif 		=> "/usr/bin/test `/bin/grep 'Port 631' '/etc/cups/cupsd.conf' | /bin/grep -v '^#' | /usr/bin/wc -l` -ne 0",
	#	notify 		=> Service['cups'],
	#}

	line {"CupsListen":
		file 	=> "/etc/cups/cupsd.conf",
		line 	=> "Listen localhost",
		ensure 	=> comment,
		require => Package['cups'],
		notify 	=> Service['cups']
	}

	line {"CupsPort631":
		file 	=> "/etc/cups/cupsd.conf",
		line 	=> "Port 631",
		ensure 	=> present,
		require => Package['cups'],
		notify 	=> Service['cups'],
	}

    exec {"cupsctl --remote-admin":
        user    => "root",
        notify  => Service['cups'],
    }

}