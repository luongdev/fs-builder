include $(top_srcdir)/build/modmake.rulesam
MODNAME=mod_event_kafka

mod_LTLIBRARIES = mod_event_kafka.la
mod_event_kafka_la_SOURCES  = mod_event_kafka.cpp
mod_event_kafka_la_CFLAGS   = $(AM_CFLAGS) -g -O0
mod_event_kafka_la_CXXFLAGS = $(AM_CXXFLAGS) -std=c++17 -g -O0

mod_event_kafka_la_LIBADD   = $(switch_builddir)/libfreeswitch.la
mod_event_kafka_la_LDFLAGS  = -avoid-version -module -no-undefined -shared -lrdkafka -lz -lpthread -lrt