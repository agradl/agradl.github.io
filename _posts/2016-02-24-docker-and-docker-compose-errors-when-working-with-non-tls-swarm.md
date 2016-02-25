---
layout: post
title: docker, docker-compose errors when working with non-TLS swarm
categories: docker
excerpt: The Docker toolbox worked perfectly, until I went to work with our private swarm host.

---

The Docker toolbox for Mac OS-X worked perfectly, until I went to work with our private docker swarm host.

> Error response from daemon: client is newer than server (client API version: 1.22, server API version: 1.20)

As the error suggests, your client is newer than your server. Most suggestions involved simply updating the server. Not too helpful if that decision is out of your control. Luckily if you installed the latest toolbox version, they've introduced a new environment flag to downgrade your api version `export DOCKER_API_VERSION="1.20"` did the trick.

Not so fast.

> An error occurred trying to connect: Get https://your-server:2375/v1.20/containers/json: tls: oversized record received with length 20527

See the problem? Neither did I at first. Those more familiar with docker swarm will realize that port 2375 is for http and 2376 is for https. Our in house swarm doesn't use https yet docker is trying to connect with it. Eventually I get things to work in a new terminal window and discover what the issue is. I was using the terminal opened from the docker toolbox quickstart which helpfully sets some necessary environment variables to connect to the local boot2docker VM using TLS.

`env | grep DOCKER`
> DOCKER_HOST=tcp://your-server:2375
> DOCKER_API_VERSION=1.20
> DOCKER_TLS_VERIFY=1
> DOCKER_CERT_PATH=/Users/agradl/.docker/machine/machines/default
> DOCKER_MACHINE_NAME=default

`unset DOCKER_TLS_VERIFY && unset DOCKER_CERT_PATH` and then I'm back in business. I can `docker ps` like a boss. Now I'm ready to deploy my container to the swarm. `docker-compose -f my-service.yml -p my-service up` to deploy and... deja vu.

> Error response from daemon: client is newer than server (client API version: 1.22, server API version: 1.20)

By this point I'm pretty confused. After some intense googling, I see mention that `docker-compose` is bundled with a separate `docker` binary! Apparently this bundled version doesn't use the `DOCKER_API_VERSION` environment variable. Giving up on the installed versions, I finally give in and just downgrade `docker-compose` using ```curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose```.

Despite all these problems, I was thoroughly impressed with how seamless the toolbox install worked and got me up and running. After downloading it I was creating containers and running a Dockerfile in minutes. Quite a different experience from when I last tried it about a year ago.