DEFAULT_GOAL := all
OUTPUTS = libq_core.so q.h q_core.h
BASE_PATH=$(abspath ../../ )

all: q_core
	echo "Q is built"

clean:
	find ${BASE_PATH} -name "*.o" -o -name "_*" | xargs rm -rf
	rm -f ${Q_ROOT}/lib/*.so
	rm -f ${Q_ROOT}/include/*.h
	rm -f ${Q_BUILD_DIR}/src/*
	rm -f ${Q_BUILD_DIR}/include/*
	make -C ${BASE_PATH}/UTILS/src/  clean
	make -C ${BASE_PATH}/OPERATORS/LOAD_CSV/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/AINB/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/IFXTHENYELSEZ/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/PRINT/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/F1F2OPF3/lua clean
	make -C ${BASE_PATH}/OPERATORS/F1S1OPF2/lua clean
	make -C ${BASE_PATH}/OPERATORS/SORT/lua clean
	make -C ${BASE_PATH}/OPERATORS/IDX_SORT/lua clean
	make -C ${BASE_PATH}/OPERATORS/S_TO_F/lua clean
	make -C ${BASE_PATH}/OPERATORS/F_TO_S/lua clean
	make -C ${BASE_PATH}/OPERATORS/AX_EQUALS_B/ clean
	make -C ${BASE_PATH}/OPERATORS/MM/lua/ clean
	make -C ${BASE_PATH}/OPERATORS/APPROX/QUANTILE/lua  clean
	make -C ${BASE_PATH}/OPERATORS/APPROX/FREQUENT  clean
	make -C ${BASE_PATH}/OPERATORS/PCA/src clean

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
	cd ${BASE_PATH}/UTILS/lua/
	lua copy_generated_files.lua 
	luajit mk_so.lua
	echo "all done for q_core"

q_basic: utils load_csv print column
	luajit mk_so.lua /tmp/
	echo "Basic Q is built"

column:
	cd ${BASE_PATH}/RUNTIME/src;
	make -C ${BASE_PATH}/RUNTIME/src/
	echo "column done"

utils:
	make -C ${BASE_PATH}/UTILS/src/ 
	echo "utils done"

ifxthenyelsez:
	make -C ${BASE_PATH}/OPERATORS/IFXTHENYELSEZ/lua/
	echo "ifxthenyelsez done"

ainb:
	make -C ${BASE_PATH}/OPERATORS/AINB/lua/
	echo "ainb done"

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
	ainb \
	ifxthenyelsez \
	mv_mul \
	approx_quantile \
	approx_frequent \
	corrm
	echo "all done for operators"


f1f2opf3: q_basic
	make -C ${BASE_PATH}/OPERATORS/F1F2OPF3/lua
	echo "f1f2opf3 done"

f1s1opf2: q_basic
	make -C ${BASE_PATH}/OPERATORS/F1S1OPF2/lua
	echo "f1s1opf2 done"

sort: q_basic
	make -C ${BASE_PATH}/OPERATORS/SORT/lua
	echo "sort done"

idx_sort: q_basic
	make -C ${BASE_PATH}/OPERATORS/IDX_SORT/lua
	echo "idx_sort done"

s_to_f: q_basic
	make -C ${BASE_PATH}/OPERATORS/S_TO_F/lua
	echo "s_to_f done"

f_to_s: q_basic
	make -C ${BASE_PATH}/OPERATORS/F_TO_S/lua
	echo "f_to_s done"

ax_equals_b: q_basic
	make -C ${BASE_PATH}/OPERATORS/AX_EQUALS_B/
	echo "ax_equals_b done"

approx_quantile: q_basic
	make -C ${BASE_PATH}/OPERATORS/APPROX/QUANTILE/lua
	echo "approx_quantile done"

approx_frequent: q_basic
	make -C ${BASE_PATH}/OPERATORS/APPROX/FREQUENT
	echo "approx_frequent done"

mv_mul: q_basic
	make -C ${BASE_PATH}/OPERATORS/MM/lua/
	echo "mv_mul done"

corrm: q_basic
	make -C ${BASE_PATH}/OPERATORS/PCA/src/
	echo "corrm done"

