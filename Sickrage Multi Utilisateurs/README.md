Bonjour à tous,

Il y a quelques temps, je suis tombé sur sickrage, via le tutoriel créé sur ce forum par [b]adaur[/b]. Sickrage est presque parfait, la seul chose qui lui manque (à mon avis), est le fait qu'il ne sois pas multi-utilisateurs, j'ai donc trouvé une solution pour pouvoir le faire, et je viens donc vous la partager.

Afin de ne pas refaire la même présentation de sickrage que [b]adaur[/b], je vous renvoie plutôt sur son [url=http://mondedie.fr/d/6429]sujet[/url]. Je mets également quelques citations de lui pour reprendre l'installation de base. Sur ce tuto je me base sur sickrage, mais ceci fonctionne parfaitement sur la version originale de sickbeard.


On commence.


[color=#ff0000][b][u]1. Installation des prérequis :[/u][/b][/color]
On commence par installer python, son module cheetah et git. Si vous ne les avez pas, ça donne ça:
[code]$ apt-get install git-core python python-cheetah[/code]

[color=#ff0000][b][u]2. Installation de sickbeard:[/u][/b][/color]
On télécharge et installe sickbeard:
[code]$ git clone https://github.com/SickRage/SickRage /opt/sickrage
cd /opt/sickrage[/code]

Personnellement je le mets dans opt, mais à vous de choisir.
On lui donne les droits de l'utilisateur principal (pour moi c'est xataz, c'est moi l'admin ^^) :
[code]$ chown -R xataz:xataz /opt/sickrage[/code]

De cette manière seul vous pourrez mettre à jour sickbeard, les autres utilisateurs aurons par contre des messages dans la logs, mais rien de méchants.

Jusque là pas de changement par rapport au tutoriel de [b]adaur[/b], mais c'est la que ça change.


[color=#ff0000][b][u]3. Le multi-utilisateurs:[/u][/b][/color]
Celui ci resemble au multi-utilisateurs de rtorrent/rutorrent, un fichier d'execution par utilisateur, un fichier de configuration par utilisateur, et une authentification nginx (plus proxypass, rien de compliqué).
Pour pouvoir faire du multi user, j'ai modifié le script init.ubuntu :

Donc on crée notre fichier pour notre utilisateur :
[code]$ nano /etc/init.d/sickrage_xataz[/code]
et on copie ceci :
[code]
#!/bin/bash
#
### BEGIN INIT INFO
# Provides:          sickrage_xataz
# Required-Start:    $local_fs $network $remote_fs
# Required-Stop:     $local_fs $network $remote_fs
# Should-Start:      $NetworkManager
# Should-Stop:       $NetworkManager
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Daemon pour sickbeard
# Description:       Permets le lancement de sickbeard en multi-utilisateurs
### END INIT INFO

# A modifier
SR_USER=xataz
SR_INSTALL=/opt/sickrage



# Pas touche
NAME=sickbeard_$SR_USER
DESC="SickBeard pour $SR_USER"
SR_HOME=$SR_INSTALL
SR_DATA=$SR_HOME/data/$SR_USER
SR_OPTS=--config=$SR_DATA/config.ini
SR_PIDFILE=$SR_DATA/sickrage.pid


# default
RUN_AS=${SR_USER-sickrage}
APP_PATH=${SR_HOME-/opt/sickrage}
DATA_DIR=${SR_DATA-/opt/sickrage}
PID_FILE=${SR_PIDFILE-/var/run/sickrage/sickrage.pid}
DAEMON=${PYTHON_BIN-/usr/bin/python}
EXTRA_DAEMON_OPTS=${SR_OPTS-}
EXTRA_SSD_OPTS=${SSD_OPTS-}

PID_PATH=`dirname $PID_FILE`
DAEMON_OPTS=" SickBeard.py -q --daemon --nolaunch --pidfile=${PID_FILE} --datadir=${DATA_DIR} ${EXTRA_DAEMON_OPTS}"

test -x $DAEMON || exit 0
set -e

if [ ! -d $PID_PATH ]; then
    mkdir -p $PID_PATH
    chown $RUN_AS $PID_PATH
fi

if [ ! -d $DATA_DIR ]; then
    mkdir -p $DATA_DIR
    chown $RUN_AS $DATA_DIR
fi

if [ -e $PID_FILE ]; then
    PID=`cat $PID_FILE`
    if ! kill -0 $PID > /dev/null 2>&1; then
        echo "Removing stale $PID_FILE"
        rm $PID_FILE
    fi
fi

d_start() {
    echo "Starting $DESC"
    start-stop-daemon -d $APP_PATH -c $RUN_AS $EXTRA_SSD_OPTS --start --pidfile $PID_FILE --exec $DAEMON -- $DAEMON_OPTS
}

d_stop() {
    echo "Stopping $DESC"
    start-stop-daemon --stop --pidfile $PID_FILE --retry 15
}

d_status() {
        if [ -e $PID_FILE ]
        then
                if [ $(cat $PID_FILE) -eq $(ps -ef | grep $PID_FILE | grep -v grep | awk '{print $2}') ]
                then
                        echo "$DESC is running"
                else
                        echo "$DESC is stopping"
                fi
        else
                echo "$DESC is stopping"
        fi

}

case "$1" in
    start)
        d_start
        ;;
    stop)
        d_stop
        ;;

    restart|force-reload)
        d_stop
        sleep 2
        d_start
        ;;
    status)
        d_status
        ;;
    *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|status|force-reload}" >&2
        exit 1
        ;;
