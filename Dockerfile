# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-16.04

# Define software download URLs.
ARG RAVENCOIN_URL=https://github.com/RavenProject/Ravencoin

# Define working directory.
WORKDIR /tmp

### Install RavenCoin
RUN \
	apt-get update && \
	apt-get install -y \
	software-properties-common && \
	add-apt-repository ppa:bitcoin/bitcoin && \
	apt-get update && \
#dependency	
	apt-get install -y \
	build-essential \
	libtool \
	autotools-dev \
	automake \
	pkg-config \
	libssl-dev \
	libevent-dev \
	bsdmainutils \
	python3 \
#Qt5 dependency
	libqt5gui5 \
	libqt5core5a \
	libqt5dbus5 \
	qttools5-dev \
	qttools5-dev-tools \
	libprotobuf-dev \
	protobuf-compiler \
#ZMQ dependency
	libzmq3-dev \
#libqrencode dependency	
	libqrencode-dev \
#libboost dependency
	libboost-system-dev \
	libboost-filesystem-dev \
	libboost-chrono-dev \
	libboost-program-options-dev \
	libboost-test-dev \
	libboost-thread-dev \
#BerkeleyDB dependency
	libdb4.8-dev \
	libdb4.8++-dev \
#git dependency
	git && \
echo "**** Downloading ravencoin... ****" && \
	git clone $RAVENCOIN_URL /ravencoin && \
	cd /ravencoin && \
	./autogen.sh && \
	./configure --enable-cxx --disable-shared --with-gui --with-pic CXXFLAGS="-fPIC -O2" CPPFLAGS="-fPIC -O2" && \
	make && \
	make install && \
	cd / && \
echo "**** cleanup ****" && \
	apt-get clean -y && \
	apt-get autoremove -y && \
	rm -rf \
		/ravencoin \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*
		
# Add files.
COPY rootfs/ /

# Set environment variables.
ENV	APP_NAME="RavencoinWallet" \
	USER_ID=99 \
	GROUP_ID=100 \
	UMASK=0

# Define mountable directories.
VOLUME ["/storage"]