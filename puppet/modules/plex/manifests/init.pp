class plex ($port = "32400") { 

    exec{'echo "deb http://www.plexapp.com/repo lucid main" > /etc/apt/sources.list.d/plex.list':
        alias   => 'addPlexToSources',
        user    => 'root',
        notify  => Exec['aptUpdate'],
    }

    exec{'apt-get install -y --force-yes plexmediaserver':
        alias   => 'installPlex',
        user    => 'root',
        require => Exec['aptUpdate'],
    }

    #package{'plexmediaserver':
    #    ensure   => latest,
    #    require => Exec['aptUpdateForPlex'],
    #}
    
}