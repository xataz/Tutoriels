# Partitionnement de mon dedié avec LVM

## LVM kesako ?
LVM (logical volume manager), est un outils permettant la création et la gestion de volume logique (~= partition logique). LVM permets une gestion simplifié de ces volumes.

LVM agit sur plusieurs "couche", représenté sur ce schéma (merci ubuntu-fr ^^) :
![Schéma](https://doc.ubuntu-fr.org/_media/lvm.jpg)

Nous avons les volumes physique que l'on appelle PV (Physical Volume), ce sont des partitions ou des disques durs complets.
Ensuite nous avons les groupes de volumes, que l'on appelle VG (Volume Group), ce sont des groupes de PV.
Puis nous avons les volumes logique, que l'on appelle LV (Logical Volume), ce sont les "partitions".

## Avantages
- Simplifie l’allocation d'espaces disques.

## inconvénients
- Dans le cas de plusieurs PV dans un VG, si un disque crash, tous est perdu.

## Pré-requis
On a pas besoin de beaucoup de choses :
- LVM installé (apt-get install lvm2)
- Un peu de temps
- De l'attention, une boulette est vite arrivé
- Un dédié fraichement installé

## Le cas utilisé
Je prends l'exemple d'un kimsufi, si je ne me trompe pas, le panel de kimsufi ne permets pas de faire une installation avec lvm de base.
Il me semble que le problème est le même chez online.

Mon serveur est de base installé comme ceci :
```shell
Device          Start        End    Sectors    Size Type
/dev/sda1          40       2048       2009 1004,5K BIOS boot
/dev/sda2        4096   40962047   40957952   19,5G Linux filesystem
/dev/sda3    40962048 3905974271 3865012224    1,8T Linux filesystem
/dev/sda4  3905974272 3907020799    1046528    511M Linux swap
```

Le /dev/sda2 étant le root, et le sda3 le home. Si votre partitionnement n'est pas comme ceci, il va falloir passer par la case redimensionnement via le rescue.

Ce tutoriel est réalisé en live, donc tous devrait fonctionner, car ce sont des copiés collés de ce que j'ai réalisé sur mon kimsufi.

Bon, vous êtes prêt ?! on y va !!!

## Préparation du système
On commence par vérifier la présence de lvm :
```shell
$ lvm version
  LVM version:     2.02.111(2) (2014-09-01)
  Library version: 1.02.90 (2014-09-01)
  Driver version:  4.27.0
```

C'est cool, c'est installé.
Si ce n'est pas le cas, il faut l'installer :
```shell
$ apt-get install lvm2
```

Si vous avez des utilisateurs déjà créé, sauvegardé le contenu des homes, car tous sera supprimé.

Nous allons maintenant démonté le home :
```shell
$ umount /home
```
Et directement on va supprimer la ligne dans le fstab :
```shell
nano /etc/fstab
```
et on supprime la ligne du home, pour moi c'est :
```shell
/dev/sda3       /home   ext4    defaults,relatime       1       2
```

## Création du PV
Nous allons créé notre PV sur sda3, c'est plutôt simple :
```shell
$ pvcreate /dev/sda3
  Physical volume "/dev/sda3" successfully created
```

Et c'est tous.

## Création du VG
C'est aussi simple de créé un VG :
```shell
$ vgcreate vghome /dev/sda3
  Volume group "vghome" successfully created
```
Dans cet exemple, je l'ai nommé vghome, c'est un choix arbitraire, j'aurais pu tapé :
```shell
$ vgcreate monVG /dev/sda3
```


## Obtenir des informations sur le VG créé
```shell
$ vgdisplay vghome
  --- Volume group ---
  VG Name               vghome
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1,80 TiB
  PE Size               4,00 MiB
  Total PE              471803
  Alloc PE / Size       0 / 0
  Free  PE / Size       471803 / 1,80 TiB
  VG UUID               yBQGpE-2cMa-3g9B-msCS-BjAP-Cp6q-pESGIl
```

## Création d'un LV
Je vais maintenant me créé un LV, c'est la que je défini la taille.
Puisque c'est pour moi, j'ai besoin de 500Go, voici comment je le crée :
```shell
$ lvcreate -L 500G -n xataz vghome
  Logical volume "xataz" created
```
Pour les options :

- -L : Pour choisir la taille
- -n : Pour le nom du lv, choix arbitraire, mais logique, c'est pour mon home, je l'appelle donc xataz, question d'organisation.
- et on fini par vghome, car je veux qu'il sois sur ce vg (et parce que j'en ai qu'un ^^)


Maintenant il faut formaté celui ci (en ext4) :
```shell
$ mkfs.ext4 /dev/mapper/vghome-xataz
mke2fs 1.42.12 (29-Aug-2014)
En train de créer un système de fichiers avec 131072000 4k blocs et 32768000 i-noeuds.
UUID de système de fichiers=95bd7e36-7524-4391-a044-b8eec060d92f
Superblocs de secours stockés sur les blocs :
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968,
        102400000

Allocation des tables de groupe : complété
Écriture des tables d'i-noeuds : complété
Création du journal (32768 blocs) : complété
Écriture des superblocs et de l'information de comptabilité du système de
fichiers : complété
```

Les LVs ce trouvent à deux endroits dans le /dev, nous avons le choix entre :
```shell
/dev/mapper/vgname-lvname
```
ou
```shell
/dev/vgname/lvname
```

Pour le fameux 5% de réservé, nous pouvons le supprimer avec :

```shell
$ tune2fs -m 0 /dev/mapper/vghome-xataz
tune2fs 1.42.12 (29-Aug-2014)
Définition du pourcentage de blocs réservés à 0% (0 blocs)
```

## Création d'un deuxième LV
Pendant que j'y suis, je vais créé un VG pour ma soeur (didine), elle n'a pas besoin de 500Go, mais 50go devrait lui suffire, mais avant ceci, je vais vérifier que j'ai assez de place :
```shell
$ vgdisplay vghome
  --- Volume group ---
  VG Name               vghome
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1,80 TiB
  PE Size               4,00 MiB
  Total PE              471803
  Alloc PE / Size       128000 / 500,00 GiB
  Free  PE / Size       343803 / 1,31 TiB
  VG UUID               yBQGpE-2cMa-3g9B-msCS-BjAP-Cp6q-pESGIl
```
On voit qu'il me reste 1,31 To :
```shell
Free  PE / Size       343803 / 1,31 TiB
```
Je peux donc sans soucis créer la partition pour ma soeurette (en vrai c'est un chieuse) :
```shell
$ lvcreate -L 50G -n didine vghome
  Logical volume "didine" created
```
et on formate :
```shell
$ mkfs.ext4 /dev/vghome/didine
```

Puis on supprime les 5% réservé :
```shell
$ tune2fs -m 0 /dev/mapper/vghome-didine
tune2fs 1.42.12 (29-Aug-2014)
Définition du pourcentage de blocs réservés à 0% (0 blocs)
```


D’ailleurs didine sera mon cobaye pour la suite de ce tutoriel.

## Montage des partitions
Puisque nous créons des LV pour nos utilisateurs, nous allons d'abord créer le répertoire pour notre utilisateur :
```shell
$ mkdir -p /home/xataz
```

On monte sur le home de l'utilisateur :
```shell
$ mount /dev/mapper/vghome-xataz /home/xataz/
```

On crée l'utilisateur :
```shell
useradd -M -s /bin/bash xataz
```
Ou alors avec le script d'ex_rat, dans n'exécutez pas la commande suivante. 

On change les droits du home :
```shell
$ chown -R xataz:xataz /home/xataz
```

Et voila, notre utilisateur à sa propre partition.

Il ne reste plus qu'à écrire tous ceci en dur dans le fstab :
```shell
nano /etc/fstab
```
et on rajoute ceci :
```shell
/dev/mapper/vghome-xataz        /home/xataz     ext4    defaults        0       2
```

Je fait de même pour didine en background.

## Redimensionnement d'un LV
On commence ici le récit fabuleux de "didine la pissouse".

### Augmentation de l'espace disque
Didine ayant fait trop de vidéo de son chat, n'a plus de place, elle me demande donc de lui ajouté 50Go.

Pour commencer, je vérifie que je peux le faire :
```shell
$ vgdisplay vghome
  --- Volume group ---
  VG Name               vghome
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  7
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1,80 TiB
  PE Size               4,00 MiB
  Total PE              471803
  Alloc PE / Size       140800 / 550,00 GiB
  Free  PE / Size       331003 / 1,26 TiB
  VG UUID               yBQGpE-2cMa-3g9B-msCS-BjAP-Cp6q-pESGIl
```

Je peux donc lui ajouter l'espace qu'elle veux.
On va vérifier combien elle a pour le moment :
```shell
$ df -h /home/didine
Sys. de fichiers          Taille Utilisé Dispo Uti% Monté sur
/dev/mapper/vghome-didine    50G     52M   47G   1% /home/didine
```
J'aurais pu vérifier avec lvdisplay :
```shell
$ lvdisplay /dev/mapper/vghome-didine
  --- Logical volume ---
  LV Path                /dev/vghome/didine
  LV Name                didine
  VG Name                vghome
  LV UUID                HDaUgK-ccu0-m4MD-nUN6-0N1R-R0pW-t5Llkg
  LV Write Access        read/write
  LV Creation host, time seedbox, 2015-09-12 21:36:42 -0400
  LV Status              available
  # open                 1
  LV Size                50,00 GiB
  Current LE             19200
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:1
```

On commence par démonter le volume :
```shell
$ umount /home/didine/
```

Puis on peux en vérifier l'intégrité :
```shell
$ e2fsck -f /dev/mapper/vghome-didine
e2fsck 1.42.12 (29-Aug-2014)
Passe 1 : vérification des i-noeuds, des blocs et des tailles
Passe 2 : vérification de la structure des répertoires
Passe 3 : vérification de la connectivité des répertoires
Passe 4 : vérification des compteurs de référence
Passe 5 : vérification de l'information du sommaire de groupe
/dev/mapper/vghome-didine : 14/3276800 fichiers (0.0% non contigus), 251702/13107200 blocs
```

Tous est parfait, on peux donc attaqué le redimensionnement du LV :
```shell
$ lvresize -L +50G /dev/mapper/vghome-didine
  Size of logical volume vghome/didine changed from 50,00 GiB (12800 extents) to 100,00 GiB (25600 extents).
  Logical volume didine successfully resized
```

Par contre ce n'est pas fini, car dans ce cas, le fs fait toujours 50Go, seul le LV à été redimensionner, il faut redimensionner également le FS :
```shell
$ resize2fs /dev/mapper/vghome-didine
resize2fs 1.42.12 (29-Aug-2014)
En train de redimensionner le système de fichiers sur /dev/mapper/vghome-didine à 26214400 (4k) blocs.
Le système de fichiers sur /dev/mapper/vghome-didine a maintenant une taille de 26214400 blocs (4k).
```

On peux maintenant remonté la partition :
```shell
$ mount /dev/mapper/vghome-didine /home/didine/
```

et on vérifie l'espace :
```shell
$ df -h /home/didine/
Sys. de fichiers          Taille Utilisé Dispo Uti% Monté sur
/dev/mapper/vghome-didine    99G     60M   94G   1% /home/didine
```

Et voila le travail.


### Suppression de l'espace disque
Didine me dit qu'elle a supprimer quelques vidéos de son chat, et dit que en fait 75Go aurait largement suffit.
Puisque je n'aime pas avoir de l'espace non utilisé (c'est pas vrai, mais on va dire que si), je vais rétrécir sa partition.

Ceci est plus risqué que l'agrandissement, nous allons donc utilisé une méthode qui limite ces risques, mais il faut qu'il reste au moins 10% d'espaces par rapport a la taille voulu.

On démonte de nouveau sa partition :
```shell
$ umount /home/didine/
```

On revérifie l'intégrité des données :
```shell
$ e2fsck -f /dev/mapper/vghome-didine
e2fsck 1.42.12 (29-Aug-2014)
Passe 1 : vérification des i-noeuds, des blocs et des tailles
Passe 2 : vérification de la structure des répertoires
Passe 3 : vérification de la connectivité des répertoires
Passe 4 : vérification des compteurs de référence
Passe 5 : vérification de l'information du sommaire de groupe
/dev/mapper/vghome-didine : 14/6553600 fichiers (0.0% non contigus), 459352/26214400 blocs
```

Dans mon cas, didine veut 75Go, pour évité les risques je vais redimensionner le FS à 70Go dans un 1er temps :
```shell
$ resize2fs -p /dev/mapper/vghome-didine 70G
resize2fs 1.42.12 (29-Aug-2014)
En train de redimensionner le système de fichiers sur /dev/mapper/vghome-didine à 18350080 (4k) blocs.
Début de la passe 3 (max = 800)
Examen de la table d'i-noeuds XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Le système de fichiers sur /dev/mapper/vghome-didine a maintenant une taille de 18350080 blocs (4k).
```

Puis on peut enfin redimensionner le LV :
```shell
$ lvresize -L 75G /dev/mapper/vghome-didine
  WARNING: Reducing active logical volume to 75,00 GiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce didine? [y/n]: y
  Size of logical volume vghome/didine changed from 100,00 GiB (25600 extents) to 75,00 GiB (19200 extents).
  Logical volume didine successfully resized
```

Comme vous pouvez le voir, j'ai utilisé cette fois ci une taille absolu (-L 75G), mais j'aurais pu dans ce cas utilisé également -L -25G (Comme tous a l'heure avec +50G).

Puis je redimensionne le fs :
```shell
$ resize2fs /dev/mapper/vghome-didine
resize2fs 1.42.12 (29-Aug-2014)
En train de redimensionner le système de fichiers sur /dev/mapper/vghome-didine à 19660800 (4k) blocs.
Le système de fichiers sur /dev/mapper/vghome-didine a maintenant une taille de 19660800 blocs (4k).
```

Puis on remonte le volume :
```shell
$ mount /dev/mapper/vghome-didine /home/didine
```

On vérifie la taille :
```shell
$ df -h /home/didine/
Sys. de fichiers          Taille Utilisé Dispo Uti% Monté sur
/dev/mapper/vghome-didine    74G     52M   70G   1% /home/didine
```

Maintenant que c'est fait, j'espère que didine va me foutre la paix ^^.

_Pourquoi devoir redimensionner deux fois le fs_
C'est pour une raison plutôt simple, les outils resize2fs et lvresize peuvent avoir une différence de quelques octect, ou megaoctect au maximum, ce qui pourrait poser des problèmes.
C'est pourquoi il vaut mieux redimensionner le fs un peu en dessous que voulu, pour avoir la marge lors du redimensionnement du lv.
C'est d'ailleurs cet différence, qui fait que le fs fait 74G au lieu de 75G, il doit avoir quelques o voir Mo de différence.
J'espère être clair dans cet explication ^^.

## Suppression d'un LV
Maintenant didine me dit qu'elle ne veux plus d'espace sur mon serveur.

Je vais pas garder son espace, il pourrait servir à quelqu'un d'autre.
Je peux rapidement le supprimer en deux commande.
On commence par démonter le volume :
```shell
$ umount /home/didine/
```

Puis on le supprime :
```shell
$ lvremove /dev/vghome/didine
Do you really want to remove active logical volume didine? [y/n]: y
  Logical volume "didine" successfully removed
```

Et voila, il est supprimé.

Il ne faut pas oublier de supprimer également la ligne dans le fstab :
```shell
/dev/mapper/vghome-didine       /home/didine     ext4    defaults        0       2
```

## Conclusion
Comme vous pouvez le voir, il est plutôt simple de faire des modifications sur un volume logique, mais il faut toutefois respecter les règles de sécurités.
Nous aurions pu créé le swap sur le VG également, mais le principe reste le même.

Donc voila, a vous de jouer maintenant.

## Contribution
Toute contribution est la bienvenue.  
N'hésitez pas à contribuer aux Tutoriels, ajout d'information, correction de fautes (et il y en a), amélioration etc ...  
Ça se passe [ici](https://github.com/xataz/Tutoriels)  

## Questions
Toute question sur la [discussion](https://mondedie.fr/d/7149) ou sur [github](https://github.com/xataz/Tutoriels/issues)