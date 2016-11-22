# Direct Download et Upload avec plowshare

## Plowshare kesako ?
Plowshare est une suite de script permettant la gestion des sites de partage de fichier, comme 1fichier ou uploaded.net. Cette suite permet d'uploader, de télécharger, de supprimer, de lister, de vérifier des fichiers sur ces hébergeurs. Il permets même sur certains site, d'utiliser son propre compte.

[color=#f21313]ATTENTION[/color] : Ceci est un outil 100% en ligne de commande.

## Pré-requis
Si vous avez suivit le tutoriel de rutorrent ou utilisé le script de ex_rat, tous est bon.
Sinon il faudra installer git et curl :
```shell
$ apt-get install git curl -y
```

## Installation
Rien de bien compliquer pour l'installer.
On commence par récupérer les sources :
```shell
$ cd /tmp
$ git clone https://github.com/mcrapet/plowshare.git
$ cd plowshare
$ make install
$ cd ..
$ rm -rf plowshare
```

Et voila c'est installer, mais pas totalement fonctionnel.
Il faut d'abord installer les modules :
```shell
$ plowmod --install
```
Ceci est à faire avec chaque utilisateur qui ce servira de plowshare

## Les outils
Comme je le disais plowshare est une suite de script, donc il fourni plusieurs script qui ont une utilité chacun. Nous en avons déjà utilisé un, qui est plowmod.
Voici une courte explication de ces scripts, qui sont plutôt clair par leur nom :
**plowdown** : Permets de télécharger des fichiers
**plowup** : Permets d'uploader des fichiers
**plowlist** : Sur beaucoup de site, on peut créé des folders de fichier, ceci permets donc le lister les fichiers dans un folder.
**plowprobe** : Permets d'obtenir les informations sur les fichiers, comme la taille, mais aussi savoir si le lien est encore valide.
**plowdel** : Permets de supprimer un fichier uploader
**plowmod** : Permets la gestion des modules, tous à l'heure couplé au paramètre --install, permettait l'installation des modules, nous pouvons bien sur les mettres à jour, avec --update.

Nous allons donc voir comment utilisé les scripts plowup et plowdown, et ce sera déjà pas mal.
Je ne vais pas expliquer comment l'utiliser avec tous les hébergeurs, il en prends trop en compte, étant donner que j'ai eu une demande pour 1fichier récemment je prendrais celui ci en exemple, plus uploaded_net, parce que ...

## Les hébergeurs
Beaucoup d'hébergeurs sont supportés, je ne vais pas affiché la liste complète ici, mais vous pouvez l'obtenir avec l'options --modules :
```shell
$ plowup --modules
$ plowdown --modules
$ plowlist --modules
$ plowprobe --modules
$ plowdel --modules
```

Par contre, certains modules ne sont pas compatibles avec toutes ces options, à vous de vérifier.


## plowup
Pour moi l'outil le plus utile, je télécharge les vidéos 4K de du chat de ma sœur principalement en torrent, mais le repartage sur ces sites (son chat est une star, y'a de la demande).

### La syntaxe
La syntax est plutôt simple :
```shell
$ plowup [argument] [hébergeur] [fichier]
```

### Les arguments
En fonction des hébergeurs, les arguments peuvent être différents. Pour les obtenir il suffit de faire :
```shell
$ plowup --longhelp
```
Voici une partie du résultat de cette commande, pour 1fichier :
```shell
[...]
Options for module <1fichier>:
  -a, --auth=USER:PASSWORD         User account
  -p, --link-password=PASSWORD     Protect a link with a password
  -d, --message=MESSAGE            Set file message (is send with notification email)
      --domain=ID                  You can set domain ID to upload (ID can be found at http://www.1fichier.com/en/api/web.html)
      --email-to=EMAIL             <To> field for notification email
      --restrictip                 Restrict login session to my IP address
[...]
```
J'ai pas trouvé mieux pour obtenir ces arguments, il va falloir fouiné.
Mais en règle général nous utiliserons principalement :
```shell
-a user:password     Pour l'authentification
-b user:password     Pour l'authentification si compatible seulement avec les comptes gratuit
```
Il y a d'autres options sur certains hébergeurs, comme pouvoir ajouter une description, un mot de passe pour le téléchargement, ou le répertoire d'upload. 

