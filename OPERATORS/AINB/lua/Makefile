# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libainb.so  _ainb.lua
	
AUX_FILES = ../../../UTILS/src/bytes_to_bits.c

../../../UTILS/gen_inc/_bytes_to_bits.h :
	make -C ../../../UTILS/lua/
../gen_src/_ainb_F4_F4.c :
	luajit generator.lua # TODO: Should be more specific
../gen_src/_ainb_I4_I4.c :
	luajit generator.lua I4 I4 
#----------------------------------
_ainb.lua : pkg_ainb.lua
	lua pkg_ainb.lua
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libainb.so : ${GEN_FILES} ${AUX_FILES}
	luajit generator.lua # TODO This should not be here. Hack
	gcc ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libainb.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libainb.so
	echo "TODO"

test_c :  libainb.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_ainb_F4_F4.c \
	../gen_src/_ainb_F4_F8.c \
	../gen_src/_ainb_F4_I1.c \
	../gen_src/_ainb_F4_I2.c \
	../gen_src/_ainb_F4_I4.c \
	../gen_src/_ainb_F4_I8.c \
	../gen_src/_ainb_F8_F4.c \
	../gen_src/_ainb_F8_F8.c \
	../gen_src/_ainb_F8_I1.c \
	../gen_src/_ainb_F8_I2.c \
	../gen_src/_ainb_F8_I4.c \
	../gen_src/_ainb_F8_I8.c \
	../gen_src/_ainb_I1_F4.c \
	../gen_src/_ainb_I1_F8.c \
	../gen_src/_ainb_I1_I1.c \
	../gen_src/_ainb_I1_I2.c \
	../gen_src/_ainb_I1_I4.c \
	../gen_src/_ainb_I1_I8.c \
	../gen_src/_ainb_I2_F4.c \
	../gen_src/_ainb_I2_F8.c \
	../gen_src/_ainb_I2_I1.c \
	../gen_src/_ainb_I2_I2.c \
	../gen_src/_ainb_I2_I4.c \
	../gen_src/_ainb_I2_I8.c \
	../gen_src/_ainb_I4_F4.c \
	../gen_src/_ainb_I4_F8.c \
	../gen_src/_ainb_I4_I1.c \
	../gen_src/_ainb_I4_I2.c \
	../gen_src/_ainb_I4_I4.c \
	../gen_src/_ainb_I4_I8.c \
	../gen_src/_ainb_I8_F4.c \
	../gen_src/_ainb_I8_F8.c \
	../gen_src/_ainb_I8_I1.c \
	../gen_src/_ainb_I8_I2.c \
	../gen_src/_ainb_I8_I4.c \
	../gen_src/_ainb_I8_I8.c \
