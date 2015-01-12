FROM ubuntu:14.04

MAINTAINER Riyad Parvez <riyad.parvez@gmail.com>

# Setup the toolchain.
# add the setup script to install libevent from source
ADD klee-build.sh /
RUN chmod +x klee-build.sh
RUN /klee-build.sh

#RUN apt-get update -y && apt-get upgrade -y && \
# apt-get install --no-install-recommends --auto-remove -y git build-essential pkg-config file &&\
# apt-get clean autoclean && apt-get autoremove -y && rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}

# Setup home directory
WORKDIR /home
ENV HOME /home

CMD ["/bin/bash"]
