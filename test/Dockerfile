#FROM luongld/fs:1.10.10-builder as builder

FROM debian:bookworm-slim

# COPY --from=builder /usr/local/freeswitch /usr/local/freeswitch
# COPY --from=builder /var/lib/*freeswitch* /usr/lib/
# COPY --from=builder /usr/lib/lib*.so* /usr/lib/
# COPY --from=builder /usr/lib/x86_64-linux-gnu/lib*.so* /usr/lib/
# COPY --from=builder /usr/local/lib/lib*.so* /usr/lib/

# # COPY sounds/* /usr/share/freeswitch/
# # RUN cd /usr/share/freeswitch/ && cat sounds.tar.gz.* | tar xzvf - && rm -rf sounds.tar.gz.*

# VOLUME ["/usr/lib", "/usr/local"]

RUN apt update
RUN apt install -y wget curl git iproute2 mlocate
RUN apt install -y autoconf automake libtool make devscripts g++ pkg-config swig4.0 cmake uuid-dev dpkg-dev
RUN apt install -y libncurses5-dev libjpeg-dev flac libgdbm-dev libdb-dev equivs libpq-dev \
  liblua5.4-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev \
  libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev \
  libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev \
  libavformat-dev libswscale-dev libvlc-dev python3-distutils libhiredis-dev librdkafka-dev \
  libz-dev libmariadb-dev libldap2-dev
RUN apt autoclean && apt autoremove


CMD ["tail", "-f", "/dev/null"]