### exemples
#### Envoyer un fichier sur 1fichier sans authentification :
```shell
$ plowup 1fichier test.txt
Starting upload (1fichier): test.txt
Destination file: test.txt
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6434    0  4587  100  1847   4664   1878 --:--:-- --:--:-- --:--:--  5007
#DEL https://1fichier.com/remove/4walgw1m6s/G6ttD
https://1fichier.com/?4walgw1m6s
```
Comme on peut le voir, le résultat est plutôt clair, nous avons un lien de suppression (pas forcément sur tous les hébergeurs), et en dessous le lien de téléchargement, souvent celui que l'on partage.

#### Envoyer un fichier sur uploaded_net avec authentification :
```shell
$ plowup -a username:password uploaded_net test.txt
Starting upload (uploaded_net): test.txt
Destination file: test.txt
Starting login process: XXXXXXXX/**********
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1707    0    11  100  1696     11   1786 --:--:-- --:--:-- --:--:--  9860
#ADM 90tn73xm
http://ul.to/skuh3t8h
```
Comme pour sans authentification, nous avons le lien pour le téléchargement, par contre je dois avouer que ce qu'il y a après le ADM, j'en ai aucune idée.

#### Envoyer plusieurs fichiers sur 1fichier :
```shell
xataz@seedbox:/home/xataz/# plowup 1fichier /chemin/des/fichier/*
Destination file: rtorrent.py
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11622    0  4587  100  7035   5518   8463 --:--:-- --:--:-- --:--:--  8610
#DEL https://1fichier.com/remove/cryud4e79p/9rCT6
https://1fichier.com/?cryud4e79p
Starting upload (1fichier): test.php
Destination file: test.php
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6903    0  4587  100  2316   5517   2785 --:--:-- --:--:-- --:--:--  5600
#DEL https://1fichier.com/remove/blgbcl9uda/YZ7Q2
https://1fichier.com/?blgbcl9uda
```
Le résultat est le même mais avec plusieurs liens.

Et si je ne veux pas télécharger tous les fichiers présents dans ce répertoire, là c'est plus compliqué, il faudrait créé un fichier texte avec le nom des fichiers dans un fichier text, que l'on execute comme ceci :
```shell
# mon fichier text
file1
file2
file3
file4
file5
file6
file7
file8
file9
file test
```
_Je sais je suis très original_

Je le lance comme ceci :
```shell
$ while read i; do plowup 1fichier "$i"; done < test.txt
```
Je ne mets pas le résultat de la commande car il est plutôt long, mais ça marche.
Pour expliquer un peu, on boucle sur chaque ligne du fichier, pour lequel a chaque fois on fait un plowup de ce fichier.

## plowdown
### La syntaxe
La syntax est plutôt simple, similaire à plowup :
```shell
$ plowdown [argument] [hébergeur] [url]
```
Il n'est pas toujours utile de mettre le nom de l'hébergeur.

### Les arguments
En fonction des hébergeurs, les arguments peuvent être différents. Pour les obtenir il suffit de faire :
```shell
$ plowdown --longhelp
```
Voici une partie du résultat de cette commande, pour 1fichier et uploaded_net :
```shell
[...]
Options for module <1fichier>:
  -a, --auth=USER:PASSWORD         Premium account
  -p, --link-password=PASSWORD     Used in password-protected files
      --restrictip                 Restrict login session to my IP address
[...]
Options for module <uploaded_net>:
  -a, --auth=USER:PASSWORD         User account
  -p, --link-password=PASSWORD     Used in password-protected files
[...]
```

J'ai pas trouvé mieux pour obtenir ces arguments, il va falloir fouiné.
Mais en règle général nous utiliserons principalement :
```shell
-a user:password     Pour l'authentification
-b user:password     Pour l'authentification si compatible seulement avec les comptes gratuit
```

