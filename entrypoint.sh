#!/bin/bash

if [ ! -f "/pgdata/16/data/PG_VERSION" ]
then
        sudo -u postgres /usr/pgsql-16/bin/initdb -D /pgdata/16/data
        echo "include = 'pg_custom.conf'" >> /pgdata/16/data/postgresql.conf
        cp /pg_custom.conf /pgdata/16/data/
        cp /pg_hba.conf /pgdata/16/data/
        cp /pgsqlProfile /var/lib/pgsql/.pgsql_profile
        cp /photos.sql /pgdata/


	# add ssh keys
	mkdir -p /var/lib/pgsql/.ssh
        cp /id_rsa /var/lib/pgsql/.ssh
        cp /id_rsa.pub /var/lib/pgsql/.ssh
        cp /authorized_keys /var/lib/pgsql/.ssh
        chown -R postgres:postgres /var/lib/pgsql/.ssh
        chmod 0700 /var/lib/pgsql/.ssh
        chmod 0600 /var/lib/pgsql/.ssh/*

        chown postgres:postgres /var/lib/pgsql/.pgsql_profile
        chown postgres:postgres /pgdata/16/data/pg_custom.conf
        chown postgres:postgres /pgdata/16/data/pg_hba.conf
        chown postgres:postgres /pgdata/photos.sql
        sudo -u postgres /usr/pgsql-16/bin/pg_ctl -D /pgdata/16/data start
        sudo -u postgres psql -c "ALTER ROLE postgres PASSWORD 'postgres';"

        if [ -z "$PGSTART" ]
        then
           sudo -u postgres /usr/pgsql-16/bin/pg_ctl -D /pgdata/16/data stop
        else
           sudo -u postgres /usr/pgsql-16/bin/pg_ctl -D /pgdata/16/data restart
        fi
else
        if [ -z "$PGSTART" ]
        then
           sudo -u postgres /usr/pgsql-16/bin/pg_ctl -D /pgdata/16/data start
        fi
fi

if [[ ! -f "/usr/bin/etcd" && ! -f "/usr/bin/etcdctl" && ! -f "/usr/bin/etcdutl" ]]
then
  # Install etcd from google
  ETCD_VER=v3.5.17
  GOOGLE_URL=https://storage.googleapis.com/etcd
  GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
  DOWNLOAD_URL=${GOOGLE_URL}
  rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test
  curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
  rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  /tmp/etcd-download-test/etcd --version
  /tmp/etcd-download-test/etcdctl version
  /tmp/etcd-download-test/etcdutl version
  cp -p /tmp/etcd-download-test/etcd /usr/bin/
  cp -p /tmp/etcd-download-test/etcdctl /usr/bin/
  cp -p /tmp/etcd-download-test/etcdutl /usr/bin/
  cd /tmp
  rm -rf /tmp/etcd-download-test
fi

# Setup some ssh stuff

for ssh_key in rsa ed25519 ecdsa
do
   key_file=/etc/ssh/ssh_host_${ssh_key}_key
   if [ ! -f $key_file ]
   then
     ssh-keygen -t $ssh_key -f $key_file -N ''
   fi
done

echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

/usr/sbin/sshd

rm -f /run/nologin

# /bin/bash better option than the tail -f especially without a supervisor
# consider using dumb_init in the future as a supervisor https://github.com/Yelp/dumb-init
 
TMOUT=0 /bin/bash

#exec tail -f /dev/null
#sleep infinity
