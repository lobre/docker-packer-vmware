FROM debian:9

ENV DEBIAN_FRONTEND=noninteractive
ENV PACKER_VERSION=1.3.3
ENV PACKER_SHA256SUM=efa311336db17c0709d5069509c34c35f0d59c63dfb05f61d4572c5a26b563ea

# install required tools
RUN apt-get -y update && \
    apt-get -y install \
        unzip \
        wget \
        build-essential \
        xorg \
        net-tools \
        libxt6 \ 
        libxtst6 \ 
        libxcursor-dev \ 
        libxinerama-dev \
        qemu-utils \
        libxi6 && \
    apt-get -y clean

# install vmware player
RUN wget -O /tmp/vmware-player.bundle \
      https://download3.vmware.com/software/player/file/VMware-Player-14.1.5-10950780.x86_64.bundle && \
    chmod +x /tmp/vmware-player.bundle && \
    /tmp/vmware-player.bundle --eulas-agreed --console --required && \
    rm /tmp/vmware-player.bundle

# install vmware vix
RUN wget -O /tmp/vmware-vix.bundle \
      https://download3.vmware.com/software/player/file/VMware-VIX-1.17.0-6661328.x86_64.bundle && \
    chmod +x /tmp/vmware-vix.bundle && \
    /tmp/vmware-vix.bundle --eulas-agreed --console --required && \
    rm /tmp/vmware-vix.bundle

# add nmap conf
COPY netmap.conf /etc/vmware/netmap.conf

# install packer
RUN PACKER_VERSION=`wget -O- https://releases.hashicorp.com/packer/ 2> /dev/null \
      | fgrep '/packer' \
      | head -1 \
      | sed -r 's/.*packer_([0-9.]+).*/\1/'` && \
    wget -O /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    unzip packer.zip && \
    chmod +x packer && \
    mv packer /usr/local/bin && \
    rm packer.zip

# create user
RUN useradd -ms /bin/bash packer
USER packer

WORKDIR /home/packer
ENTRYPOINT ["/usr/local/bin/packer"]
