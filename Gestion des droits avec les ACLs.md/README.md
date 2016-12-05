# Gestion des droits avec les ACLs

Étant en train de reconfiguration mon NAS, j'en suis maintenant rendu à la gestion des droits, et je me suis dit, pourquoi pas faire un petit tutoriel sur le sujet.

## Qu'est-ce que les ACLs ?
Les ACLs (pour **A**ccess **C**ontrol **L**ist), permettent une gestion plus fine des permissions utilisateurs. Par exemple, nous pouvons donner les droits en écriture pour un utilisateur à un répertoire spécifique, puis seulement en lecture à un autre, et pourquoi pas également à un groupe.
Cela permet d'étendre le modèle unix, qui ne permets de gérer les accès pour un seul utilisateur, un seul groupe, et les autres.

### Concrètement, à quoi cela peut-il servir ?
En fait c'est simple, qui n'a par exemple jamais eu le problème avec l'utilisateur www-data, on voudrais qu'il accède à un fichier ou un répertoire, mais impossible, il n'a pas les droits. On essai généralement de jouer avec les groupes, en ajoutant www-data dans le groupe users par exemple. Avec les ACLs, c'est plus simple, il suffit de dire que le fichier peu être lu par www-data.

## Installation
Malgré que les ACLs soient souvent installé par défaut, cela ne fait pas de mal de vérifier :
```shell
$ apt-get install acl
```

Il nous faut vérifier que les ACLs sont actifs :
```shell
$ grep ACL /boot/config-$(uname -r)
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_FS_POSIX_ACL=y
CONFIG_TMPFS_POSIX_ACL=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_F2FS_FS_POSIX_ACL=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_CEPH_FS_POSIX_ACL=y
CONFIG_CIFS_ACL=y
CONFIG_9P_FS_POSIX_ACL=y
```

De mon coté c'est bon, si ce n'est pas le cas, modifier ce fichier en conséquence, et redémarrer la machine pour que cela sois pris en charge.

Ensuite en fonction de votre système de fichiers, il y aura des actions à faire ou non, si vous utilisez ext4 c'est bon, sinon il faudra remonter la partition avec les bonnes options.
Pour vérifier le système de fichiers, on fait comme ceci :
```shell
# Le résultat de la commande est tronqué
$ mount
[...]
/dev/sde1 on / type ext4 (rw,relatime,errors=remount-ro,data=ordered)
[...]
/dev/sde7 on /tmp type ext4 (rw,relatime,data=ordered)
/dev/sde5 on /var type ext4 (rw,relatime,data=ordered)
/dev/mapper/vgnas-divers on /storage/Divers type ext4 (rw,relatime,stripe=384,data=ordered)
/dev/sde8 on /home type ext4 (rw,relatime,data=ordered)
```

Pour moi, tout est en ext4, mais si par exemple vous êtes en ext3, il vous faudra remonté la partition avec cette commande :
```shell
$ mount -o remount,acl /home
```
Je viens ici de remonter mon home, avec l'option acl, il faudra évidemment ajouter l'option dans le fstab.

## Utilisation
Vous allez voir, c'est vraiment simple à utiliser (mais peux devenir complexe à maintenir), nous n'avons que deux commandes :
- getfacl : Pour lister les acls
- setfacl : Pour gérer les acls

Nous allons commencés par un peu de théorie.

### Les permissions
Comme tout le monde le sait, sous unix, nous avons 3 permissions :
- read : Nommé r ou 4
- write : Nommé w ou 2
- execute : Nommé x ou 1

Pour l'explication purement théorique, c'est permissions sont codés en base 2 (binaire) sur 3 bits (enfin y'a un 4ème bits, mais nous n'en parlerons pas ici) :
Read donne 100 (4)
Write donne 010 (2)
Execute donne 001 (1)

C'est pour cela que chaque permissions à une valeur différente. (Ce principe est également utilisé pour l'adressage IP, mais ce n'est pas le sujet).

Exemple :
Mon utilisateur a les permissions en Lecture et Écriture sur un fichier, cela lui donne donc les permissions rw-, donc 4+2=6, ou 100+010=110.

