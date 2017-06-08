OUTPUTS = libq.so libq_core.so q.h q_core.h
BASE_PATH=$(abspath ../../ )

clean:
	find ${BASE_PATH} -name "*.o" -o -name "_*" | xargs rm -rf
	find ${Q_ROOT}/lib -type f | xargs rm
	find ${Q_ROOT}/bin -type f | xargs rm
	rm -rf /tmp/LUA*
	rm -f /tmp/libq.so /tmp/libq_core.so

install:
	cd ../../;\
	rm -rf /usr/local/share/lua/5.1/Q;\
	mkdir /usr/local/share/lua/5.1/Q;\
	cp -r ./OPERATORS /usr/local/share/lua/5.1/Q;\
	cp -r ./UTILS /usr/local/share/lua/5.1/Q;\
	cp -r ./RUNTIME /usr/local/share/lua/5.1/Q;\
	cp -r  q_export.lua /usr/local/share/lua/5.1/Q;\
	cp -r  init.lua /usr/local/share/lua/5.1/Q;\
	# FIX THIS, pick library from build target
	cp ${Q_ROOT}/lib/libq.so /usr/lib;\
	cp ${Q_ROOT}/include/q_core.h /usr/local/share/lua/5.1/Q

libq.so: libq_core.so q.h

all: q_core
	cd ${BASE_PATH}

q_core: libq_core.so q_core.h
	luajit mk_so.lua /tmp/
	echo "all done for q_core"

q: libq.so q.h
	echo "all done for q"

q_core.h: column utils load_csv
	echo "all done for q_core.h"

libq_core.so: column utils load_csv q_core.h
	luajit mk_core.lua /tmp/
	# get files in q_core.h
	# we need to first make everything needed for the file

libq.so: q_operators
	luajit mk_so.lua /tmp/

column:
	cd ${BASE_PATH}/RUNTIME/COLUMN/code/src;
	echo "column done"

utils:
		cd ${BASE_PATH}/;\
		cd UTILS/src; \
		bash gen_files.sh;\
		echo "utils done"

load_csv:
		cd ${BASE_PATH};\
		cd OPERATORS/LOAD_CSV;\
		cd lua;\
		bash gen_files.sh;\
		cd ../src;\
		bash gen_files.sh;\
		echo "load_csv done"

print:
		cd ${BASE_PATH};\
		cd OPERATORS/PRINT;\
		cd lua;\
		bash gen_files.sh;\
		cd ../src;\
		bash gen_files.sh;\
		echo "print done"

q_operators: f1f2opf3 f1s1opf2 sort idx_sort s_to_f f_to_s ax_equals_b
	echo "all done for operators"


f1f2opf3: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/F1F2OPF3/lua;\
		make clean && make;\
		luajit pkg_f1f2opf3.lua;\
		echo "f1f2opf3 done"

f1s1opf2: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/F1S1OPF2/lua;\
		bash gen_files.sh;\
		luajit pkg_f1s1opf2.lua;\
		echo "f1s1opf2 done"

sort: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/SORT/lua;\
		bash gen_files.sh;\
		echo "sort done"

idx_sort: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/IDX_SORT/lua;\
		bash gen_files.sh;\
		echo "idx_sort done"

s_to_f: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/S_TO_F/lua;\
		bash gen_files.sh;\
		luajit pkg_s_to_f.lua;\
		echo "s_to_f done"

f_to_s: q_core

		# cd ${BASE_PATH};\
 		# cd OPERATORS/F_TO_S/lua;\
 		# bash gen_files.sh;\
 		# luajit pkg_f_to_s.lua;\
 		# echo "f_to_s done"

ax_equals_b: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/AX_EQUALS_B;\
		make clean && make;\
		echo "ax_equals_b done"





	
