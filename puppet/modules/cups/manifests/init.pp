class cups ($port = "631") {
	package {"cups":
		ensure 	=> latest,
        require => Exec['aptUpdate'],
	}

	service {"cups":
		ensure     => running,
      	enable     => true,
      	hasstatus  => true,
      	hasrestart => true,
      	require    => Package['cups'],
	}

    delete_lines {"DeletePorts":
        file    => "/etc/cups/cupsd.conf",
        pattern => "Port *"
    }

	line {"CupsListen":
		file 	=> "/etc/cups/cupsd.conf",
		line 	=> "Listen localhost",
		ensure 	=> comment,
		require => Package['cups'],
		notify 	=> Service['cups']
	}

	line {"CupsPort":
		file 	=> "/etc/cups/cupsd.conf",
		line 	=> "Port $port",
		ensure 	=> present,
		require => [ Package['cups'], Delete_lines['DeletePorts'] ],
		notify 	=> Service['cups'],
	}

    exec {"cupsctl --remote-admin":
        user    => "root",
        notify  => Service['cups'],
        require => Package['cups'],
    }

}