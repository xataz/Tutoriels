# Docker-machine

## Qu'est ce que docker-machine
Docker-machine est un outil qui permet de provisionner des machines (physique ou virtuelle) afin d'y installer le nécessaire pour faire fonctionner docker. Machine permets de provisionner sur virtualbox, mais également beaucoup de service cloud, comme digitalOcean, Azure, Google ou plus générique sur du openstack. Il installera donc docker, mais génère également un certificat ssl, un jeu de clé pour une connexion ssh, et ceux sur de nombreuses distribution GNU/Linux (debian, centos, archlinux ...).

J'ai personnellement commencé à utiliser docker-machine que très récemment, et je trouve cela vraiment indispensable. 

## Installation
Lors de la rédaction de ce chapitre, nous sommes à la version 0.7.0 de docker-machine, les liens indiqués sont donc contextualisé avec cette version. Il se peut donc que lors de votre lecture, une autre version sois sortie, pour le vérifier, vous pouvez regarder sur [les releases du github de docker-machine](https://github.com/docker/machine/releases/).

### Sous Windows
Si vous avez installé boot2docker, docker-machine est déjà pré-installer, sinon l'installation est plutôt simple, il suffit de télécharger l'exécutable :
[docker-machine 32bits](https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-Windows-i386.exe)
[docker-machine 64bits](https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-Windows-x86_64.exe)

Il faut ensuite le placer dans un endroit stratégique, personnellement c:\docker\bin, je vous conseille également de le renommer en docker-machine.exe, car c'est pas très pratique de toujours taper docker-machine-Windows-x86_64.exe.

N'oubliez pas de rajouter l'emplacement de votre binaire dans la variable d'environnement PATH afin qu'il soit utilisable partout.

Et normalement cela fonctionne, on teste :
```shell
$ docker-machine.exe version
docker-machine version 0.7.0, build 61388e9
```

### Sous GNU/Linux et OS X
L'installation est encore plus simple sous un système Unix, il suffit de télécharger le binaire (sauf si vous avez utilisé la toolbox pour OS X) :
```shell
$ wget https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-$(uname -s)-$(uname -m) -O /usr/local/bin/docker-machine
$ chmod +x /usr/local/bin/docker-machine
# $(uname -s) : Permets d'obtenir le type d'OS (linux ou darwin)
# $(uname -m) : Permets d'obtenir l'architecture de l'OS (i386 ou x86_64)
# Exemple sous OS X : docker-machine-$(uname -s)-$(uname -m) devient docker-machine-darwin-x86_64
```

Normalement c'est bon, pour tester :
```shell
$ docker-machine version
docker-machine version 0.7.0, build 61388e9
```

## Utilisation
Nous utiliserons docker-machine seulement avec les driver virtualbox, le principe reste cependant le même avec les autres drivers (cf [liste](https://docs.docker.com/machine/drivers/)).

Pour voir les commandes de docker-machine :
```shell
$ docker-machine
Usage: docker-machine.exe [OPTIONS] COMMAND [arg...]

Create and manage machines running Docker.

Version: 0.7.0, build a650a40

Author:
  Docker Machine Contributors - <https://github.com/docker/machine>

Options:
  --debug, -D                                           Enable debug mode
  -s, --storage-path "C:\Users\xataz\.docker\machine"   Configures storage path [$MACHINE_STORAGE_PATH]
  --tls-ca-cert                                         CA to verify remotes against [$MACHINE_TLS_CA_CERT]
  --tls-ca-key                                          Private key to generate certificates [$MACHINE_TLS_CA_KEY]
  --tls-client-cert                                     Client cert to use for TLS [$MACHINE_TLS_CLIENT_CERT]
  --tls-client-key                                      Private key used in client TLS auth [$MACHINE_TLS_CLIENT_KEY]
  --github-api-token                                    Token to use for requests to the Github API [$MACHINE_GITHUB_API_TOKEN]
  --native-ssh                                          Use the native (Go-based) SSH implementation. [$MACHINE_NATIVE_SSH]
  --bugsnag-api-token                                   BugSnag API token for crash reporting [$MACHINE_BUGSNAG_API_TOKEN]
  --help, -h                                            show help
  --version, -v                                         print the version

Commands:
  active                Print which machine is active
  config                Print the connection config for machine
  create                Create a machine
  env                   Display the commands to set up the environment for the Docker client
  inspect               Inspect information about a machine
  ip                    Get the IP address of a machine
  kill                  Kill a machine
  ls                    List machines
  provision             Re-provision existing machines
  regenerate-certs      Regenerate TLS Certificates for a machine
  restart               Restart a machine
  rm                    Remove a machine
  ssh                   Log into or run a command on a machine with SSH.
  scp                   Copy files between machines
  start                 Start a machine
  status                Get the status of a machine
  stop                  Stop a machine
  upgrade               Upgrade a machine to the latest version of Docker
  url                   Get the URL of a machine
  version               Show the Docker Machine version or a machine docker version
  help                  Shows a list of commands or help for one command

Run 'docker-machine.exe COMMAND --help' for more information on a command.
```

Comme on peut le voir, les commandes sont toujours similaires à compose ou docker.
Si vous êtes sous windows, installer avec docker-toolbox, vous devriez déjà avoir une machine, pour vérifier, faites :
```shell
$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
mydocker   -        generic      Running   tcp://192.168.1.201:2376            v1.10.3
swarm      -        virtualbox   Running   tcp://192.168.99.100:2376           v1.11.0
```
Sinon, nous y reviendrons.

### Créer une machine docker
Comme dit précedemment nous utiliserons virtualbox, nous allons donc créer notre machine avec `docker-machine create`.
Pour voir les arguments possible à `create` il suffit de faire :
```shell
$ docker-machine create
Usage: docker-machine create [OPTIONS] [arg...]

Create a machine

Description:
   Run 'C:\Program Files\Docker Toolbox\docker-machine.exe create --driver name' to include the create flags for that driver in the help text.

Options:

   --driver, -d "none"                                                                                  Driver to create machine with. [$MACHINE_DRIVER]
   --engine-install-url "https://get.docker.com"                                                        Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]
   --engine-opt [--engine-opt option --engine-opt option]                                               Specify arbitrary flags to include with the created engine in the form flag=value
   --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option]     Specify insecure registries to allow with the created engine
   --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option]           Specify registry mirrors to use [$ENGINE_REGISTRY_MIRROR]
   --engine-label [--engine-label option --engine-label option]                                         Specify labels for the created engine
   --engine-storage-driver                                                                              Specify a storage driver to use with the engine
   --engine-env [--engine-env option --engine-env option]                                               Specify environment variables to set in the engine
   --swarm                                                                                              Configure Machine with Swarm
   --swarm-image "swarm:latest"                                                                         Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]
   --swarm-master                                                                                       Configure Machine to be a Swarm master
   --swarm-discovery                                                                                    Discovery service to use with Swarm
   --swarm-strategy "spread"                                                                            Define a default scheduling strategy for Swarm
   --swarm-opt [--swarm-opt option --swarm-opt option]                                                  Define arbitrary flags for swarm
   --swarm-host "tcp://0.0.0.0:3376"                                                                    ip/socket to listen on for Swarm master
   --swarm-addr                                                                                         addr to advertise for Swarm (default: detect and use the machine IP)
   --swarm-experimental                                                                                 Enable Swarm experimental features
   --tls-san [--tls-san option --tls-san option]                                                        Support extra SANs for TLS certs
```

Et plus particulièrement pour le driver virtualbox :
```shell
$ docker-machine create -d virtualbox --help
Usage: docker-machine create [OPTIONS] [arg...]

Create a machine

Description:
   Run 'C:\Program Files\Docker Toolbox\docker-machine.exe create --driver name' to include the create flags for that driver in the help text.

Options:

   --driver, -d "none"                                                                                  Driver to create machine with. [$MACHINE_DRIVER]
   --engine-env [--engine-env option --engine-env option]                                               Specify environment variables to set in the engine
   --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option]     Specify insecure registries to allow with the created engine
   --engine-install-url "https://get.docker.com"                                                        Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]
   --engine-label [--engine-label option --engine-label option]                                         Specify labels for the created engine
   --engine-opt [--engine-opt option --engine-opt option]                                               Specify arbitrary flags to include with the created engine in the form flag=value
   --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option]           Specify registry mirrors to use [$ENGINE_REGISTRY_MIRROR]
   --engine-storage-driver                                                                              Specify a storage driver to use with the engine
   --swarm                                                                                              Configure Machine with Swarm
   --swarm-addr                                                                                         addr to advertise for Swarm (default: detect and use the machine IP)
   --swarm-discovery                                                                                    Discovery service to use with Swarm
   --swarm-experimental                                                                                 Enable Swarm experimental features
   --swarm-host "tcp://0.0.0.0:3376"                                                                    ip/socket to listen on for Swarm master
   --swarm-image "swarm:latest"                                                                         Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]
   --swarm-master                                                                                       Configure Machine to be a Swarm master
   --swarm-opt [--swarm-opt option --swarm-opt option]                                                  Define arbitrary flags for swarm
   --swarm-strategy "spread"                                                                            Define a default scheduling strategy for Swarm
   --tls-san [--tls-san option --tls-san option]                                                        Support extra SANs for TLS certs
   --virtualbox-boot2docker-url                                                                         The URL of the boot2docker image. Defaults to the latest available version [$VIRTUALBOX_BOOT2DOCKER_URL]
   --virtualbox-cpu-count "1"                                                                           number of CPUs for the machine (-1 to use the number of CPUs available) [$VIRTUALBOX_CPU_COUNT]
   --virtualbox-disk-size "20000"                                                                       Size of disk for host in MB [$VIRTUALBOX_DISK_SIZE]
   --virtualbox-host-dns-resolver                                                                       Use the host DNS resolver [$VIRTUALBOX_HOST_DNS_RESOLVER]
   --virtualbox-hostonly-cidr "192.168.99.1/24"                                                         Specify the Host Only CIDR [$VIRTUALBOX_HOSTONLY_CIDR]
   --virtualbox-hostonly-nicpromisc "deny"                                                              Specify the Host Only Network Adapter Promiscuous Mode [$VIRTUALBOX_HOSTONLY_NIC_PROMISC]
   --virtualbox-hostonly-nictype "82540EM"                                                              Specify the Host Only Network Adapter Type [$VIRTUALBOX_HOSTONLY_NIC_TYPE]
   --virtualbox-import-boot2docker-vm                                                                   The name of a Boot2Docker VM to import [$VIRTUALBOX_BOOT2DOCKER_IMPORT_VM]
   --virtualbox-memory "1024"                                                                           Size of memory for host in MB [$VIRTUALBOX_MEMORY_SIZE]
   --virtualbox-nat-nictype "82540EM"                                                                   Specify the Network Adapter Type [$VIRTUALBOX_NAT_NICTYPE]
   --virtualbox-no-dns-proxy                                                                            Disable proxying all DNS requests to the host [$VIRTUALBOX_NO_DNS_PROXY]
   --virtualbox-no-share                                                                                Disable the mount of your home directory [$VIRTUALBOX_NO_SHARE]
   --virtualbox-no-vtx-check                                                                            Disable checking for the availability of hardware virtualization before the vm is started [$VIRTUALBOX_NO_VTX_CHECK]
```

Bon maintenant que nous avons les arguments, nous pouvons créer notre machine :
```shell
$ docker-machine create -d virtualbox --virtualbox-cpu-count "2" --virtualbox-memory "2048" --virtualbox-disk-size "25000" tutoriel
Running pre-create checks...
Creating machine...
(tutoriel) Copying C:\Users\xataz\.docker\machine\cache\boot2docker.iso to C:\Users\xataz\.docker\machine\machines\tutoriel\boot2docker.iso...
(tutoriel) Creating VirtualBox VM...
(tutoriel) Creating SSH key...
(tutoriel) Starting the VM...
(tutoriel) Check network to re-create if needed...
(tutoriel) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: C:\Program Files\Docker Toolbox\docker-machine.exe env tutoriel
```

Nous avons donc créé notre machine, comme nous pouvons le vérifier :
```shell
$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
mydocker   -        generic      Running   tcp://192.168.1.201:2376            v1.10.3
tutoriel   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.11.0
```

### Utilisons notre machine
Creer une machine c'est bien, mais l'utiliser c'est mieux.

Si nous tentons de lister les images par exemple, nous avons une erreur (ici sous windows) :
```shell
$ docker images
An error occurred trying to connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.23/images/json: open //./pipe/docker_engine: Le fichier spécifié est introuvable.
```

Pour ce faire il faut indiqué à docker sur qu'elle machine ce connecter, comme ceci :
```shell
$ docker --tlsverify -H tcp://192.168.99.100:2376 --tlscacert=/c/Users/xataz/.docker/machine/machines/tutoriel/ca.pem --tlscert=/c/Users/xataz/.docker/machine/machines/tutoriel/cert.pem --tlskey=/c/Users/xataz/.docker/machine/machines/tutoriel/key.pem info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 1.11.0
Storage Driver: aufs
 Root Dir: /mnt/sda1/var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 0
 Dirperm1 Supported: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: host bridge null
Kernel Version: 4.1.19-boot2docker
Operating System: Boot2Docker 1.11.0 (TCL 7.0); HEAD : 32ee7e9 - Wed Apr 13 20:06:49 UTC 2016
OSType: linux
Architecture: x86_64
CPUs: 2
Total Memory: 1.955 GiB
Name: tutoriel
ID: ZYFO:VNOS:UWNZ:LKHI:WC7A:D2XC:RFKD:GAMN:VF42:GI5Y:D27G:HSIK
Docker Root Dir: /mnt/sda1/var/lib/docker
Debug mode (client): false
Debug mode (server): true
 File Descriptors: 12
 Goroutines: 30
 System Time: 2016-04-20T18:03:14.189404964Z
 EventsListeners: 0
Registry: https://index.docker.io/v1/
Labels:
 provider=virtualbox
```

Admettez le, c'est plutôt chiant à faire, nous avons une autre méthode, qui consiste à "sourcer" les informations de la machine, de mettre ceci en variable d'environnement avec l'option `env` :
```shell
$ docker-machine env tutoriel
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="C:\Users\xataz\.docker\machine\machines\tutoriel"
export DOCKER_MACHINE_NAME="tutoriel"
# Run this command to configure your shell:
# eval $("C:\Program Files\Docker Toolbox\docker-machine.exe" env tutoriel)
```

Nous avons ici les différentes information pour pouvoir si connecter, et même la commande à taper :
```shell
$ eval $("C:\Program Files\Docker Toolbox\docker-machine.exe" env tutoriel)
```
*Sous l'invite de commande windows (j'utilise mingw64), la commande sera '@FOR /f "tokens=*" %i IN ('docker-machine env tutoriel') DO @%i', mais elle est également indiqué via la commande.*

Et c'est tout, nous pouvons tester :
```shell
$ docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 1.11.0
Storage Driver: aufs
 Root Dir: /mnt/sda1/var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 0
 Dirperm1 Supported: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge null host
Kernel Version: 4.1.19-boot2docker
Operating System: Boot2Docker 1.11.0 (TCL 7.0); HEAD : 32ee7e9 - Wed Apr 13 20:06:49 UTC 2016
OSType: linux
Architecture: x86_64
CPUs: 2
Total Memory: 1.955 GiB
Name: tutoriel
ID: ZYFO:VNOS:UWNZ:LKHI:WC7A:D2XC:RFKD:GAMN:VF42:GI5Y:D27G:HSIK
Docker Root Dir: /mnt/sda1/var/lib/docker
Debug mode (client): false
Debug mode (server): true
 File Descriptors: 12
 Goroutines: 30
 System Time: 2016-04-20T18:08:33.287063691Z
 EventsListeners: 0
Registry: https://index.docker.io/v1/
Labels:
 provider=virtualbox
```

Simple non ?!
Nous pouvons maintenant utiliser docker comme si on était en local.
```shell
$ docker run -d -P xataz/nginx:1.9
Unable to find image 'xataz/nginx:1.9' locally
1.9: Pulling from xataz/nginx
420890c9e918: Pulling fs layer
49453f6fdf36: Pulling fs layer
14a932cbdb93: Pulling fs layer
179d8f2a0f72: Pulling fs layer
de957a98ee12: Pulling fs layer
4237b3506f00: Pulling fs layer
87aa5a2470bc: Pulling fs layer
e0d4bf63eb3c: Pulling fs layer
179d8f2a0f72: Waiting
de957a98ee12: Waiting
4237b3506f00: Waiting
87aa5a2470bc: Waiting
e0d4bf63eb3c: Waiting
49453f6fdf36: Download complete
420890c9e918: Verifying Checksum
420890c9e918: Pull complete
49453f6fdf36: Pull complete
14a932cbdb93: Verifying Checksum
14a932cbdb93: Download complete
14a932cbdb93: Pull complete
4237b3506f00: Verifying Checksum
4237b3506f00: Download complete
179d8f2a0f72: Verifying Checksum
179d8f2a0f72: Download complete
179d8f2a0f72: Pull complete
87aa5a2470bc: Verifying Checksum
87aa5a2470bc: Download complete
de957a98ee12: Verifying Checksum
de957a98ee12: Download complete
e0d4bf63eb3c: Verifying Checksum
e0d4bf63eb3c: Download complete
de957a98ee12: Pull complete
4237b3506f00: Pull complete
87aa5a2470bc: Pull complete
e0d4bf63eb3c: Pull complete
Digest: sha256:a04aebdf836a37c4b5de9ce32a39ba5fc2535e25c58730e1a1f6bf77ef11fe69
Status: Downloaded newer image for xataz/nginx:1.9
818cebd0bed38966c05730b1b0a02f3a3f48adf0aea5bf52d25da7578bdfee15

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                              NAMES
818cebd0bed3        xataz/nginx:1.9     "tini -- /usr/bin/sta"   15 seconds ago      Up 14 seconds       0.0.0.0:32769->8080/tcp, 0.0.0.0:32768->8443/tcp   hungry_hawking
```

> Attention, les volumes restent locaux à la machine créé, et non à la machine cliente.


### Gérer nos machines
Maintenant que nous avons créé notre machine, il va falloir la gérer, et franchement c'est simpliste.

Commençons par l'arrêter :
```shell
$ docker-machine stop tutoriel
Stopping "tutoriel"...
Machine "tutoriel" was stopped.

$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                        SWARM   DOCKER    ERRORS
mydocker   -        generic      Running   tcp://192.168.1.201:2376           v1.10.3
tutoriel   -        virtualbox   Stopped                                      Unknown
```

Puis nous pouvons la démarrer :
```shell
$ docker-machine start tutoriel
Starting "tutoriel"...
(tutoriel) Check network to re-create if needed...
(tutoriel) Waiting for an IP...
Machine "tutoriel" was started.
Waiting for SSH to be available...
Detecting the provisioner...
Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.

$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
mydocker   -        generic      Running   tcp://192.168.1.201:2376            v1.10.3
tutoriel   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.11.0
```

Il aurait été plus simple de la redémarrer :
```shell
$ docker-machine restart tutoriel
Restarting "tutoriel"...
(tutoriel) Check network to re-create if needed...
(tutoriel) Waiting for an IP...
Waiting for SSH to be available...
Detecting the provisioner...
Restarted machines may have new IP addresses. You may need to re-run the `docker-machine env` command.

$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
mydocker   -        generic      Running   tcp://192.168.1.201:2376            v1.10.3
tutoriel   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.11.0
```

Nous pouvons même mettre à jour docker :
```shell
$ docker-machine upgrade mydocker
Waiting for SSH to be available...
Detecting the provisioner...
Upgrading docker...
Restarting docker...

xataz@DESKTOP-2JR2J0C MINGW64 /
$ docker-machine ls
NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
mydocker   -        generic      Running   tcp://192.168.1.201:2376            v1.11.0
tutoriel   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.11.0
```

Il se peut que le besoin de se connecter en ssh sur la machine se fasse, dans ce cas nous pouvons :
```shell
$ docker-machine ssh tutoriel
                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/
 _                 _   ____     _            _
| |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
| '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
| |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
|_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
Boot2Docker version 1.11.0, build HEAD : 32ee7e9 - Wed Apr 13 20:06:49 UTC 2016
Docker version 1.11.0, build 4dc5990
docker@tutoriel:~$
```

Et enfin nous pouvons la supprimer :
```shell
$ docker-machine stop tutoriel && docker-machine rm tutoriel
Stopping "tutoriel"...
Machine "tutoriel" was stopped.
About to remove tutoriel
Are you sure? (y/n): y
Successfully removed tutoriel

$ docker-machine ls
NAME       ACTIVE   DRIVER    STATE     URL                        SWARM   DOCKER    ERRORS
mydocker   -        generic   Running   tcp://192.168.1.201:2376           v1.11.0
```
