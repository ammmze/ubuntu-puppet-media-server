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
        port    => "32400",
    }

    # SabNZBd+

    class {"sabnzbd":
        require     => [ User['mediaserver'] ],
        port    => "8080",
    }

    # Sickbeard

    class {"sickbeard":
        require     => [ User['mediaserver'] ],
        port    => "8081",
    }

    # CouchPotato

    class {"couchpotato":
        require     => [ User['mediaserver'] ],
        port    => "8082",
    }

    # CUPS

    class {"cups":
        port    => "631",
    }

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

define delete_lines($file, $pattern) {
    exec { "/bin/sed -i -r -e '/$pattern/d' $file":
        onlyif => "/bin/grep -E '$pattern' '$file'",
    }
}

define replace($file, $pattern, $replacement, $user) {
    $pattern_no_slashes = $pattern
    $replacement_no_slashes = $replacement
    #$pattern_no_slashes = slash_escape($pattern)
    #$replacement_no_slashes = slash_escape($replacement)

    exec { "/usr/bin/perl -pi -e 's/$pattern_no_slashes/$replacement_no_slashes/' '$file'":
        onlyif => "/usr/bin/perl -ne 'BEGIN { \$ret = 1; } \$ret = 0 if /$pattern_no_slashes/ && ! /$replacement_no_slashes/ ; END { exit \$ret; }' '$file'",
        user    => $user,
    }
}

define prepend_if_no_such_line($file, $line, $refreshonly = 'false') {
    exec { "/usr/bin/perl -p0i -e 's/^/$line\n/;' '$file'":
        unless      => "/bin/grep -Fxqe '$line' '$file'",
        path        => "/bin",
        refreshonly => $refreshonly,
    }
}