# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libsumby.so  
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libsumby.so : ${GEN_FILES} \
	sumby.tmpl
	luajit generator.lua
	gcc ${GEN_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libsumby.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libsumby.so
	echo "TODO"

test_c :  libsumby.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_sumby_I1_I1_I8.c \
        ../gen_src/_sumby_I1_I2_I8.c \
        ../gen_src/_sumby_I1_I4_I8.c \
        ../gen_src/_sumby_I1_I8_I8.c \
        ../gen_src/_sumby_I2_I1_I8.c \
        ../gen_src/_sumby_I2_I2_I8.c \
        ../gen_src/_sumby_I2_I4_I8.c \
        ../gen_src/_sumby_I2_I8_I8.c \
        ../gen_src/_sumby_I4_I1_I8.c \
        ../gen_src/_sumby_I4_I2_I8.c \
        ../gen_src/_sumby_I4_I4_I8.c \
        ../gen_src/_sumby_I4_I8_I8.c \
        ../gen_src/_sumby_I8_I1_I8.c \
        ../gen_src/_sumby_I8_I2_I8.c \
        ../gen_src/_sumby_I8_I4_I8.c \
        ../gen_src/_sumby_I8_I8_I8.c \
        ../gen_src/_sumby_F4_I1_F8.c \
        ../gen_src/_sumby_F4_I2_F8.c \
        ../gen_src/_sumby_F4_I4_F8.c \
        ../gen_src/_sumby_F4_I8_F8.c \
        ../gen_src/_sumby_F8_I1_F8.c \
        ../gen_src/_sumby_F8_I2_F8.c \
        ../gen_src/_sumby_F8_I4_F8.c \
        ../gen_src/_sumby_F8_I8_F8.c \
