FROM debian:bullseye-slim

ENV TZ="Asia/Ho_Chi_Minh"

RUN apt update -y && apt install -y wget curl vim git iproute2 \
  autoconf automake libtool make devscripts g++ libncurses5-dev libjpeg-dev \
  pkg-config flac libgdbm-dev libdb-dev equivs mlocate dpkg-dev libpq-dev \
  liblua5.4-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev \
  libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev \
  libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev \
  libavformat-dev libswscale-dev libvlc-dev python3-distutils libhiredis-dev libvpx6 swig4.0 cmake uuid-dev

RUN cd /usr/src && git clone https://github.com/signalwire/libks.git libks \
  && cd libks && git reset --hard 607b4b34251400d9531e02a6612c32d2ab66ca95 \
  && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 \
  && make && make install && export C_INCLUDE_PATH=/usr/include/libks

RUN cd /usr/src && git clone https://github.com/freeswitch/sofia-sip.git \
  sofia && cd sofia && ./autogen.sh && ./configure && make && make install

RUN cd /usr/src && git clone https://github.com/freeswitch/spandsp.git spandsp \
  && cd spandsp && git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4 \
  && sh autogen.sh && ./configure && make && make install && ldconfig

RUN cd /usr/src && git clone https://github.com/warmcat/libwebsockets.git websockets \
  && cd websockets/cmake && mkdir -p build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX:PATH=/usr ../.. \
  && make && make install && export CPLUS_INCLUDE_PATH=/usr/include/libwebsockets

# for v8
RUN apt install -y libncurses5
# for kafka
RUN apt install -y librdkafka-dev libz-dev
# for mariadb
RUN apt install -y libmariadb-dev
# for ldap
RUN apt install -y libldap2-dev

RUN cd /usr/src && wget http://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.9.-release.zip \
  && unzip freeswitch-1.10.9.-release.zip && mv freeswitch-1.10.9.-release freeswitch

RUN echo "" > /usr/src/freeswitch/cluecon.tmpl && echo "" > /usr/src/freeswitch/cluecon_small.tmpl \
  echo "" > /usr/src/freeswitch/cluecon2_small.tmpl && echo "" > /usr/src/freeswitch/cluecon2.tmpl

COPY src/switch_rtp.c /usr/src/freeswitch/src/switch_rtp.c
COPY src/switch_xml.c /usr/src/freeswitch/src/switch_xml.c
COPY src/mod_audio_fork /usr/src/freeswitch/src/mod/applications/mod_audio_fork
COPY src/mod_event_kafka /usr/src/freeswitch/src/mod/event_handlers/mod_event_kafka
COPY src/mod_event_redis /usr/src/freeswitch/src/mod/event_handlers/mod_event_redis

COPY src/patches /tmp/patches

RUN patch /usr/src/freeswitch/Makefile.am /tmp/patches/Makefile.patch
RUN patch /usr/src/freeswitch/modules.conf /tmp/patches/modules.patch
RUN patch -R /usr/src/freeswitch/configure.ac /tmp/patches/configure.patch
RUN patch /usr/src/freeswitch/src/mod/languages/mod_lua/mod_lua.cpp /tmp/patches/mod_lua.patch
RUN patch /usr/src/freeswitch/src/include/switch_types.h /tmp/patches/switch_types.patch
RUN patch -R /usr/src/freeswitch/src/switch_core.c /tmp/patches/switch_core.patch

RUN echo 'const char *cc = "", *cc_s = "";' > /usr/src/freeswitch/src/include/cc.h
RUN echo 'const char *cc = "", *cc_s = "";' > /usr/src/freeswitch/libs/esl/src/include/cc.h

RUN cd /usr/src/freeswitch && autoreconf -f -i \
  && ./configure -C --prefix=/usr --localstatedir=/var \
  --sysconfdir=/etc --with-openssl --with-lws=yes \
  --enable-portable-binary --enable-core-pgsql-support --disable-dependency-tracking

COPY src/sounds/* /usr/share/freeswitch/
RUN cd /usr/share/freeswitch/ && cat sounds.tar.gz.* | tar xzvf - && rm -rf sounds.tar.gz.*

RUN cd /usr/src/freeswitch && make && make install

RUN apt autoclean && rm -rf /usr/src/libks && rm -rf /tmp/* \
  && rm -rf /usr/src/spandsp && rm -rf /usr/src/websockets \
  && rm -rf /usr/src/sofia && rm -rf /usr/src/freeswitch-1.10.9.-release.zip \
  && rm -rf /usr/src/freeswitch/freeswitch-sounds*

COPY test/*.lua /usr/share/freeswitch/scripts/
COPY test/*.xml /etc/freeswitch/autoload_configs/

VOLUME ["/etc/freeswitch", "/var/lib/freeswitch", "/usr/share/freeswitch", "/opt/freeswitch"]

CMD tail -f /dev/null