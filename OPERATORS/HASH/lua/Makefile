# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS= -I.  -I../../../UTILS/inc/  -I../inc/ -I../../../UTILS/gen_inc 

UDIR= ${Q_SRC_ROOT}/UTILS/lua/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : lib_hash.so 
	
clean : 
	rm -f _*
	rm -f *.so

SRC_FILES =  \
	../src/spooky_hash.c \

lib_hash.so : ${SRC_FILES}
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${SRC_FILES} ${CFLAGS} ${INCS} -shared -o lib_hash.so
	test -d  ${Q_BUILD_DIR}/src/
	cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	cp ../inc/spooky_hash.h ${Q_BUILD_DIR}/include/

test_q : lib_hash.so
	echo "TODO"

test_c :  libl_hash.so
	echo "TODO"

test : test_q test_c

