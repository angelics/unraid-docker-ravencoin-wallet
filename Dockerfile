# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-16.04

# Define working directory.
WORKDIR /tmp

RUN \
	echo "Adding bitcoin repository..." && \
	add-pkg --virtual build-dependencies \
	software-properties-common \
	&& \
	add-apt-repository ppa:bitcoin/bitcoin && \
    del-pkg build-dependencies && \
	echo "Adding raven-qt dependencies..." && \
	add-pkg \
		tzdata \
		libqt5network5 \
		libqt5widgets5 \
		libzmq5 \
		libboost-filesystem1.58.0 \
		libboost-program-options1.58.0 \
		libboost-thread1.58.0 \
		libboost-chrono1.58.0 \
		libqrencode3 \
		libprotobuf9v5 \
		libdb4.8++ \
		libevent-pthreads-2.0-5 \
		libevent-2.0-5 \
		&& \
	rm -rf /tmp/* /tmp/.[!.]* && \
    # Maximize only the main window.
    sed-patch 's/<application type="normal">/<application type="normal" title="Raven Core - Wallet">/' \
        /etc/xdg/openbox/rc.xml && \
	# Generate and install favicons.
    APP_ICON_URL=https://raw.githubusercontent.com/angelics/unraid-docker-ravencoin-wallet/master/icon.png && \
    install_app_icon.sh "$APP_ICON_URL"
	
# Define download URLs.
ARG RAVENCOIN_VERSION=2.5.0
ARG RAVENCOIN_URL=https://github.com/RavenProject/Ravencoin/archive/v${RAVENCOIN_VERSION}.tar.gz

RUN \
	echo "Make install RavencoinWallet..." && \
	add-pkg --virtual build-dependencies \
		build-essential \
		libtool \
		autotools-dev \
		automake \
		pkg-config \
		libssl-dev \
		libevent-dev \
		bsdmainutils \
		python3 \
		qttools5-dev \
		qttools5-dev-tools \
		libprotobuf-dev \
		protobuf-compiler \
		libzmq3-dev \
		libqrencode-dev \
		libdb4.8-dev \
		libdb4.8++-dev \
		libboost-system-dev \
		libboost-filesystem-dev \
		libboost-chrono-dev \
		libboost-program-options-dev \
		libboost-test-dev \
		libboost-thread-dev \
		curl \
		ca-certificates \
		&& \
	mkdir ravencoin && \
	echo "Download RavencoinWallet..." && \
	curl -sS -L ${RAVENCOIN_URL} | tar -xz --strip 1 -C ravencoin && \
	cd ravencoin && \
	./autogen.sh && \
	./configure --enable-cxx \
				--disable-shared \
				--with-gui \
				--disable-tests \
				--disable-bench \
				--with-pic CXXFLAGS="-fPIC -O2" CPPFLAGS="-fPIC -O2" \
				&& \
	make -j4 && \
	make install && \
	strip --strip-unneeded /usr/local/bin/ravend && \
	strip --strip-unneeded /usr/local/bin/raven-qt && \
	strip --strip-unneeded /usr/local/lib/libravenconsensus.a && \
	strip --strip-unneeded /usr/local/bin/raven-cli && \
    echo "Remove unused packages..." && \
    del-pkg build-dependencies && \
    apt-get purge --auto-remove xz-utils -y && \
	rm -rf /tmp/* /tmp/.[!.]*

# Add files
COPY rootfs/ /

# Set environment variables.
ENV	APP_NAME="RavencoinWallet"

# Define mountable directories.
VOLUME ["/storage"]

# Expose port
EXPOSE 8767 18770 8766 18766 