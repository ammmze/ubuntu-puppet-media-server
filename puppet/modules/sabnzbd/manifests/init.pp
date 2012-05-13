class sabnzbd ($port = "8080") { 

    exec{'add-apt-repository ppa:jcfp/ppa':
        alias   => 'addSabnzbdPPA',
        user    => 'root',
        require => Package['python-software-properties'],
        notify  => Exec['aptUpdate'],
    }

    exec{'apt-get install -y --force-yes sabnzbdplus sabnzbdplus-theme-smpl sabnzbdplus-theme-plush sabnzbdplus-theme-iphone':
        alias   => 'installSabnzbd',
        user    => 'root',
        require => Exec['aptUpdate'],
    }

    # Run as background service
    
    exec{'service sabnzbdplus stop':
        alias   => 'stopSabnzbd',
        user    => 'root',
        require => Exec['installSabnzbd'],
    }
    
    exec{'sed -i "s/USER=.*/USER=mediaserver/" /etc/default/sabnzbdplus':
        user    => 'root',
        require => Exec['stopSabnzbd'],
        notify  => Service['sabnzbdplus'],
    }
    exec{'sed -i "s/HOST=.*/HOST=0\.0\.0\.0/" /etc/default/sabnzbdplus':
        user    => 'root',
        require => Exec['installSabnzbd'],
        notify  => Service['sabnzbdplus'],
    }
    exec{'sed -i "s/PORT=.*/PORT=8080/" /etc/default/sabnzbdplus':
        user    => 'root',
        require => Exec['installSabnzbd'],
        notify  => Service['sabnzbdplus'],
    }

    service{'sabnzbdplus':
        ensure      => running,
        enable      => true,
        hasstatus   => true,
        hasrestart  => true,
        require     => Exec['installSabnzbd'],
    }

}