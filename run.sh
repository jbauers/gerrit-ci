#!/bin/sh

# Podman
MY_UID=$(id -u)
MY_GID=$(id -g)

docker build -t gerrit .

mkdir -p {cache,git,index,hooks}
sudo cp ci/* hooks/
sudo chown -R ${MY_UID}:${MY_GID} hooks

# selinux, mount with 'z'
docker run -p "8080:8080" \
           -p "29418:29418" \
           -v "${PWD}/git:/var/gerrit/git:z" \
           -v "${PWD}/index:/var/gerrit/index:z" \
           -v "${PWD}/cache:/var/gerrit/cache:z" \
           -v "${PWD}/hooks:/var/gerrit/hooks:z" \
           gerrit
