[quote]Pour les réclamations ==> [url]http://mondedie.fr/d/7149[/url][/quote]


[b][size=20] LVM kesako [/size][/b]
LVM (logical volume manager), est un outils permettant la création et la gestion de volume logique (~= partition logique). LVM permets une gestion simplifié de ces volumes.

LVM agit sur plusieurs "couche", représenté sur ce schéma (merci ubuntu-fr ^^) :
[img=Schéma]https://doc.ubuntu-fr.org/_media/lvm.jpg[/img]

Nous avons les volumes physique que l'on appelle PV (Physical Volume), ce sont des partitions ou des disques durs complets.
Ensuite nous avons les groupes de volumes, que l'on appelle VG (Volume Group), ce sont des groupes de PV.
Puis nous avons les volumes logique, que l'on appelle LV (Logical Volume), ce sont les "partitions".

[b]Avantages :[/b]
- Simplifie l’allocation d'espaces disques.

[b]inconvénients :[/b]
- Dans le cas de plusieurs PV dans un VG, si un disque crash, tous est perdu.

[b][size=20] Pré-requis [/size][/b]
On a pas besoin de beaucoup de choses :
- LVM installé (apt-get install lvm2)
- Un peu de temps
- De l'attention, une boulette est vite arrivé
- Un dédié fraichement installé

[b][size=20] Le cas utilisé [/size][/b]
Je prends l'exemple d'un kimsufi, si je ne me trompe pas, le panel de kimsufi ne permets pas de faire une installation avec lvm de base.
Il me semble que le problème est le même chez online.

Mon serveur est de base installé comme ceci :
Device          Start        End    Sectors    Size Type
/dev/sda1          40       2048       2009 1004,5K BIOS boot
/dev/sda2        4096   40962047   40957952   19,5G Linux filesystem
/dev/sda3    40962048 3905974271 3865012224    1,8T Linux filesystem
/dev/sda4  3905974272 3907020799    1046528    511M Linux swap

Le /dev/sda2 étant le root, et le sda3 le home. Si votre partitionnement n'est pas comme ceci, il va falloir passer par la case redimensionnement via le rescue.

Ce tutoriel est réalisé en live, donc tous devrait fonctionner, car ce sont des copiés collés de ce que j'ai réalisé sur mon kimsufi.

Bon, vous êtes prêt ?! on y va !!!


[b][size=20] Préparation du système [/size][/b]
On commence par vérifier la présence de lvm :
[code]
root@seedbox:~# lvm version
  LVM version:     2.02.111(2) (2014-09-01)
  Library version: 1.02.90 (2014-09-01)
  Driver version:  4.27.0
[/code]

C'est cool, c'est installé.
Si ce n'est pas le cas, il faut l'installer :
[code]root@seedbox:~# apt-get install lvm2[/code]


Si vous avez des utilisateurs déjà créé, sauvegardé le contenu des homes, car tous sera supprimé.

Nous allons maintenant démonté le home :
[code]root@seedbox:~# umount /home[/code]
Et directement on va supprimer la ligne dans le fstab :
[code]nano /etc/fstab[/code]
et on supprime la ligne du home, pour moi c'est :
[code]/dev/sda3       /home   ext4    defaults,relatime       1       2[/code]

[b][size=20] Création du PV [/size][/b]
Nous allons créé notre PV sur sda3, c'est plutôt simple :
[code]
root@seedbox:~# pvcreate /dev/sda3
  Physical volume "/dev/sda3" successfully created
[/code]

Et c'est tous.

[b][size=20] Création du VG [/size][/b]
C'est aussi simple de créé un VG :
[code]
root@seedbox:~# vgcreate vghome /dev/sda3
  Volume group "vghome" successfully created
[/code]
Dans cet exemple, je l'ai nommé vghome, c'est un choix arbitraire, j'aurais pu tapé :
[code]vgcreate monVG /dev/sda3[/code]


[b][size=20] Obtenir des informations sur le VG créé [/size][/b]
[code]
root@seedbox:~# vgdisplay vghome
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
[/code]

[b][size=20] Création d'un LV [/size][/b]
Je vais maintenant me créé un LV, c'est la que je défini la taille.
Puisque c'est pour moi, j'ai besoin de 500Go, voici comment je le crée :
[code]
root@seedbox:~# lvcreate -L 500G -n xataz vghome
  Logical volume "xataz" created
[/code]
Pour les options :
-L : Pour choisir la taille
-n : Pour le nom du lv, choix arbitraire, mais logique, c'est pour mon home, je l'appelle donc xataz, question d'organisation.
et on fini par vghome, car je veux qu'il sois sur ce vg (et parce que j'en ai qu'un ^^)


Maintenant il faut formaté celui ci (en ext4) :
[code]
root@seedbox:~# mkfs.ext4 /dev/mapper/vghome-xataz
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
[/code]

Les LVs ce trouvent à deux endroits dans le /dev, nous avons le choix entre :
[code]/dev/mapper/vgname-lvname[/code]
ou
[code]/dev/vgname/lvname[/code]

Pour le fameux 5% de réservé, nous pouvons le supprimer avec :

