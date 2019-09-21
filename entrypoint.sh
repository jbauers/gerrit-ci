#!/bin/bash -e

mkdir -p "/home/gerrit"
chown -R gerrit:gerrit "/var/gerrit" "/home/gerrit"
sudo -i -u gerrit bash << EOF
if [ ! -d /home/gerrit/.ssh ]; then
  mkdir -p /home/gerrit/.ssh
  ssh-keygen -b 2048 -t rsa -f /home/gerrit/.ssh/id_rsa -q -N ""
fi
if [ ! -d /var/gerrit/git/All-Projects.git ] || [ "$1" == "init" ]
then
  echo "Initializing Gerrit site ..."
  java -jar /var/gerrit/bin/gerrit.war init --batch --install-all-plugins -d /var/gerrit
  /setup.sh
  java -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
  git config -f /var/gerrit/etc/gerrit.config --add container.javaOptions "-Djava.security.egd=file:/dev/./urandom"
fi

git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "${CANONICAL_WEB_URL:-http://$HOSTNAME}"

if [ "$1" != "init" ]
then
  echo "Running Gerrit ..."
  exec /var/gerrit/bin/gerrit.sh run
fi
EOF
