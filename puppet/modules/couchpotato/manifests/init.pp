class couchpotato ($port = "8082") { 

    exec{'git clone https://github.com/RuudBurger/CouchPotato.git /home/mediaserver/.couchpotato':
        alias       => 'downloadCouchPotato',
        require     => Package['git'],
        user        => 'mediaserver',
        onlyif      => 'test ! -d /home/mediaserver/.couchpotato',
    }
    exec{'cp /home/mediaserver/.couchpotato/initd.ubuntu /etc/init.d/couchpotato':
        alias       => 'copyCouchPotatoInit',
        require     => Exec['downloadCouchPotato'],
        user        => 'root',
    }
    exec{'cp /home/mediaserver/.couchpotato/default.ubuntu /etc/default/couchpotato':
        alias       => 'copyCouchPotatoDefault',
        require     => Exec['downloadCouchPotato'],
        user        => 'root',
    }
    exec{'sed -i "s/APP_PATH=.*/APP_PATH=\/home\/mediaserver\/.couchpotato/" /etc/default/couchpotato':
        alias       => 'updateCouchPotatoDefaultAppPath',
        user    => 'root',
        require => Exec['copyCouchPotatoDefault'],
    }
    exec{'sed -i "s/ENABLE_DAEMON=.*/ENABLE_DAEMON=1/" /etc/default/couchpotato':
        alias       => 'updateCouchPotatoDefaultEnableDaemon',
        user    => 'root',
        require => Exec['copyCouchPotatoDefault'],
    }
    exec{'sed -i "s/RUN_AS=.*/RUN_AS=mediaserver/" /etc/default/couchpotato':
        alias       => 'updateCouchPotatoDefaultRunAs',
        user    => 'root',
        require => Exec['copyCouchPotatoDefault'],
    }
    replace { "CouchPotatoPort":
        file            => "/etc/default/couchpotato",
        pattern         => "PORT=.*",
        replacement     => "PORT=$port",
        alias           => 'updateCouchPotatoDefaultPort',
        user            => 'root',
        require         => Exec['copyCouchPotatoDefault'],
    }
    exec{'sed -i "s/WEB_UPDATE=.*/WEB_UPDATE=1/" /etc/default/couchpotato':
        alias       => 'updateCouchPotatoDefaultWebUpdate',
        user    => 'root',
        require => Exec['copyCouchPotatoDefault'],
    }
    exec{'update-rc.d couchpotato defaults':
        alias       => 'updateCouchPotatoInit',
        require     => [ Exec['updateCouchPotatoDefaultAppPath'], Exec['updateCouchPotatoDefaultRunAs'], Exec['updateCouchPotatoDefaultEnableDaemon'], Replace['updateCouchPotatoDefaultPort'], Exec['updateCouchPotatoDefaultWebUpdate'] ],
        user        => 'root',
        notify      => Service['couchpotato'],
    }

    service{'couchpotato':
        ensure      => running,
        enable      => true,
        hasstatus   => false,
        hasrestart  => true,
        require     => [ Package['python-cheetah'], Exec['updateCouchPotatoInit'] ],
    }
    
}