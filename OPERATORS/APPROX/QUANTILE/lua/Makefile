# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I../src/  -I../../../../UTILS/inc/ -I../gen_inc/ -I../../../SORT/gen_inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libaq.so 
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		
../gen_src/_qsort_asc_I1.c :
	make -C ../../../SORT/lua/ clean && make -C ../../../SORT/lua/ 

../gen_src/_qsort_asc_I2.c :
	make -C ../../../SORT/lua/ clean && make -C ../../../SORT/lua/ 

../gen_src/_qsort_asc_I4.c :
	make -C ../../../SORT/lua/ clean && make -C ../../../SORT/lua/ 

../gen_src/_qsort_asc_I8.c :
	make -C ../../../SORT/lua/ clean && make -C ../../../SORT/lua/ 


libaq.so : ../gen_src/_qsort_asc_I1.c \
           ../gen_src/_qsort_asc_I2.c \
           ../gen_src/_qsort_asc_I4.c \
           ../gen_src/_qsort_asc_I8.c 
	luajit generator.lua 
	gcc ../src/*.c ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libaq.so