esac

exit 0
[/code]

Les seuls choses à modifier sont :
[code]
# Provides:          sickrage_xataz
SR_USER=xataz
SR_INSTALL=/opt/sickrage
[/code]

SR_USER est le nom de votre utilisateur, et SR_INSTALL est le répertoire d'installation, si vous avez mis un répertoire différent au mien.


Un petit chmod pour le rendre exécutable :
[code]$ chmod +x /etc/init.d/sickrage_xataz[/code]

Ce qu'on va faire, c'est lancer ce script, cela permettra de créé les fichiers pour votre utilisateur, et on l'arrête aussi tôt :
[code]$ /etc/init.d/sickrage_xataz start && /etc/init.d/sickrage_xataz stop[/code]

Voila les fichiers de configuration ce sont créé tous seul dans /opt/sickrage/data/xataz (si vous avez le même répertoire d'installation que moi).
On ouvre le fichier config.ini pour apporté quelques modification :
[code]$ nano /opt/sickrage/data/xataz/config.ini [/code]
et on modifie ceci :
[code]
web_root = "/sickrage" # Pour un accès par http://monip/sickrage
web_port = 20001 # personnellement j'ai commencé à 20001, ne laisser pas 8081, car c'est le port par défault de sickbeard, donc a chaque nouvelle utilisateurs, il recréra le fichier avec ce port, et ceci bloquera le démarrage de l'application
torrent_dir = /home/xataz/downloads/.watch/ # le répertoire watch de rtorrent, la ou sickbeard téléchargera les .torrents
[/code]
Et c'est tous.


Maintenant on ajoute le démarrage automatique de l'application au démarrage du serveur :
[code]$ update-rc.d sickrage_xataz defaults[/code]


Et voila, l'étape 3 est à faire pour chaque utilisateurs.



[color=#ff0000][b][u]4. Configuration de nginx :[/u][/b][/color]
Afin de pouvoir y accéder directement via l'url (https://monip/sickrage), il va falloir modifier la configuration de nginx, rien de bien méchants.
Nous allons utilisé l'authentification de nginx, plûtot que celle de sickrage.

Pour ce faire rien de bien compliqué, il suffit de modifier le fichier /etc/nginx/sites-enabled/rutorrent.conf :
[code]$ nano /etc/nginx/sites-enabled/rutorrent.conf[/code]
Et d'ajouter après :
[code]
location ^~ /rutorrent {
	root /var/www;
	include /etc/nginx/conf.d/php.conf;
	include /etc/nginx/conf.d/cache.conf;

	location ~ /\.svn {
		deny all;
	}

	location ~ /\.ht {
		deny all;
	}
    }
[/code]
Ceci :
[code]
location /sickrage {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $remote_addr;
                proxy_set_header Host $host;
                proxy_redirect off;
                if ($remote_user = "xataz") {
                        proxy_pass http://127.0.0.1:20001;
                        break;
                }
                if ($remote_user = "test") {
                        proxy_pass http://127.0.0.1:20002;
                        break;
                }
        }

[/code]

Pour vous expliquer rapidement, si l'utilisateur tape dans son navigateur http://monip/sickrage, Nginx vérifie l'utilisateur connecté, en fonction de l'utilisateur, il "redirige" vers le bon port.
Si mon utilisateur est xataz, il redirige vers le port 20001, précédemment configurer. Si l'utilisateur est test, vers le port 20002, etc ....

Puis on relance nginx :
[code]
$ /etc/init.d/nginx restart
[/code]

Donc voila pour ce tutoriel.
Je rappel que la configuration de base (partie 1 et 2) sont totalement tiré du tutoriel de [b]adaur[/b], pour le reste c'est bien de moi. 


@+

EDIT : Modification du daemon pour une compatibilité avec debian 8.
EDIT 2 : Modification de la configuration nginx + config sickrage