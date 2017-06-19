DEFAULT_GOAL := all
OUTPUTS = libq_core.so q.h q_core.h
BASE_PATH=$(abspath ../../ )

all: q_core
	echo "Q is built"

clean:
	find ${BASE_PATH} -name "*.o" -o -name "_*" | xargs rm -rf
	find ${Q_ROOT}/lib -type f | xargs rm -f
	find ${Q_ROOT}/include -type f | xargs rm -f
	rm -rf /tmp/LUA*
	rm -f /tmp/libq_core.so
	cd ${BASE_PATH}/OPERATORS/F1F2OPF3/lua/;\
		bash clean.sh
	cd ${BASE_PATH}/OPERATORS/F1S1OPF2/lua/;\
		bash clean.sh

install: uninstall 
	cd ../../;\
	mkdir /usr/local/share/lua/5.1/Q;\
	cp -r ./OPERATORS /usr/local/share/lua/5.1/Q;\
	cp -r ./UTILS /usr/local/share/lua/5.1/Q;\
	cp -r ./RUNTIME /usr/local/share/lua/5.1/Q;\
	cp -r  q_export.lua /usr/local/share/lua/5.1/Q;\
	cp -r  init.lua /usr/local/share/lua/5.1/Q;\
	# FIX THIS, pick library from build target
	cp ${Q_ROOT}/lib/libq_core.so /usr/lib;\
	cp ${Q_ROOT}/include/q_core.h /usr/local/share/lua/5.1/Q

all: q_core
	cd ${BASE_PATH}

uninstall:
	rm -rf /usr/local/share/lua/5.1/Q;\
	rm -f /usr/lib/libq_core.so;\
	echo "Q uninstalled"


q_core: q_basic q_operators
	luajit mk_so.lua /tmp/
	echo "all done for q_core"

q_basic: column utils load_csv print
	luajit mk_so.lua /tmp/
	echo "Basic Q is built"

column:
	cd ${BASE_PATH}/RUNTIME/COLUMN/code/src;
	echo "column done"

utils:
	make -C ${BASE_PATH}/UTILS/src/ 
	echo "utils done"

load_csv:
	make -C ${BASE_PATH}/OPERATORS/LOAD_CSV/lua/
	echo "load_csv done"

print:
	make -C ${BASE_PATH}/OPERATORS/PRINT/lua/
	echo "print_csv done"

q_operators: f1f2opf3 \
	f1s1opf2 \
	sort \
	idx_sort \
	s_to_f \
	f_to_s \
	ax_equals_b \
	approx_quantile
	echo "all done for operators"


f1f2opf3: q_basic
		make -C ${BASE_PATH}/OPERATORS/F1F2OPF3/lua
		echo "f1f2opf3 done"

f1s1opf2: q_basic
		make ${BASE_PATH}/OPERATORS/F1S1OPF2/lua
		echo "f1s1opf2 done"

sort: q_basic
		make -C ${BASE_PATH}/OPERATORS/SORT/lua
		echo "sort done"

idx_sort: q_basic
		cd ${BASE_PATH}/OPERATORS/IDX_SORT/lua;\
		bash gen_files.sh

		echo "idx_sort done"

s_to_f: q_basic
		make -C ${BASE_PATH}/OPERATORS/S_TO_F/lua
		echo "s_to_f done"

f_to_s: q_basic
		make -C ${BASE_PATH}/OPERATORS/F_TO_S/lua
		echo "f_to_s done"

ax_equals_b: q_basic
		cd ${BASE_PATH}/OPERATORS/AX_EQUALS_B;\
		make clean && make

		echo "ax_equals_b done"

	
approx_quantile: q_basic
	make -C ${BASE_PATH}/OPERATORS/APPROX/QUANTILE/lua 
	echo "approx_quantile done"

