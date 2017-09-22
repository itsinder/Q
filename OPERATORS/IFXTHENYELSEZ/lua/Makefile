# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libifxthenyelsez.so  
	
../gen_src/_ifxthenyelsez_I4.c :
	luajit generator.lua # TODO: Should be more specific
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libifxthenyelsez.so : ${GEN_FILES} ifxthenyelsez.tmpl 
	luajit generator.lua # TODO This should not be here. Hack
	gcc  ${CFLAGS} ${GEN_FILES} ${INCS} ${Q_LINK_FLAGS} \
	  -o libifxthenyelsez.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

GEN_FILES = \
	../gen_src/_ifxthenyelsez_I1.c \
	../gen_src/_ifxthenyelsez_I2.c \
	../gen_src/_ifxthenyelsez_I4.c \
	../gen_src/_ifxthenyelsez_I8.c \
	../gen_src/_ifxthenyelsez_F4.c \
	../gen_src/_ifxthenyelsez_F8.c \

