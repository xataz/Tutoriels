# Monitoring avec Monit

## Qu'est ce que monit :
Monit est un outils gratuit qui permets de surveiller l'état d'un serveur, comme les services ou les espaces disques. Il permets également de planifier des actions en cas de plantage d'un de ces services, comme le relancé, ou alors pour un espaces disques pleins et exécuté un script qui fera le tri.


## Le tutoriel :
Ce tutoriel ne sera qu'une ébauche, monit étant réellement puissant, je ne montrerai ici qu'une configuration basique.

Les exemples donnés sont valable pour debian 8.

Voici le résultat du tutoriel (avec des erreurs voulu) :
![](https://images.mondedie.fr/images/monitdebia.jpg)


## Installer monit :
Sous Debian, il est facile d'installer monit, puisqu'il est disponible dans les dépots :
```shell
$ apt-get install monit
```

## Configuration global de monit :
Tout ce passe dans le répertoire /etc/monit.
Nous allons commencer par la configuration général de monit, nous allons donc éditer le fichier monitrc, mais avant on sauvegarde la configuration par defaults :
```shell
$ cp /etc/monit/monitrc{,.bak}
```
et on vide pour faire une configuration de zero, que j'expliquerai bien évidemment :
```shell
echo "" > /etc/monit/monitrc
```

Et mon écrit ceci dedans :
```shell
set daemon 120
        with start delay 240


set httpd port 2812
        allow monit:monit

set mailserver smtp.gmail.com port 587
        username "mail@gmail.com" password "password"
        using tlsv12

set alert mail@gmail.com

set logfile /var/log/monit.log
set pidfile /var/run/monit.pid

set eventqueue
        basedir /var/lib/monit/events
        slots 100

set mail-format {
        from: monit@$HOST
        subject: monit alert --  $EVENT $SERVICE
}

include /etc/monit/conf.d/*
```

Pour expliqué rapidement :
* **set daemon** => Définie la fréquence de vérification des checks, ici toutes les 120 secondes
* **set start delay** => Permets de mettre une tempo au lancement de l'appli, ici le 1er check ce fera au bout de 240 sec.
* **set httpd port** => Choix du port d'écoute, ceci permets l'accès au webUI.
* **allow monit:monit** => Création de l'utilisateur monit, avec mot de passe monit pour y accéder.
* **set mailserver** => Configuration du serveur de mail (ici google), pour envoyé les alertes
* **set alert** => Configuration du mail qui reçois les notifications
* **set logfile** => Emplacement des logs de monit
* **set pidfile** => Emplacement du fichier pid
* **set eventqueue** => Permets en cas de pertes de connexions de garder en memoire les evenements afin de les notifier par la suite
* **set mail-format** => Format du mail envoyés en cas d'alerte
* **include**=> Permets d'organiser la configuration, en fait il va lire tous les fichiers présents dans le répertoires indiqués.


## Configuration du monitoring systèmes :
Dans cette partie, nous allons voir comment surveiller le système, comme le CPU, ou la ram, et même la température.
On crée donc un fichier dans le conf.d :
```shell
$ vim /etc/monit/conf.d/system
```
et on écrit ceci :
```shell
check system $HOST
        if loadavg (1min) > 3 then alert
        if loadavg (5min) > 2 then alert
        if loadavg (15min) > 1 then alert
        if memory usage > 80% for 4 cycles then alert
        if swap usage > 20% for 4 cycles then alert
        if cpu usage (user) > 80% for 2 cycles then alert
        if cpu usage (system) > 20% for 2 cycles then alert
        if cpu usage (wait) > 80% for 2 cycles then alert
```
La syntax est vraiment simple, et très littéraire.  

Comme on peut le voir, monit utilise un système de cycle, 1 cycle représente le temps (set daemon), on peux donc attendre qu'un service sois indisponible pendant plus d'un cycle avant de créé une alert.  

La on ne check que le CPU et la memoire, mais je vous ai parler également de la temperature, malheureusement il n'y a pas de solution native pour ceci, nous allons donc utilisé un script. Monit prends donc la valeur de retour comme valeur.  
Personnellement pour la temperature, j'utilise lm-sensors.
```shell
$ apt-get install lm-sensors
```
Vérifier que cela fonctionne en tapant :
```shell
$ sensors -u
```

On va donc créé un script pour récuperer les valeurs possibles ;
```shell
$ mkdir /etc/monit/script
$ vim /etc/monit/script/temp
```
```shell
#!/bin/bash

CPU0=$(sensors -u | grep "temp2_input" | awk '{printf "%d",$2}')
exit $CPU0
```

A adapter en fonction de vos capteurs.

on oublie pas de le rendre executable :
```shell
chmod u+x /etc/monit/script/temp
```

On repasse donc à la configuration du fichier system et on ajoute ceci :
```shell
check program CPU0 with path "/etc/monit/script/temp"
    group temperature
    if status > 75 then alert
```

Il est bien évidemment possible d'améliorer ce script, comme mesurer plusieurs sondes.

## Configuration du monitoring des services :
Je ne vais pas vous expliquer comment tous monitorer, mais je vais vous montrer quelques configurations, comme ssh, rtorrent et nginx.  
Pour les services nous utilisons des fichiers pid, c'est fichier sont situés généralement dans /var/run, chaque fichier contient l'id d'un processus.

Nous créons un fichier /etc/monit/conf.d/services.
Nous allons commencer par ssh :
```shell
check process sshd with pidfile /var/run/sshd.pid
        group login
        start program = "/bin/systemctl start sshd.service"
        stop program = "/bin/systemctl stop sshd.service"
        if failed host 127.0.0.1 port 22 protocol ssh for 2 cycles then restart
        if 5 restarts within 5 cycles then unmonitor
```

Comme je disais la syntaxe est vraiment littéraire, mais pour résumer :  
Si la connexion échoue on relance le service, et si il y a 5 relances d'affilé, on arrête de surveiller le service.  

Le nom du process (ici sshd) et le nom du groupe est choisi arbitrairement, c'est surtout pour vous organisé, a chacun sa méthode.  
Par contre lors de l’exécution d'un script ou d'un programme, il faut toujours mettre le chemin absolu, sinon ceci ne fonctionnera pas.

On passe maintenant a nginx + php-fpm :
```shell
check process nginx with pidfile /var/run/nginx.pid
        group http
        start program = "/bin/systemctl start nginx.service"
        stop program  = "/bin/systemctl stop nginx.service"
        if cpu > 70% for 2 cycles then alert
        if cpu > 90% for 2 cycles then restart
        if failed host 127.0.0.1 port 80 protocol http for 2 cycles then restart
        if 5 restarts within 5 cycles then unmonitor

check process php with pidfile /var/run/php5-fpm.pid
        group http
        start program = "/bin/systemctl start php5-fpm.service"
        stop program  = "/bin/systemctl stop php5-fpm.service"
        if 5 restarts within 5 cycles then unmonitor
```

Pour finir avec les services, nous allons passer à rtorrent, mais le problème de rtorrent, c'est qu'il n'y a pas de fichiers pid pour rtorrent, il y a bien un pid pour le screen, mais il arrive que rtorrent plante mais que screen tourne toujours. Nous allons donc devoir modifier le script d'exécution.
Ce fichier est placé dans /etc/init.d/username-rtorrent et on ajoute dans la fonction rt_start après le su :
```shell
PID=$(cut -d+ -f2 /home/${user}/.session/rtorrent.lock)
echo $PID > /var/run/${user}-rtorrent.pid
```

Ceci créera le fichier pid au lancement de rtorrent. Ce qui permets maintenant de le monitorer :
```shell
check process username-rtorrent with pidfile /var/run/username-rtorrent.pid
        group rtorrent
        start program = "/etc/init.d/username-rtorrent start"
        stop program = "/etc/init.d/username-rtorrent stop"
        if cpu > 50% for 5 cycles then alert
        if cpu > 90% for 5 cycles then restart
        if 5 restarts within 5 cycles then unmonitor
```

Bien évidemment à ajouté pour chaque utilisateurs.  

Je m'arrête la pour les services, même si il y en a pleins d'autre que l'on peut monitorer, mais après c'est spécifique.

## Configuration du monitoring des filesystems :
Pour les filesystems, c'est encore plus simple :
nous créerons un fichier /etc/monit/conf.d/fs
```shell
check filesystem home with path /home
        if space usage > 70% then alert

check filesystem var with path /var
        if space usage > 80% then alert
        if space usage > 90% then exec "/usr/bin/find /var/log -type f -mtime +30 -exec rm -rf {} \;"
```

J'ai ajouté une petite commande qui permets de faire du tri dans les logs, ceci est un exemple, on peu par exemple exécuter un script.


Ne pas oublié de faire un reload de monit à chaque modification :
```shell
$ /etc/init.d/monit reload
```


## Conclusion :
Comme je le disais, ceci est une configuration basique, je n'ai pas tous abordé. Mais si vous voulez aller plus loin, je ne peux que vous conseillez d'aller voir les [exemples](https://mmonit.com/wiki/Monit/ConfigurationExamples) et la [Documentation officiel](https://www.google.fr/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=0CCoQFjABahUKEwjyurHdourGAhXDbRQKHRgIA_w&url=https%3A%2F%2Fmmonit.com%2Fmonit%2Fdocumentation%2Fmonit.html&ei=2TStVbLqIMPbUZiQjOAP&usg=AFQjCNE_veyF_N9NRKE317I8Eu1Tvthyqw&sig2=8TXMBNl9TprX3Wh1pS5PHw&bvm=bv.98197061,d.d24&cad=rja) qui sont vraiment bien foutu.

Autrement Hardware à créé un [github](https://github.com/hardware/monit-conf.d) avec plusieurs configuration de plusieurs services.  

## Contribution
Toute contribution est la bienvenue.  
N'hésitez pas à contribuer aux Tutoriels, ajout d'information, correction de fautes (et il y en a), amélioration etc ...  
Ça se passe [ici](https://github.com/xataz/Tutoriels)  

## Questions
Toute question sur la [discussion](https://mondedie.fr/d/6947) ou sur [github](https://github.com/xataz/Tutoriels/issues)