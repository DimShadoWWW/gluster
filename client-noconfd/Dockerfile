FROM centos

RUN yum --setopt=tsflags=nodocs -y update && \
    yum clean all && \
    yum --setopt=tsflags=nodocs -y install wget attr iputils iproute && \
    wget http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/glusterfs-epel.repo -O /etc/yum.repos.d/glusterfs-epel.repo && \
    wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \
    rpm -ivh epel-release-7-5.noarch.rpm && \
    rm epel-release-7-5.noarch.rpm && \
    yum --setopt=tsflags=nodocs -y install glusterfs && \
    yum clean all

CMD ["/usr/sbin/init"]
