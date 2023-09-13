#!/bin/bash

echo "########## Installing common"
apt install -y wget curl git iproute2 mlocate

echo "########## Installing build tools"
apt install -y autoconf automake libtool make devscripts g++ pkg-config swig4.0 cmake uuid-dev dpkg-dev

echo "########## Installing dependencies"
apt install -y libncurses5-dev libjpeg-dev flac libgdbm-dev libdb-dev equivs libpq-dev \
  liblua5.4-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev \
  libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev \
  libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev \
  libavformat-dev libswscale-dev libvlc-dev python3-distutils libhiredis-dev

apt install -y librdkafka-dev libz-dev #for kafka
apt install -y libmariadb-dev #for mysql
apt install -y libldap2-dev #for ldap

#for sofia
cd /usr/src && git clone https://github.com/freeswitch/sofia-sip.git \
  sofia && cd sofia && ./autogen.sh && ./configure && make && make install

#for audio fork
cd /usr/src && git clone https://github.com/warmcat/libwebsockets.git websockets \
  && cd websockets/cmake && mkdir -p build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX:PATH=/usr ../.. \
  && make && make install && export CPLUS_INCLUDE_PATH=/usr/include/libwebsockets \
  && rm -rf /usr/src/websockets

cd /usr/src && git clone https://github.com/signalwire/libks.git libks && cd libks \
  && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 \
  && make && make install && export C_INCLUDE_PATH=/usr/include/libks/libks2 \
  && rm -rf /usr/src/libks

cd /usr/src && git clone https://github.com/freeswitch/spandsp.git spandsp \
  && cd spandsp && git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4 \
  && sh autogen.sh && ./configure && make && make install && ldconfig && /usr/src/spandsp

cd /usr/src && wget http://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.10.-release.zip \
  && unzip freeswitch-1.10.10.-release.zip && mv freeswitch-1.10.10.-release freeswitch \
  && rm -rf /usr/src/freeswitch-1.10.10.-release.zip

mv /tmp/mods/mod_audio_fork /usr/src/freeswitch/src/mod/applications/mod_audio_fork
mv /tmp/mods/mod_event_kafka /usr/src/freeswitch/src/mod/event_handlers/mod_event_kafka

echo 'const char *cc = "", *cc_s = "";' > /usr/src/freeswitch/src/include/cc.h
echo 'const char *cc = "", *cc_s = "";' > /usr/src/freeswitch/libs/esl/src/include/cc.h
echo '' > /usr/src/freeswitch/cluecon.tmpl && echo '' > /usr/src/freeswitch/cluecon_small.tmpl
echo '' > /usr/src/freeswitch/cluecon2_small.tmpl && echo '' > /usr/src/freeswitch/cluecon2.tmpl

patch /usr/src/freeswitch/configure.ac /tmp/patches/configure.patch
patch /usr/src/freeswitch/modules.conf /tmp/patches/modules.patch
patch /usr/src/freeswitch/src/switch_xml.c /tmp/patches/switch_xml.patch
patch /usr/src/freeswitch/src/switch_core.c /tmp/patches/switch_core.patch
patch /usr/src/freeswitch/src/include/switch_types.h /tmp/patches/switch_types.patch
#
patch /usr/src/freeswitch/src/mod/languages/mod_lua/mod_lua.cpp /tmp/patches/mod_lua.patch

cd /usr/src/freeswitch && autoreconf -f -i \
  && ./configure -C \
  --prefix=/usr/local/freeswitch \
  --localstatedir=/var --libdir=/var/lib \
  --sysconfdir=/etc --with-openssl --with-lws --disable-fhs \
  --enable-portable-binary --enable-core-pgsql-support --disable-dependency-tracking

cd /usr/src/freeswitch && make && make install