### exemples
#### Téléchargement d'un fichier sans authentification sur uploaded_net avec captcha puis 1fichier sans captcha :
```shell
$ plowdown http://ul.to/mfqzmd4f
Starting download (uploaded_net): http://ul.to/mfqzmd4f
Waiting 31 seconds... done
DISPLAY variable not exported! Skip X11 viewers probing.
No ascii viewer found to display captcha image
Local image: /tmp/plowdown.17887.25704.recaptcha.jpg
Leave this field blank and hit enter to get another captcha image
Enter captcha response (drop punctuation marks, case insensitive):
```

> Pour les captcha, je télécharge l'image avec filezilla. Lors du test impossible de lire correctement le captcha, ça vient peu être de moi, mais franchement ils sont difficilement lisible ^^.

```shell
$ plowdown https://1fichier.com/?s3kk91yzx2
Starting download (1fichier): https://1fichier.com/?s3kk91yzx2
File URL: https://a-7.1fichier.com/s26562064
Filename: file test
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     2    0     2    0     0      0      0 --:--:--  0:00:02 --:--:--     3
file test
```

#### Téléchargement d'un fichier avec authentification sur 1fichier :
```shell
xataz@seedbox:~/test$ plowdown -a email:pass https://1fichier.com/?gvyovqoffj
Starting download (1fichier): https://1fichier.com/?gvyovqoffj
Starting login process: XXXX@XXX.XX/******
File URL: https://a-7.1fichier.com/s26562140
Filename: file6
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     2  100     2    0     0      3      0 --:--:-- --:--:-- --:--:--     3
file6
```

#### Téléchargement de plusieurs fichiers sur 1fichier :
On crée un fichier avec toutes les urls :
```shell
https://1fichier.com/?yb8c051e4x
https://1fichier.com/?svznjbhc69
https://1fichier.com/?v7saebso46
https://1fichier.com/?qwpj4q599e
https://1fichier.com/?onfpze9atu
https://1fichier.com/?gvyovqoffj
https://1fichier.com/?x6rhfio2th
https://1fichier.com/?gnsx9dph1k
https://1fichier.com/?gs67vykdbm
https://1fichier.com/?s3kk91yzx2
```
et on télécharge :
```shell
$ plowdown url.txt
Starting download (1fichier): https://1fichier.com/?yb8c051e4x
File URL: https://a-7.1fichier.com/s26562196
Filename: file1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     2  100     2    0     0      3      0 --:--:-- --:--:-- --:--:--     3
file1
[...]
Starting download (1fichier): https://1fichier.com/?s3kk91yzx2
File URL: https://a-7.1fichier.com/s26562207
Filename: file test
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     2  100     2    0     0      3      0 --:--:-- --:--:-- --:--:--     3
file test
```
Cela fonctionne également avec plusieurs hébergeurs.


## Le fichier de configuration
Nous pouvons utilisé un fichier de configuration qui permettra de ne plus avoir à entrer les identifiants avec la commande.

Il suffit de créé un fichier dans votre home :
```shell
nano ~/.config/plowshare/plowshare.conf
```
Et par exemple :
```shell
[General]
interface = eth0

uploaded_net/a = "username:password"
1fichier/a = "usermail:password"

[Plowdown]
timeout=3600

[Plowup]
max-retries=2
```
Ne pas oublié de changer les droits du fichier pour évité des erreurs :
```shell
chmod 600 ~/.config/plowshare/plowshare.conf
```

Maintenant si vous télécharger ou uploader sur uploaded_net, ou 1fichier, plus besoin de rentrer un identifiant :
```shell
plowup 1fichier monfichieraup
```

## Conclusion
Je n'ai ici que expliqué les options basique de plowshare, il existe beaucoup d'autre options, que vous pouvez retrouver sur le [github](https://github.com/mcrapet/plowshare).

## Contribution
Toute contribution est la bienvenue.  
N'hésitez pas à contribuer au Tutoriel, ajout d'information, correction de fautes (et il y en a), amélioration etc ...  
Ça se passe [ici](https://github.com/xataz/Tutoriels)  

## Questions
Toute question sur la [discussion](https://mondedie.fr/d/7150) ou sur [github](https://github.com/xataz/Tutoriels/issues)