Ceci pour 3 catégories:
- User : nommé u
- Group : nommé g
- Other : nommé o

ce qui nous donne par exemple :
rwx:r-x:r--
sois :
754
Ou en binaire
111:101:100


Bon si je vous embrouille avec le binaire, sachez que ce n'est pas une nécessité en sois de le connaitre (même si l'informatique est basé la dessus). Le but de ce tutoriel, n'est pas de vous apprendre le binaire, mais si vous voulez en savoir plus, je vous conseil ce [cours](https://openclassrooms.com/courses/les-calculs-en-binaire).

### Appliquer des ACLs
Maintenant que je vous ai tous perdu, on attaque pour de vrai.

Nous commençons donc par setfacl, car il ne sers à rien de lister des ACLs qui n'existe pas \^\^ :
```shell
$ setfacl -h
setfacl 2.2.52 -- définir les listes de contrôle d'accès des fichiers (ACL)
Utilisation : setfacl [-bkndRLP] { -m|-M|-x|-X ... } file ...
  -m, --modify=acl           modifier l'ACL(s) actuel de fichier(s)
  -M, --modify-file=fichier  lire l'entrée ACL à modifier du fichier
  -x, --remove=acl           supprimer les entrées de l'ACL des fichier
  -X, --remove-file=fichier  lire les entrées ACL à supprimer du fichier
  -b, --remove-all           supprimer toutes les entrées ACL étendues
  -k, --remove-default       supprimer l'ACL par défaut
      --set=acl           set the ACL of file(s), replacing the current ACL
      --set-file=file     read ACL entries to set from file
      --mask              do recalculate the effective rights mask
  -n, --no-mask           ne pas recalculer les masques de droits en vigueur
  -d, --default           les opérations s'appliquent à l'ACL par défaut
  -R, --recursive         parcourir récursivement les sous-répertoires
  -L, --logical           suivre les liens symboliques
  -P, --physical          ne pas suivre les liens symboliques
      --restore=fichier   restaurer les ACL (inverse de « getfacl -R »)
      --test              mode test (les ACL ne sont pas modifiés)
  -v, --version           print version and exit
  -h, --help              this help text
```
Le help des outils ACL est plutôt clair.

Pour appliquer des permissions, c'est plutôt simple, et nous utiliserons ce format :
```shell
categorie:userougroup:permissions
```

Par exemple pour l'utilisateur user1, le groupe group1 et les autres nous utiliserons ceci :
```shell
u:user1:rwx
g:group1:rx
o::-
```
Ce qui donne que user1 a toutes les permissions, group1 peut lire et exécuter, et les autres vont se faire voir.

Pas si différent d'un chmod en faite (un peu quand même, mais le principe est le même).

Qu'est-ce que ça donne une commande complète, nous partirons pour cette exemple, sur un nouveau répertoire dans /opt, que je nommerai acl ^^.

Nous allons donner les droits à user1 :
```shell
$ setfacl -m u:user1:rwx /opt/acl
```
C'est simple non ?!
Pareil pour le groupe et les autres :
```shell
$ setfacl -m g:group1:rx /opt/acl
$ setfacl -m o::- /opt/acl
```

Quand on ne veut aucune permission, on mets -, sinon setfacl nous crache dessus.

Par contre avec ces commandes, les ACLs ne sont appliqués que pour /opt/acl, et pas pour les sous répertoires et fichiers. Pour cela nous utiliserons comme pour chmod, l'option -R :
```shell
$ setfacl -R -m u:user2:rwx /opt/acl
$ setfacl -R -m g:group2:rx /opt/acl
$ setfacl -R -m o::- /opt/acl
```

### Lister les acls
Pour lister les acls, c'est tout aussi simple :
```shell
$ getfacl -h
getfacl 2.2.52 -- get file access control lists
Usage: getfacl [-aceEsRLPtpndvh] file ...
  -a,  --access           display the file access control list only
  -d, --default           display the default access control list only
  -c, --omit-header       do not display the comment header
  -e, --all-effective     print all effective rights
  -E, --no-effective      print no effective rights
  -s, --skip-base         skip files that only have the base entries
  -R, --recursive         recurse into subdirectories
  -L, --logical           logical walk, follow symbolic links
  -P, --physical          physical walk, do not follow symbolic links
  -t, --tabular           use tabular output format
  -n, --numeric           print numeric user/group identifiers
  -p, --absolute-names    don't strip leading '/' in pathnames
  -v, --version           print version and exit
  -h, --help              this help text
```

