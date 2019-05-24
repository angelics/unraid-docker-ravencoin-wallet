# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-16.04

# Define download URLs.
ARG RAVENCOIN_VERSION=2.2.2
ARG RAVENCOIN_URL=https://github.com/RavenProject/Ravencoin/archive/v${RAVENCOIN_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

### Install RavenCoin
RUN \
	apt-get update && apt-get install -y \
	software-properties-common \
	&& \
	add-apt-repository ppa:bitcoin/bitcoin && \
#dependency
	apt-get update && apt-get install -y \
	build-essential \
	libtool \
	autotools-dev \
	automake \
	pkg-config \
	libssl-dev \
	libevent-dev \
	bsdmainutils \
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
#curl dependency
	curl \
	&& \
echo "**** Downloading ravencoin... ****" && \
	mkdir ravencoin && \
	curl -sS -L ${RAVENCOIN_URL} | tar -xz --strip 1 -C ravencoin && \
	cd ravencoin && \
	./autogen.sh && \
	./configure --enable-cxx --disable-shared --with-gui --with-pic CXXFLAGS="-fPIC -O2" CPPFLAGS="-fPIC -O2" && \
	make && \
	make install && \
	cd / && \
echo "**** cleanup ****" && \
	apt-get clean -y && \
	apt-get autoremove -y && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/* \
		/tmp/.[!.]* \
		/etc/login.defs
	
# Add files
COPY rootfs/ /

# Set environment variables.
ENV	APP_NAME="RavencoinWallet"

# Define mountable directories.
VOLUME ["/storage"]

# Expose port
EXPOSE 8767