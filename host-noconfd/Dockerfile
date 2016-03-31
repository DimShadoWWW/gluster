FROM centos

RUN yum --setopt=tsflags=nodocs -y update && \
    yum clean all && \
    yum --setopt=tsflags=nodocs -y install wget attr iputils iproute && \
    wget http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/glusterfs-epel.repo -O /etc/yum.repos.d/glusterfs-epel.repo && \
    wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \
    rpm -ivh epel-release-7-5.noarch.rpm && \
    rm epel-release-7-5.noarch.rpm && \
    yum --setopt=tsflags=nodocs -y install glusterfs-server && \
    yum clean all && \
    systemctl enable rpcbind.service

EXPOSE 22 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162 49163

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["glusterd"]
