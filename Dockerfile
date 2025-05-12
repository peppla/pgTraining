FROM rockylinux:8

RUN \
  dnf -y update \
  && dnf install -y wget \
  && dnf install -y curl \
  && dnf install -y jq \
  && dnf install -y vim \
  && dnf install -y sudo \
  && dnf install -y gnupg \
  && dnf install -y openssh-server \
  && dnf install -y openssh-clients \
  && dnf install -y procps-ng \
  && dnf install -y net-tools \
  && dnf install -y iproute \
  && dnf install -y less \
  && dnf install -y watchdog \
  && dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
  && dnf -qy module disable postgresql \
  && dnf install -y postgresql16-server \
  && dnf install -y postgresql16-contrib \
  && dnf install -y epel-release \
  && dnf install -y libssh2 \
  && dnf install -y pgbackrest \
  && dnf install -y pgbouncer \
  && dnf install -y patroni-etcd \
  && dnf install -y haproxy \
  && dnf install -y pg_repack_16 \
  && dnf install -y pg_top \
  && dnf install -y pg_activity \
  && dnf install -y https://www.pgpool.net/yum/rpms/4.5/redhat/rhel-8-x86_64/pgpool-II-release-4.5-1.noarch.rpm \
  && dnf install -y https://www.pgpool.net/yum/rpms/4.5/redhat/rhel-8-x86_64/pgpool-II-pg16-extensions-4.5.1-1pgdg.rhel8.x86_64.rpm \
 # && dnf install -y pgpool-II-pg16-extensions pgpool-II-pg16 \
  && dnf install -y repmgr_16

RUN mkdir -p /pgdata/16/
RUN mkdir -p /pgha/{config,pgbackrest,data/{etcd,postgres}}

RUN chown -R postgres:postgres /pgdata
RUN chown -R postgres:postgres /pgha
RUN chmod 0700 /pgdata
RUN chmod 0700 /pgha

COPY pg_custom.conf /
COPY pg_hba.conf /
COPY pgsqlProfile /
COPY photos.sql /
COPY id_rsa /
COPY id_rsa.pub /
COPY authorized_keys /

EXPOSE 22 80 443 5432 2379 2380 8432 5000 5001 8008 9999 9898

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh 

SHELL ["/bin/bash", "-c"]
ENTRYPOINT /entrypoint.sh

