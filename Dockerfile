FROM debian:bookworm-slim as builder

ENV TZ="Asia/Ho_Chi_Minh"

RUN apt update -y

COPY scripts /tmp/scripts
COPY patches /tmp/patches
COPY mods /tmp/mods
COPY sounds /tmp/sounds

RUN chmod +x /tmp/scripts/*.sh && /tmp/scripts/installer.sh

# FROM debian:bookworm-slim

# COPY --from=builder /usr/local/freeswitch /usr/local/freeswitch

# COPY sounds/* /usr/share/freeswitch/
# RUN cd /usr/share/freeswitch/ && cat sounds.tar.gz.* | tar xzvf - && rm -rf sounds.tar.gz.*

VOLUME ["/usr/lib", "/var/lib", "/usr/local"]

CMD ["tail", "-f", "/dev/null"]