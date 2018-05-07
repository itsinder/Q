# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/  -I../inc/ -I../../../UTILS/gen_inc 

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

SRC_FILES =  \
	../src/merge.c  \


libgetk.so : ${SRC_FILES}
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${SRC_FILES} ${CFLAGS} ${INCS} -shared -o libgetk.so
	test -d  ${Q_BUILD_DIR}/src/
	cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	cp ../inc/merge.h ${Q_BUILD_DIR}/include/

test_q : libgetk.so
	echo "TODO"

test_c :  libgetk.so
	echo "TODO"

test : test_q test_c

