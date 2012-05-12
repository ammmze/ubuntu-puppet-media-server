class sickbeard { 

    package {"python-cheetah":
        ensure  => latest
    }

    exec{'git clone https://github.com/midgetspy/Sick-Beard.git /home/mediaserver/.sickbeard':
        alias       => 'downloadSickbeard',
        require     => Package['git'],
        user        => 'mediaserver',
        onlyif      => 'test ! -d /home/mediaserver/.sickbeard',
    }
    exec{'cp /home/mediaserver/.sickbeard/init.ubuntu /etc/init.d/sickbeard':
        alias       => 'copySickbeardInit',
        require     => Exec['downloadSickbeard'],
        user        => 'root',
    }
    exec{'sed -i "s/APP_PATH=.*/APP_PATH=\/home\/mediaserver\/.sickbeard/" /etc/init.d/sickbeard':
        alias       => 'updateSickbeardInitAppPath',
        user    => 'root',
        require => Exec['copySickbeardInit'],
    }
    exec{'sed -i "s/DATA_DIR=.*/DATA_DIR=\/home\/mediaserver\/.sickbeard/" /etc/init.d/sickbeard':
        alias       => 'updateSickbeardInitDataDir',
        user    => 'root',
        require => Exec['copySickbeardInit'],
    }
    exec{'sed -i "s/RUN_AS=.*/RUN_AS=mediaserver/" /etc/init.d/sickbeard':
        alias       => 'updateSickbeardInitRunAs',
        user    => 'root',
        require => Exec['copySickbeardInit'],
    }
    exec{'update-rc.d sickbeard defaults':
        alias       => 'updateSickbeardInit',
        require     => [ Exec['updateSickbeardInitAppPath'], Exec['updateSickbeardInitRunAs'], Exec['updateSickbeardInitDataDir'] ],
        user        => 'root',
    }

    service{'sickbeard':
        ensure      => running,
        enable      => true,
        hasstatus   => false,
        hasrestart  => true,
        require     => [ Package['python-cheetah'], Exec['updateSickbeardInit'] ],
    }
    
}