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
../gen_src/_get_val_F4_by_idx_I1.c : get_val_by_idx.tmpl get_val_by_idx_specialize.lua
	luajit generator.lua operators.lua
		
# ../gen_src/_get_idx_by_val_I1_F4.c : get_idx_by_val.tmpl get_idx_by_val_specialize.lua
#	luajit generator.lua operators.lua
		
	# ../gen_src/_get_idx_by_val_I1_F4.c 
libget.so : ../gen_src/_get_val_F4_by_idx_I1.c 
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libget.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/
