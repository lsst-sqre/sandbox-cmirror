FROM centos:7
MAINTAINER sqre-admin

USER root
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y bzip2

COPY scripts/install_miniconda.sh /root/
ENV MINICONDA_VERSION=4.2.12
RUN chmod a+x /root/install_miniconda.sh && /root/install_miniconda.sh
RUN echo 'PATH=$PATH:/miniconda/bin' > /etc/profile.d/miniconda.sh
RUN /miniconda/bin/pip install conda-mirror==0.7.3

RUN yum clean all

RUN useradd cmirror
USER cmirror

ENTRYPOINT ["/miniconda/bin/conda-mirror"]