Voyons voir notre dossier /opt/acl :
```shell
/opt/acl # getfacl .
# file: .
# owner: root
# group: root
user::rwx
user:user1:rwx
group::r-x
group:group1:r-x
mask::rwx
other::---
default:user::rwx
default:group::r-x
default:group:group1:rwx
default:mask::rwx
default:other::---
```

Ici c'est plutôt simple :
user::rwx, group::r-x et other::--- correspondent au droit unix (chmod), donc 750
group:group1:r-x est l'accès du groupe group1, donc 5 (101)
user:user1:rwx est l'accès de l'utilisateur user1, donc 7 (111)

Nous voyons deux particularités, le default, et le mask que je vais bien sur vous expliquer.

### Le mask
Le mask est la permission global, par défaut égal à la permission maximum d'un utilisateur ou groupe, ici rwx.
Si je mets le mask à rw par exemple, que ce passe t'il ?
```shell
/opt/acl # setfacl -m m::rw .
/opt/acl # getfacl .
# file: .
# owner: root
# group: root
user::rwx
user:user1:rwx                  #effective:rw-
group::r-x                      #effective:r--
group:user1:r-x                 #effective:r--
mask::rw-
other::---
default:user::rwx
default:group::r-x
default:group:group1:rwx
default:mask::rwx
default:other::---
```

Nous voyons donc le mask à rw, et en plus nous avons les commentaires _effective_ qui sont apparu. Ceci est la véritable permission que l'utilisateur aura. En fait le mask, permet de définir la permission maximum que les utilisateurs et groupes pourrons avoir.
Donc puisque la permission de user1 est rwx, et que x n'est pas autorisé, ces droits effectifs (entendez par là réel), sont en fait rw.

### Le default
Les permissions par défaut sont pratique, ils permettent de préciser les permissions qui serons appliqué en cas de création de fichiers ou répertoires.

Dans cet exemple, nous voyons ceci :
```shell
default:user::rwx
default:group::r-x
default:group:group1:rwx
default:mask::rwx
default:other::---
```
Ce qui veux dire littéralement :
Les droits unix serons 750 (default:user::rwx, default:group::r-x et default:other::---).
Le groupe group1 aura toute les permissions
Et nous autorisons les permissions rwx.

Si par exemple avec mon utilisateur root je crée un fichier vide :
```shell
/opt/acl # touch test
/opt/acl # getfacl test
# file: test
# owner: root
# group: root
user::rw-
group::r-x                      #effective:r--
group:group1:rwx                #effective:rw-
mask::rw-
other::rw-
```

euh ? pourquoi le mask est rw, alors que le mask par défaut est rwx ?
En fait c'est simple, le fichier n'est pas reconnu comme exécutable par le propriétaire, donc également pour les acl.

Si je rajoute cette permission au groupe propriétaire, cela va fonctionner (idem pour un utilisateur) :
```shell
/opt/acl # chmod g+x test
/opt/acl # ls -l
total 0
-rw-rwxrw-    1 root     root             0 Feb 17 19:03 test
/opt/acl # getfacl test
# file: test
# owner: root
# group: root
user::rw-
user:user1:rwx
group::r-x
group:group1:rwx
mask::rwx
other::rw-
```


## Conclusion
Voila pour ce tutoriel, c'est bref, mais j'espère que j'ai bien expliqué le principe. Dans l'exemple j'applique surtout à un répertoire, mais on peux également appliquer les acls directement sur un fichier.

## Contribution
Toute contribution est la bienvenue.  
N'hésitez pas à contribuer aux Tutoriels, ajout d'information, correction de fautes (et il y en a), amélioration etc ...  
Ça se passe [ici](https://github.com/xataz/Tutoriels)  

## Questions
Toute question sur la [discussion](https://mondedie.fr/d/7847) ou sur [github](https://github.com/xataz/Tutoriels/issues)