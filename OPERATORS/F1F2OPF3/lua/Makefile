# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} -Werror

all : _libf1f2opf3.so
	
vvsub_specialize.lua : vvadd_specialize.lua
	cat vvadd_specialize.lua | \
	sed s'/vvadd_/vvsub_/'g | \
	sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a - b );/'g \
	> vvsub_specialize.lua

vvmul_specialize.lua : vvadd_specialize.lua
	cat vvadd_specialize.lua | \
	sed s'/vvadd_/vvmul_/'g | \
	sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a * b );/'g \
	> vvmul_specialize.lua

vvdiv_specialize.lua : vvadd_specialize.lua
	cat vvadd_specialize.lua | \
	sed s'/vvadd_/vvdiv_/'g | \
	sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a \/ b );/'g \
	> vvdiv_specialize.lua

vvor_specialize.lua : vvand_specialize.lua
	cat vvand_specialize.lua | \
	sed s'/vvand/vvor/'g | \
	sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a || b );/'g \
	> vvor_specialize.lua

vvxor_specialize.lua : vvand_specialize.lua
	cat vvand_specialize.lua | \
	sed s'/vvand/vvxor/'g | \
	sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a ^ b );/'g \
	> vvxor_specialize.lua

vvneq_specialize.lua : vveq_specialize.lua 
	cat vveq_specialize.lua | \
	sed s'/vveq_/vvneq_/'g | \
	sed s'/comparison = .*;/comparison = "( a != b );/'g \
	> vvneq_specialize.lua

vvgt_specialize.lua : vveq_specialize.lua 
	cat vveq_specialize.lua | \
	sed s'/vveq_/vvgt_/'g | \
	sed s'/comparison = .*;/comparison = "( a > b )/'g \
	> vvgt_specialize.lua

vvlt_specialize.lua : vveq_specialize.lua 
	cat vveq_specialize.lua | \
	sed s'/vveq_/vvlt_/'g | \
	sed s'/comparison = .*;/comparison = "( a < b ;/'g \
	> vvlt_specialize.lua

vvgeq_specialize.lua : vveq_specialize.lua 
	cat vveq_specialize.lua | \
	sed s'/vveq_/vvgeq_/'g | \
	sed s'/comparison = .*;/comparison = "( a >= b )/'g \
	> vvgeq_specialize.lua

vvleq_specialize.lua : vveq_specialize.lua 
	cat vveq_specialize.lua | \
	sed s'/vveq_/vvleq_/'g | \
	sed s'/comparison = .*;/comparison = "( a <= b )/'g \
	> vvleq_specialize.lua

clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	mkdir -p ../gen_src/
	mkdir -p ../gen_inc/
	rm -f vvsub_specialize.lua 
	rm -f vvmul_specialize.lua 
	rm -f vvdiv_specialize.lua 
	rm -f vvor_specialize.lua 
	rm -f vvxor_specialize.lua 
	rm -f vvneq_specialize.lua 
	rm -f vvgt_specialize.lua 
	rm -f vvlt_specialize.lua 
	rm -f vvgeq_specialize.lua 
	rm -f vvleq_specialize.lua 
	rm -f vvneq_specialize.lua 
	rm -f _*
		
vvadd_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua
vvsub_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua
vvmul_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua
vvdiv_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua
vvrem_specialize.lua : arith_specialize.tmpl
	lua gen_specializers.lua
vvor_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua
vvxor_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua
vvandnot_specialize.lua  : bop_specialize.tmpl
	lua gen_specializers.lua
vveq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua
vvneq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua
vvgeq_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua
vvleq_specialize.lua   : cmp_specialize.tmpl
	lua gen_specializers.lua
vvgt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua
vvlt_specialize.lua  : cmp_specialize.tmpl
	lua gen_specializers.lua

_libf1f2opf3.so : _concat_files _arith_files _bop_files _cmp_files
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf1f2opf3.so
	cp libf1f2opf3.so ${Q_ROOT}/lib/

_concat_files : 
	luajit concat_generator.lua concat_operators.lua

_arith_files : vvadd_specialize.lua vvsub_specialize.lua vvmul_specialize.lua vvdiv_specialize.lua vvrem_specialize.lua
	luajit arith_generator.lua arith_operators.lua

_bop_files : vvor_specialize.lua vvxor_specialize.lua vvandnot_specialize.lua 
	luajit bop_generator.lua bop_operators.lua

_cmp_files : vvgeq_specialize.lua vvleq_specialize.lua  \
	vvgt_specialize.lua vvlt_specialize.lua vvneq_specialize.lua 

	luajit cmp_generator.lua cmp_operators.lua

