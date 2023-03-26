FROM debian:bullseye-slim

ENV TZ="Asia/Ho_Chi_Minh"

RUN apt update -y && apt install -y wget curl vim git \
  autoconf automake libtool make g++ libncurses5-dev libjpeg-dev \
  pkg-config flac libgdbm-dev libdb-dev equivs mlocate dpkg-dev libpq-dev \
  liblua5.4-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev \
  devscripts libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev \
  libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev \
  libavformat-dev libswscale-dev libvlc-dev python3-distutils libhiredis-dev swig4.0 cmake uuid-dev

RUN cd /usr/src && git clone https://github.com/signalwire/libks.git libks && cd libks \
  && cmake . && make && make install && export C_INCLUDE_PATH=/usr/include/libks

RUN cd /usr/src \
  && wget https://github.com/freeswitch/sofia-sip/archive/refs/tags/v1.13.7.zip && unzip v1.13.7.zip \
  && mv sofia-sip-1.13.7 sofia-sip && cd sofia-sip && sh autogen.sh && ./configure && make && make install

RUN cd /usr/src && git clone https://github.com/freeswitch/spandsp.git spandsp \
  && cd spandsp && sh autogen.sh && ./configure && make && make install && ldconfig

RUN /bin/sh -c cd /usr/src && git clone https://github.com/warmcat/libwebsockets.git websockets && cd websockets \
  && mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install

RUN cd /usr/src && git clone https://github.com/grpc/grpc.git \
  && cd grpc && git checkout c66d2cc && git submodule update --init --recursive \
  && mkdir -p cmake/build && cd cmake/build && cmake -DBUILD_SHARED_LIBS=ON \
    -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../..

RUN cd /usr/src && wget http://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.8.-release.zip \
  && unzip freeswitch-1.10.8.-release.zip && mv freeswitch-1.10.8.-release freeswitch

RUN echo "" > /usr/src/freeswitch/cluecon.tmpl
RUN echo "" > /usr/src/freeswitch/cluecon_small.tmpl
RUN echo "" > /usr/src/freeswitch/cluecon2_small.tmpl
RUN echo "" > /usr/src/freeswitch/cluecon2.tmpl

RUN echo 'const char *cc = "", *cc_s = "";' > /usr/src/freeswitch/src/include/cc.h
RUN echo 'const char *cc = "", *cc_s = "";' > /usr/src/freeswitch/libs/esl/src/include/cc.h

COPY ./src/switch_xml.c /usr/src/freeswitch/src/switch_xml.c
COPY ./src/switch_core.c /usr/src/freeswitch/src/switch_core.c
COPY ./src/libs/fs_cli.c /usr/src/freeswitch/libs/esl/fs_cli.c

RUN fs_mod_file='/usr/src/freeswitch/modules.conf' && fs_configure_file='/usr/src/freeswitch/configure.ac' &&\
  sed -i $fs_mod_file -e s:'#applications/mod_avmd:applications/mod_avmd:' && \
  sed -i $fs_mod_file -e s:'#applications/mod_callcenter:applications/mod_callcenter:' && \
  sed -i $fs_mod_file -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:' && \
  sed -i $fs_mod_file -e s:'#applications/mod_memcache:applications/mod_memcache:' && \
  sed -i $fs_mod_file -e s:'#applications/mod_hiredis:applications/mod_hiredis:' && \
  sed -i $fs_mod_file -e s:'#applications/mod_nibblebill:applications/mod_nibblebill:' && \
  sed -i $fs_mod_file -e s:'#applications/mod_curl:applications/mod_curl:' && \
  sed -i $fs_mod_file -e s:'#event_handlers/mod_json_cdr:event_handlers/mod_json_cdr:' && \
  sed -i $fs_mod_file -e s:'#formats/mod_shout:formats/mod_shout:' && \
  sed -i $fs_mod_file -e s:'#formats/mod_pgsql:formats/mod_pgsql:' && \
  sed -i $fs_mod_file -e s:'applications/mod_signalwire:#applications/mod_signalwire:'

RUN cd /usr/src/freeswitch && ./configure -C \
  --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-openssl \
  --enable-portable-binary --enable-core-pgsql-support --disable-dependency-tracking

RUN cd /usr/src/freeswitch && make && make install && make sounds-install moh-install \
  && make hd-sounds-install hd-moh-install && make cd-sounds-install cd-moh-install

RUN mkdir -p /usr/share/freeswitch/sounds/music/default \
  && mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/music/default

RUN apt autoclean && rm -rf /usr/src/libks && rm -rf /usr/src/sofia-sip \
  && rm -rf /usr/src/spandsp && rm -rf /usr/src/websockets && rm -rf /usr/src/grpc

VOLUME ["/etc/freeswitch", "/var/lib/freeswitch", "/usr/share/freeswitch", "/opt/freeswitch"]

CMD tail -f /dev/null