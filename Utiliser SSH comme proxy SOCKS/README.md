[u][color=#f71707][b]I. A quoi va nous servir ceci ?[/b][/color][/u]
A naviguer plus anonymement, en gros on fait passer (presque) tous par un tunnel SSH, ce qui fait que le serveur finale, lui n'a connaissance que de l'IP du serveur qui héberge SSH. En gros c'est presque comme un tunnel VPN, en plus simple.
[u][b]a. Avantages[/b][/u]
Plus simple à mettre en place qu'un serveur VPN, natif sous linux.
[u][b]b. Inconvénients[/b][/u]
Les requêtes dns ne passe pas par ce tunnel, mais tous le reste. Il faut également configurer chaque applications pour qu'elle passe par ce proxy.

[u][color=#f71707][b]II. Comment sa marche ?[/b][/color][/u]
Sans rentré dans les détails techniques, la solution que nous allons utilisé utilise le SSH de notre dédié, plus putty sur le client, rien de plus simple.
En gros on configure putty pour qu'il créé un tunnel sur un port spécifique (port locale au client), puis on connecte l'application cliente sur ce port locale.

[u][color=#f71707][b]III. On attaque ?[/b][/color][/u]
[u][b]a. Sur le dédié[/b][/u]
Ba en fait on a rien a faire, sauf si SSH n'est pas installer, mais normalement cela est fait.

[u][b]b. Sur le client[/b][/u]
[u]1. Sous windows[/u]
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

[u]2. Sous linux[/u]
Ouvrez une console et taper :
[code]ssh -D 8080 login@dédiéIP[/code]
D pour dynamic, et 8080 le numéro de port choisi (ceci n'est pas le port SSH, mais un port choisi arbitrairement).
A adapté si vous utilisez une connexion par clé, ou un autre port

[u][b]c. L'application[/b][/u]
Nous allons prendre comme exemple Firefox.
Allez dans les options, puis Avancés, Réseau, et cliquez sur Paramètres en face de de Connexions.
Et configurer comme sur l'image :
[url=http://images.mondedie.fr/?v=paramtresd.jpg][img]https://images.mondedie.fr/images/paramtresd.jpg[/img][/url]

Pour tester allez sur le site [url]http://www.mon-ip.com/[/url], et vérifiez que l'IP affiché est celle de votre dédié.

[u][color=#f71707][b]IV. Bonus, configurer une passerelle, ou comment bien faire les choses[/b][/color][/u]
Petit bonus que j'utilise chez moi, j'ai un raspberry (mais sa peut être n'importe qu'elle serveur) qui me sers de passerelle a ce proxy SOCKS. Cela évite de devoir configurer toutes les machines de la maison de cette manière, et c'est plutôt contraignant de devoir tous reconfigurer a chaque reboot.

Pour ce faire, il faut une connexion par clé. Puisque nous faisons les choses bien, nous allons créé un nouvelle utilisateur sur le dédié, pour gérer tous seul ceci. (Je ne partirais pas sur les spécifications que certains ont pour la configuration du serveur ssh, comme le match d'user ou autres).

[u][b]a. Sur le dédié[/b][/u]
On ajoute un utilisateur :
[code]adduser sshtunnel[/code]

Et c'est tous pour le dédié.

[u][b]b. Sur le RPI (ou autres)[/b][/u]
[u]1. Création de l'utilisateur[/u]
On ajoute également un user :
[code]adduser sshtunnel[/code]
On ce connecte sur cette user :
[code]sudo su - sshtunnel[/code]
ou 
[code]su - sshtunnel[/code]

[u]2. Création de la clé RSA[/u]
On crée la clé RSA :
[code]ssh-keygen -t RSA -b 4096 # Oui c'est une grosse clé[/code]
On ne mets pas de passphrase

On transfère la clé publique :
[code]ssh-copy-id -i ~/.ssh/id_rsa.pub sshtunnel@dédiéIP[/code]
Si vous avez un autre port:
[code]ssh-copy-id -i ~/.ssh/id_rsa.pub "-p 2222 sshtunnel@dédiéIP"[/code]

on test si la connexion passe :
[code]ssh -i ~/.ssh/id_rsa sshtunnel@dédiéIP[/code]

Si on ce connecte, c'est tous bon.

[u]3. Configuration SSH :[/u]
Nous allons configurer un alias pour cette connexion, pour ce faire, créé ce fichier :
[code]nano ~/.ssh/config[/code]
Et on ajoute ceci dedans :
[code]
Host dedie
    HostName dédiéIP
    User sshtunnel
    IdentityFile ~/.ssh/id_rsa
    Port 22
    DynamicForward 0.0.0.0:8080
[/code]
Explication :
Host : C'est juste un nom, on peu mettre ce qu'on veux
    HostName : L'ip de votre dédié
    User : L'user de connexion
    IdentityFile : La clé privé
    Port :  le port de connexion ssh    
    DynamicForward : le port d'écoute plus l'ip d'écoute

On test :
[code]ssh dédié[/code]
Si sa fonctionne, on quitte.
et on relance avec :
[code]ssh -f -N dédié[/code]
Ceci permets de faire tourner la connexion en background

[u]4. Script de relance[/u]
[code]nano /opt/tunnel.sh[/code]
[code]
#!/bin/bash

PORT=8080

netstat -an | grep $PORT  > /dev/null 2>&1
if [ $? -eq 1 ]
then
    ssh -f -N dedie
fi
[/code]

Le script est plutôt simple, si la connexion n'existe pas, on relance.

On va créé une petite tache cron qui s'executera toutes les minutes, pour évité les coupures, puisqu'il arrive qu'une connexion ssh ce coupe.
[code]crontab -e[/code]
et on ajoute :
[code]
* * * * * /opt/tunnel.sh
[/code]

[b]c. Sur les clients[/b]
[u]1. Configuration[/u]
On reprends firefox, on refait pareil, mais a la place de mettre 127.0.0.1, on mets l'ip du RPI (pour moi 192.168.1.16).

On test de nouveau avec mon-ip.com, et normalement, tous devrait correctement fonctionner.