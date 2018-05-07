# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libgetk.so  
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libgetk.so : ${GEN_FILES} \
	merge1.tmpl
	luajit generator.lua
	gcc ${GEN_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libgetk.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libgetk.so
	echo "TODO"

test_c :  libgetk.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_merge_max_F4.c \
	../gen_src/_merge_max_F8.c \
	../gen_src/_merge_max_I1.c \
	../gen_src/_merge_max_I2.c \
	../gen_src/_merge_max_I4.c \
	../gen_src/_merge_max_I8.c \
	../gen_src/_merge_min_I8.c \
	../gen_src/_merge_min_I4.c \
	../gen_src/_merge_min_I2.c \
	../gen_src/_merge_min_I1.c \
	../gen_src/_merge_min_F8.c \
	../gen_src/_merge_min_F4.c \