[code]root@seedbox:~# tune2fs -m 0 /dev/mapper/vghome-xataz
tune2fs 1.42.12 (29-Aug-2014)
Définition du pourcentage de blocs réservés à 0% (0 blocs)[/code]

[b][size=20] Création d'un deuxième LV [/size][/b]
Pendant que j'y suis, je vais créé un VG pour ma soeur (didine), elle n'a pas besoin de 500Go, mais 50go devrait lui suffire, mais avant ceci, je vais vérifier que j'ai assez de place :
[code]
root@seedbox:~# vgdisplay vghome
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
[/code]
On voit qu'il me reste 1,31 To :
[code]Free  PE / Size       343803 / 1,31 TiB[/code]
Je peux donc sans soucis créer la partition pour ma soeurette (en vrai c'est un chieuse) :
[code]
root@seedbox:~# lvcreate -L 50G -n didine vghome
  Logical volume "didine" created
[/code]
et on formate :
[code]
mkfs.ext4 /dev/vghome/didine
[/code]

Puis on supprime les 5% réservé :
[code]root@seedbox:~# tune2fs -m 0 /dev/mapper/vghome-didine
tune2fs 1.42.12 (29-Aug-2014)
Définition du pourcentage de blocs réservés à 0% (0 blocs)[/code]


D’ailleurs didine sera mon cobaye pour la fin de ce tutoriel.

[b][size=20] Montage des partitions [/size][/b]
Puisque nous créons des LV pour nos utilisateurs, nous allons d'abord créer le répertoire pour notre utilisateur :
[code]mkdir -p /home/xataz[/code]

On monte sur le home de l'utilisateur :
[code]root@seedbox:~# mount /dev/mapper/vghome-xataz /home/xataz/[/code]

On crée l'utilisateur :
[code]useradd -M -s /bin/bash xataz[/code]
Ou alors avec le script d'ex_rat, dans n'exécutez pas la commande suivante. 

On change les droits du home :
[code]root@seedbox:~# chown -R xataz:xataz /home/xataz[/code]


Et voila, notre utilisateur à sa propre partition.

Il ne reste plus qu'à écrire tous ceci en dur dans le fstab :
[code]nano /etc/fstab[/code]
et on rajoute ceci :
[code]/dev/mapper/vghome-xataz        /home/xataz     ext4    defaults        0       2[/code]


Je fait de même pour didine en background.

[b][size=20] Redimensionnement d'un LV [/size][/b]
On commence ici le récit fabuleux de "didine la pissouse".

[b] Augmentation de l'espace disque [/b]
Didine ayant fait trop de vidéo de son chat, n'a plus de place, elle me demande donc de lui ajouté 50Go.

Pour commencer, je vérifie que je peux le faire :
[code]
root@seedbox:~# vgdisplay vghome
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
[/code]

Je peux donc lui ajouter l'espace qu'elle veux.
On va vérifier combien elle a pour le moment :
[code]
root@seedbox:~# df -h /home/didine
Sys. de fichiers          Taille Utilisé Dispo Uti% Monté sur
/dev/mapper/vghome-didine    50G     52M   47G   1% /home/didine
[/code]
J'aurais pu vérifier avec lvdisplay :
[code]
root@seedbox:~# lvdisplay /dev/mapper/vghome-didine
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

[/code]

On commence par démonter le volume :
[code]
root@seedbox:~# umount /home/didine/
[/code]

Puis on peux en vérifier l'intégrité :
[code]
root@seedbox:~# e2fsck -f /dev/mapper/vghome-didine
e2fsck 1.42.12 (29-Aug-2014)
Passe 1 : vérification des i-noeuds, des blocs et des tailles
Passe 2 : vérification de la structure des répertoires
Passe 3 : vérification de la connectivité des répertoires
Passe 4 : vérification des compteurs de référence
Passe 5 : vérification de l'information du sommaire de groupe
/dev/mapper/vghome-didine : 14/3276800 fichiers (0.0% non contigus), 251702/13107200 blocs
[/code]

Tous est parfait, on peux donc attaqué le redimensionnement :
[code]
root@seedbox:~# lvresize -L +50G /dev/mapper/vghome-didine
  Size of logical volume vghome/didine changed from 50,00 GiB (12800 extents) to 100,00 GiB (25600 extents).
  Logical volume didine successfully resized
[/code]

Par contre ce n'est pas fini, car dans ce cas, le fs fait toujours 50Go, il faut redimensionner également le FS :
[code]
root@seedbox:~# resize2fs /dev/mapper/vghome-didine
resize2fs 1.42.12 (29-Aug-2014)
En train de redimensionner le système de fichiers sur /dev/mapper/vghome-didine à 26214400 (4k) blocs.
Le système de fichiers sur /dev/mapper/vghome-didine a maintenant une taille de 26214400 blocs (4k).
[/code]

On peux maintenant remonté la partition :
[code]
root@seedbox:~# mount /dev/mapper/vghome-didine /home/didine/
[/code]

et on vérifie l'espace :
[code]
root@seedbox:~# df -h /home/didine/
Sys. de fichiers          Taille Utilisé Dispo Uti% Monté sur
/dev/mapper/vghome-didine    99G     60M   94G   1% /home/didine
[/code]

Et voila le travail.


[b] Suppression de l'espace disque [/b]
Didine me dit qu'elle a supprimer quelques vidéos de sont chat, et dit que en fait 75Go aurait largement suffit.
Puisque je n'aime pas avoir de l'espace non utilisé (c'est pas vrai, mais on va dire que si), je vais rétrécir sa partition.

Ceci est plus risqué que l'agrandissement, nous allons donc utilisé une méthode qui limite ces risques, mais il faut qu'il reste au moins 10% d'espaces par rapport a la taille voulu.

On démonte de nouveau sa partition :
[code]root@seedbox:~# umount /home/didine/[/code]

On revérifie l'intégrité des données :
[code]
root@seedbox:~# e2fsck -f /dev/mapper/vghome-didine
e2fsck 1.42.12 (29-Aug-2014)
Passe 1 : vérification des i-noeuds, des blocs et des tailles
Passe 2 : vérification de la structure des répertoires
Passe 3 : vérification de la connectivité des répertoires
Passe 4 : vérification des compteurs de référence
Passe 5 : vérification de l'information du sommaire de groupe
/dev/mapper/vghome-didine : 14/6553600 fichiers (0.0% non contigus), 459352/26214400 blocs
[/code]

Dans mon cas, didine veut 75Go, pour évité les risques je vais redimensionner le FS à 70Go dans un 1er temps :
[code]
root@seedbox:~# resize2fs -p /dev/mapper/vghome-didine 70G
resize2fs 1.42.12 (29-Aug-2014)
En train de redimensionner le système de fichiers sur /dev/mapper/vghome-didine à 18350080 (4k) blocs.
Début de la passe 3 (max = 800)
Examen de la table d'i-noeuds XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Le système de fichiers sur /dev/mapper/vghome-didine a maintenant une taille de 18350080 blocs (4k).
[/code]

Puis on peut enfin redimensionner le LV :
[code]root@seedbox:~# lvresize -L 75G /dev/mapper/vghome-didine
  WARNING: Reducing active logical volume to 75,00 GiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce didine? [y/n]: y
  Size of logical volume vghome/didine changed from 100,00 GiB (25600 extents) to 75,00 GiB (19200 extents).
  Logical volume didine successfully resized[/code]

Comme vous pouvez le voir, j'ai utilisé cette fois ci une taille absolu (-L 75G), mais j'aurais pu dans ce cas utilisé également -L -25G (Comme tous a l'heure avec +50G).

Puis je redimensionne le fs :
[code]
root@seedbox:~# resize2fs /dev/mapper/vghome-didine
resize2fs 1.42.12 (29-Aug-2014)
En train de redimensionner le système de fichiers sur /dev/mapper/vghome-didine à 19660800 (4k) blocs.
Le système de fichiers sur /dev/mapper/vghome-didine a maintenant une taille de 19660800 blocs (4k).
[/code]

Puis on remonte le volume :
[code]root@seedbox:~# mount /dev/mapper/vghome-didine /home/didine[/code]

On vérifie la taille :
[code]root@seedbox:~# df -h /home/didine/
Sys. de fichiers          Taille Utilisé Dispo Uti% Monté sur
/dev/mapper/vghome-didine    74G     52M   70G   1% /home/didine[/code]

Maintenant que c'est fait, j'espère que didine va me foutre la paix ^^.

[u]Pourquoi devoir redimensionner deux fois le fs[/u]
C'est pour une raison plutôt simple, les outils resize2fs et lvresize peuvent avoir une différence de quelques octect, ou megaoctect au maximum, ce qui pourrait poser des problèmes.
C'est pourquoi il vaut mieux redimensionner le fs un peu en dessous que voulu, pour avoir la marge lors du redimensionnement du lv.
C'est d'ailleurs cet différence, qui fait que le fs fait 74G au lieu de 75G, il doit avoir quelques o voir Mo de différence.
J'espère être clair dans cet explication ^^.

[b][size=20] Suppression d'un LV [/size][/b]
Maintenant didine me dit qu'elle ne veux plus d'espace sur mon serveur.

Je vais pas garder son espace, il pourrait servir à quelqu'un d'autre.
Je peux rapidement le supprimer en deux commande.
On commence par démonter le volume :
[code]root@seedbox:~# umount /home/didine/[/code]

Puis on le supprime :
[code]
root@seedbox:~# lvremove /dev/vghome/didine
Do you really want to remove active logical volume didine? [y/n]: y
  Logical volume "didine" successfully removed
[/code]

Et voila, il est supprimé.

Il ne faut pas oublier de supprimer également la ligne dans le fstab :
[code]/dev/mapper/vghome-didine       /home/didine     ext4    defaults        0       2[/code]

[b][size=20] Conclusion [/size][/b]
Comme vous pouvez le voir, il est plutôt simple de faire des modifications sur un volume logique, mais il faut toutefois respecter les règles de sécurités.
Nous aurions pu créé le swap sur le VG également, mais le principe reste le même.



Donc voila, a vous de jouer maintenant.