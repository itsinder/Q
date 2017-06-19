# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libf1s1opf2.so _f1s1opf2.lua
	
f1opf2_specializers: f1opf2_specialize.tmpl \
	log_specialize.lua exp_specialize.lua \
	logit_specialize.lua logit2_specialize.lua  
	luajit gen_specializers.lua f1opf2

arith_specializers: arith_specialize.tmpl \
	vsadd_specialize.lua vssub_specialize.lua \
	vsmul_specialize.lua vsdiv_specialize.lua  
	luajit gen_specializers.lua arith

cmp_specializers: vsgeq_specialize.lua vsleq_specialize.lua  \
	vsgt_specialize.lua vslt_specialize.lua \
	vseq_specialize.lua vsneq_specialize.lua 
	luajit gen_specializers.lua cmp

bop_specializers : rem_specialize.tmpl \
	vsrem_specialize.lua  vsxor_specialize.lua \
	vsand_specialize.lua vsor_specialize.lua  
	luajit gen_specializers.lua bop

#----------------------------------
clean :
	rm -f vsadd_specialize.lua
	rm -f vssub_specialize.lua
	rm -f vsmul_specialize.lua
	rm -f vsdiv_specialize.lua 
#-------------
	rm -f vseq_specialize.lua
	rm -f vsneq_specialize.lua
	rm -f vsgeq_specialize.lua
	rm -f vsleq_specialize.lua
	rm -f vsgt_specialize.lua
	rm -f vslt_specialize.lua
#-------------
	rm -f vsrem_specialize.lua
	rm -f vsand_specialize.lua
	rm -f vsor_specialize.lua
	rm -f vsxor_specialize.lua
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
		
vsadd_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vssub_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vsmul_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
vsdiv_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua arith
#-------------------
vsand_specialize.lua  : rem_specialize.tmpl
	lua gen_specializers.lua bop
vsor_specialize.lua  : rem_specialize.tmpl
	lua gen_specializers.lua bop
vsxor_specialize.lua  : rem_specialize.tmpl
	lua gen_specializers.lua bop
vseq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsneq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsgeq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsleq_specialize.lua   : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vsgt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
vslt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua cmp
#---------------------
incr_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
decr_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
log_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
exp_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
logit_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2
logit2_specialize.lua  : f1opf2_specialize.tmpl
	lua gen_specializers.lua f1opf2

libf1s1opf2.so : _arith_files _cmp_files _f1opf2_files
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf1s1opf2.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

_arith_files : arith_specializers
	luajit generator1.lua arith_operators.lua

_cmp_files : cmp_specializers
	luajit generator1.lua cmp_operators.lua

_f1opf2_files : f1opf2_specializers
	luajit generator0.lua operators0.lua

_f1s1opf2.lua : 
	lua pkg_f1s1opf2.lua

_ctests : libf1s1opf2.so 
	cd ../test/ && bash run_tests.sh && cd -
	
