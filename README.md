ubuntu-puppet-media-server
==========================

Vagrant project using puppet to setup everything for a mediaserver.

This project uses the ubuntu server 11.10 base box found at [here](http://vagrantbox.es/170/).

In the end, the puppet stuff is all that will get used since this is intended for a full real machine, not a VM.

This project sets up the server with the following:

*   Plex - http://192.168.33.10:32400/manage
*   SabNZBd+ - http://192.168.33.10:8080
*   Sickbeard - http://192.168.33.10:8081
*   CouchPotato - http://192.168.33.10:8082
*   Cups - http://192.168.33.10:631

Note: Port customizing needs work...some are not implemented, and some don't work properly