#
# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
WARN=  -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -Wno-aggregate-return -Wno-unused-parameter
INCS= -I. \
	-I../libevent-2.1.8-stable/include/event2/ \
	-I../libevent-2.1.8-stable/include/ \
	-I../LuaJIT-2.1.0-beta3/src/ \
	-I../dt_interpreter/src/  \

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

LFLAGS= $(DBGFLAGS) $(OPTFLAGS)  $(WARN) 

CFLAGS= $(LFLAGS) 

CC= clang
CC= gcc

CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

all : q_httpd \

./libs:
	mkdir libs

../LuaJIT-2.1.0-beta3/src/libluajit.a:
		cd ../ && \
		rm -rf LuaJIT-2.1.0-beta3 && \
	 	tar -xvzf LuaJIT-2.1.0-beta3.tar.gz && \
	 	cd LuaJIT-2.1.0-beta3/ && \
		sed -i '114s/#//' src/Makefile && \
		make TARGET_FLAGS=-pthread

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DBGFLAGS)

../lua-5.1.3/src/liblua.a :
	make -C ../lua-5.1.3/src/ linux

../libevent-2.1.8-stable/.libs/libevent.so : 
	cd ../ && \
	tar -zxvf libevent-2.1.8-stable.tar.gz && \
	ls && \
	cd ./libevent-2.1.8-stable/ &&  \
	./configure && \
	make && \
	cd ../src/

./libs/libevent.so: ./libs ../libevent-2.1.8-stable/.libs/libevent.so
	cp ../libevent-2.1.8-stable/.libs/libevent.so ./libs/libevent.so

$(COBJS) : ../LuaJIT-2.1.0-beta3/src/libluajit.a \
	./libs/libevent.so 


./libs/dt.so: ./libs ../dt_interpreter/src/dt.so
	cp ../dt_interpreter/src/dt.so ./libs/dt.so

q_httpd : $(COBJS)  \
	../LuaJIT-2.1.0-beta3/src/libluajit.a \
	./libs/libevent.so
	$(CC) $(CFLAGS) $(COBJS) \
	  -o q_httpd  \
	./libs/libevent.so \
	../LuaJIT-2.1.0-beta3/src/libluajit.a \
	-lm  -lpthread -ldl 

clean:
	rm -r -f q_httpd $(COBJS) 
#	make -i -C ../LuaJIT-2.1.0-beta3/src/ clean 
#	make -i -C ../libevent-2.1.8-stable/ distclean 
#	make -i -C ../lua-5.1.3/ clean 
	rm -r -f ../libevent-2.1.8-stable/ 
	rm -r -f ../LuaJIT-2.1.0-beta3/ 
	rm -r -f ../lua-5.1.3/ 
	echo "ALL CLEAN"

qclean :
	rm -r -f q_httpd $(COBJS) *.o _*
	rm -f libs/*
