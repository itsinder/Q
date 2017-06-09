DEFAULT_GOAL := all
OUTPUTS = libq.so libq_core.so q.h q_core.h
BASE_PATH=$(abspath ../../ )

clean:
	find ${BASE_PATH} -name "*.o" -o -name "_*" | xargs rm -rf
	find ${Q_ROOT}/lib -type f | xargs rm -f
	find ${Q_ROOT}/include -type f | xargs rm -f
	rm -rf /tmp/LUA*
	rm -f /tmp/libq.so /tmp/libq_core.so
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

uninstall:
	rm -rf /usr/local/share/lua/5.1/Q;\
	rm -f /usr/lib/libq_core.so;\
	echo "Q uninstalled"

libq.so: libq_core.so q.h

all: q_core
	echo "Q is built"

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
		cd ${BASE_PATH}/;\
		cd UTILS/src;\
		bash gen_files.sh
		
		echo "utils done"

load_csv:
		cd ${BASE_PATH}/OPERATORS/LOAD_CSV/lua;\
		bash gen_files.sh
		
		cd ${BASE_PATH}/OPERATORS/LOAD_CSV/src;\
		bash gen_files.sh
		
		echo "load_csv done"

print:
		cd ${BASE_PATH}/OPERATORS/PRINT/lua;\
		bash gen_files.sh
		
		cd ${BASE_PATH}/OPERATORS/PRINT/src;\
		bash gen_files.sh
		
		echo "print done"

q_operators: f1f2opf3 f1s1opf2 sort idx_sort s_to_f f_to_s ax_equals_b
	echo "all done for operators"


f1f2opf3: q_basic
		cd ${BASE_PATH}/OPERATORS/F1F2OPF3/lua;\
		make clean && make && luajit pkg_f1f2opf3.lua
		
		#luajit pkg_f1f2opf3.lua
		echo "f1f2opf3 done"

f1s1opf2: q_basic
		cd ${BASE_PATH}/OPERATORS/F1S1OPF2/lua;\
		bash gen_files.sh && luajit pkg_f1s1opf2.lua
		
		echo "f1s1opf2 done"

sort: q_basic
		cd ${BASE_PATH}/OPERATORS/SORT/lua;\
		bash gen_files.sh

		echo "sort done"

idx_sort: q_basic
		cd ${BASE_PATH}/OPERATORS/IDX_SORT/lua;\
		bash gen_files.sh

		echo "idx_sort done"

s_to_f: q_basic
		cd ${BASE_PATH}/OPERATORS/S_TO_F/lua;\
		bash gen_files.sh && luajit pkg_s_to_f.lua
		
		#cd ${BASE_PATH};\
		#cd OPERATORS/S_TO_F/lua;\
		#luajit pkg_s_to_f.lua
		
		echo "s_to_f done"

f_to_s: q_basic
		cd ${BASE_PATH}/OPERATORS/F_TO_S/lua;\
 		bash gen_files.sh && luajit pkg_f_to_s.lua
		
		echo "f_to_s done"

ax_equals_b: q_basic
		cd ${BASE_PATH}/OPERATORS/AX_EQUALS_B;\
		make clean && make

		echo "ax_equals_b done"





	
