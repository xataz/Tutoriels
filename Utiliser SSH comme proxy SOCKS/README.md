# Utiliser SSH comme proxy SOCKS

## A quoi va nous servir ceci ?
A naviguer plus anonymement, en gros on fait passer (presque) tous par un tunnel SSH, ce qui fait que le serveur finale, lui n'a connaissance que de l'IP du serveur qui héberge SSH. En gros c'est presque comme un tunnel VPN, en plus simple.
### Avantages
Plus simple à mettre en place qu'un serveur VPN, natif sous linux.
### Inconvénients
Les requêtes dns ne passe pas par ce tunnel, mais tous le reste. Il faut également configurer chaque applications pour qu'elle passe par ce proxy.

## Comment sa marche ?
Sans rentré dans les détails techniques, la solution que nous allons utilisé utilise le SSH de notre dédié, plus putty sur le client, rien de plus simple.
En gros on configure putty pour qu'il créé un tunnel sur un port spécifique (port locale au client), puis on connecte l'application cliente sur ce port locale.

## On attaque ?
### Sur le dédié
Ba en fait on a rien a faire, sauf si SSH n'est pas installé, mais normalement cela est fait.

### Sur le client
#### Sous windows
Il faut utilisé un client SSH, Ici nous utiliserons putty (même si je lui préfère kitty).
Pour le configurer, c'est plutôt simple.
Déjà configurer le de la même manière que vous le faites pour vous connecté au serveur (si vous avez enregistré vos paramètres, choisissez le bon et cliquer sur load). Sauf qu'il faut ajouter une options :
Dans Connection -> SSH -> Tunnels :
Ajouté dans "Source port", un port voulu, perso j'utilise 8080.
Sélectionné "Dynamic".
Et cliquer sur "Add", normalement vous avez D8080 qui apparait dans la liste au dessus.
Il n'y a plus qu'a ouvrir la session en cliquant sur Open.

Une fenêtre s'ouvre comme d'habitude, si vous n'utilisez pas d'authentification par clé, connecté vous. Ne fermez surtout pas la fenêtre, sinon le tunnel se terminera
Et c'est tous.

#### Sous linux
Ouvrez une console et taper :
[code]ssh -D 8080 login@dédiéIP[/code]
D pour dynamic, et 8080 le numéro de port choisi (ceci n'est pas le port SSH, mais un port choisi arbitrairement).
A adapté si vous utilisez une connexion par clé, ou un autre port

### L'application
Nous allons prendre comme exemple Firefox.
Allez dans les options, puis Avancés, Réseau, et cliquez sur Paramètres en face de de Connexions.
Et configurer comme sur l'image :
[url=http://images.mondedie.fr/?v=paramtresd.jpg][img]https://images.mondedie.fr/images/paramtresd.jpg[/img][/url]

Pour tester allez sur le site [url]http://www.mon-ip.com/[/url], et vérifiez que l'IP affiché est celle de votre dédié.

## Bonus, configurer une passerelle, ou comment bien faire les choses
Petit bonus que j'utilise chez moi, j'ai un raspberry (mais sa peut être n'importe qu'elle serveur) qui me sers de passerelle a ce proxy SOCKS. Cela évite de devoir configurer toutes les machines de la maison de cette manière, et c'est plutôt contraignant de devoir tous reconfigurer a chaque reboot.

Pour ce faire, il faut une connexion par clé. Puisque nous faisons les choses bien, nous allons créé un nouvelle utilisateur sur le dédié, pour gérer tous seul ceci. (Je ne partirais pas sur les spécifications que certains ont pour la configuration du serveur ssh, comme le match d'user ou autres).

### Sur le dédié
On ajoute un utilisateur :
[code]adduser sshtunnel[/code]

Et c'est tous pour le dédié.

### Sur le RPI (ou autres)
#### Création de l'utilisateur
On ajoute également un user :
```shell
$ adduser sshtunnel
```
On ce connecte sur cette user :
```shell
$ sudo su - sshtunnel
```
ou 
```shell
$ su - sshtunnel
```

#### Création de la clé RSA
On crée la clé RSA :
```shell
$ ssh-keygen -t RSA -b 4096 # Oui c'est une grosse clé
```
On ne mets pas de passphrase

On transfère la clé publique :
```shell
$ ssh-copy-id -i ~/.ssh/id_rsa.pub sshtunnel@dédiéIP
```
Si vous avez un autre port:
```shell
$ ssh-copy-id -i ~/.ssh/id_rsa.pub "-p 2222 sshtunnel@dédiéIP"
```

on test si la connexion passe :
```shell
$ ssh -i ~/.ssh/id_rsa sshtunnel@dédiéIP
```

Si on ce connecte, c'est tous bon.

#### Configuration SSH :
Nous allons configurer un alias pour cette connexion, pour ce faire, créé ce fichier :
```shell
nano ~/.ssh/config
```
Et on ajoute ceci dedans :
```shell
Host dedie
    HostName dédiéIP
    User sshtunnel
    IdentityFile ~/.ssh/id_rsa
    Port 22
    DynamicForward 0.0.0.0:8080
```
Explication :  

- Host : C'est juste un nom, on peu mettre ce qu'on veux  
- HostName : L'ip de votre dédié
- User : L'user de connexion
- IdentityFile : La clé privé
- Port :  le port de connexion ssh    
- DynamicForward : le port d'écoute plus l'ip d'écoute

On test :
```shell
$ ssh dedie
```
Si sa fonctionne, on quitte.
et on relance avec :
```shell
$ ssh -f -N dedie
```
Ceci permets de faire tourner la connexion en background

#### Script de relance
```shell
$ nano /opt/tunnel.sh
```
```shell
#!/bin/bash

PORT=8080

netstat -an | grep $PORT  > /dev/null 2>&1
if [ $? -eq 1 ]
then
    ssh -f -N dedie
fi
```

Le script est plutôt simple, si la connexion n'existe pas, on relance.

On va créé une petite tache cron qui s'executera toutes les minutes, pour évité les coupures, puisqu'il arrive qu'une connexion ssh ce coupe.
```shell
$ crontab -e 
```
et on ajoute :
```shell
* * * * * /opt/tunnel.sh
```

### Sur les clients
#### Configuration
On reprends firefox, on refait pareil, mais a la place de mettre 127.0.0.1, on mets l'ip du RPI (pour moi 192.168.1.16).

On test de nouveau avec mon-ip.com, et normalement, tous devrait correctement fonctionner.


## Contribution
Toute contribution est la bienvenue.  
N'hésitez pas à contribuer aux Tutoriels, ajout d'information, correction de fautes (et il y en a), amélioration etc ...  
Ça se passe [ici](https://github.com/xataz/Tutoriels)  

## Questions
Toute question sur la [discussion](https://mondedie.fr/d/6863) ou sur [github](https://github.com/xataz/Tutoriels/issues)