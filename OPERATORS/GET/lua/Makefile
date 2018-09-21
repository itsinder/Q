# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} -Werror

all : libget.so 

#----------------------------------
clean :
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
#-------------
../gen_src/_get_I1_F4.c : get.tmpl get_specialize.lua
	luajit generator.lua operators.lua
		
libget.so : ../gen_src/_get_I1_F4.c 
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libget.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

_get_files : get_specialize.lua get.tmpl
	luajit generator.lua operators.lua
