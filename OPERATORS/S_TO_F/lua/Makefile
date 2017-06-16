# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libs_to_f.so _s_to_f.lua
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
		

libs_to_f.so : 
	luajit generator.lua operators.lua
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libs_to_f.so

_s_to_f.lua : 
	lua pkg_s_to_f.lua
