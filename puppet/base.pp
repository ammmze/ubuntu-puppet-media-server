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

    class {"cups":}

}

class {'mediaserver':}

define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
              onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }

            # Use this resource instead if your platform's grep doesn't support -vFx;
            # note that this command has been known to have problems with lines containing quotes.
            # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
            # }
        }
        uncomment: {
            exec { "/bin/sed -i -e'/${line}/s/#\\+//' '${file}'" :
                onlyif => "/bin/grep '${line}' '${file}' | /bin/grep '^#' | /usr/bin/wc -l"
            }
        }
        comment: {
            exec { "/bin/sed -i -e'/${line}/s/\\(.\\+\\)$/#\\1/' '${file}'" :
                onlyif => "/usr/bin/test `/bin/grep '${line}' '${file}' | /bin/grep -v '^#' | /usr/bin/wc -l` -ne 0"
            }
        }
    }
}
