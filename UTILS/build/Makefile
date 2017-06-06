OUTPUTS = libq.so libq_core.so q.h q_core.h
BASE_PATH=$(abspath ../../ )

libq.so: libq_core.so q.h

q.h: q_core.h


all: q_core
	cd ${BASE_PATH}

q_core: libq_core.so q_core.h
	echo "all done for q_core"

q: libq.so q.h
	echo "all done for q"

q_core.h: column utils load_csv


libq_core.so: column utils load_csv q_core.h
	
	# get files in q_core.h
	# we need to first make everything needed for the file

clean:
	find ${BASE_PATH} -name "*.o" -o -name "_*" | xargs rm -rf
	find ${Q_ROOT}/lib -type f | xargs rm
	find ${Q_ROOT}/bin -type f | xargs rm
	rm -rf /tmp/LUA*
	rm -f /tmp/libq.so /tmp/libq_core.so
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

f1f2opf3: q_core
		cd ${BASE_PATH};\
		cd OPERATORS/F1F2OPF3/lua;\
		make clean && make;\
		luajit pkg_f1f2opf3.lua;\
		echo "f1f2opf3 done"	
