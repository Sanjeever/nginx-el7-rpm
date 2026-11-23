FROM centos:centos7.9.2009@sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d32916d6487418ea4

COPY centos-vault.repo /etc/yum.repos.d/el7-vault.repo
RUN yum -y --disablerepo='*' --enablerepo='el7-vault-*' install \
      ca-certificates curl gcc gnupg2 make openssl openssl-devel pcre2-devel procps-ng \
      redhat-rpm-config rpm-build shadow-utils systemd zlib-devel \
    && yum --disablerepo='*' --enablerepo='el7-vault-*' clean all

COPY build-el7-rpm.sh /usr/local/bin/build-el7-rpm
ENTRYPOINT ["/bin/bash", "/usr/local/bin/build-el7-rpm"]
