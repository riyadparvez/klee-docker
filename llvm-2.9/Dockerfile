
FROM ubuntu:14.04

MAINTAINER Riyad Parvez <riyad.parvez@gmail.com>

# Setup the toolchain.
ADD install.sh /
RUN chmod +x install.sh
RUN /install.sh

#RUN apt-get update -y && apt-get upgrade -y && \
# apt-get install --no-install-recommends --auto-remove -y git build-essential pkg-config file &&\
# apt-get clean autoclean && apt-get autoremove -y && rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}

ENV HOME /home

# Setup home directory
WORKDIR /home
ENV HOME /home

# ...

CMD ["/bin/bash"]

