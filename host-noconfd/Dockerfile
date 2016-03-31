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
# systemctl enable rpcbind.service && \
#    systemctl enable glusterd.service

EXPOSE 22 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162 49163

ENV GLUSTER_REPLICATION=2 GLUSTER_VOLUME_NAME=gv0 GLUSTER_LOCATION=/var/gluster/store GLUSTER_PUBLIC_IP=1.1.1.1 GLUSTER_PRIVATE_IP=1.1.1.1

# nfs-utils
# RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
# rm -f /lib/systemd/system/multi-user.target.wants/*;\
# rm -f /etc/systemd/system/*.wants/*;\
# rm -f /lib/systemd/system/local-fs.target.wants/*; \
# rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
# rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
# rm -f /lib/systemd/system/basic.target.wants/*;\
# rm -f /lib/systemd/system/anaconda.target.wants/*;


# VOLUME [ “/sys/fs/cgroup” ]


#CMD ["/usr/sbin/init"]

#/usr/sbin/glusterd -p /var/run/glusterd.pid  --log-level $LOG_LEVEL $GLUSTERD_OPTIONS
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["glusterd"]
