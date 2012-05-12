class mediaserver {
    Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }

    exec{'apt-get update':
        alias   => 'aptUpdate',
        user    => 'root',
    } 

    package{'python-software-properties':
        ensure  => latest,
    }

    package{'git':
        ensure  => latest,
    }

    user {"mediaserver":
        groups          => ["adm", "lpadmin", "sambashare", "admin"],
        ensure          => present,
        managehome      => true,
    }

    # Plex

    class {"plex":
        require     => [ User['mediaserver'] ],
    }

    # SabNZBd+

    class {"sabnzbd":
        require     => [ User['mediaserver'] ],
    }

    # Sickbeard

    class {"sickbeard":
        require     => [ User['mediaserver'] ],
    }

    # CouchPotato

    class {"couchpotato":
        require     => [ User['mediaserver'] ],
    }

}

class {'mediaserver':}
