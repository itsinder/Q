#!/bin/bash
INCS=-I../inc/ -I../gen_inc/
INCDIR=../gen_inc/

all : libutils.so ${hdr_files}

../gen_inc/_rand_file_name.h : 
	lua ../lua/cli_extract_func_decl.lua rand_file_name.c ${INCDIR}

../gen_inc/_mix_UI4.h : 
	lua ../lua/cli_extract_func_decl.lua mix_UI4.c ${INCDIR}

../gen_inc/_mix_UI8.h : 
	lua ../lua/cli_extract_func_decl.lua mix_UI8.c ${INCDIR}

../gen_inc/_f_mmap.h : 
	lua ../lua/cli_extract_func_decl.lua f_mmap.c ${INCDIR}

../gen_inc/_f_munmap.h : 
	lua ../lua/cli_extract_func_decl.lua f_munmap.c ${INCDIR}

../gen_inc/_mmap.h : 
	lua ../lua/cli_extract_func_decl.lua mmap.c ${INCDIR}

../gen_inc/_bytes_to_bits.h : 
	lua ../lua/cli_extract_func_decl.lua bytes_to_bits.c ${INCDIR}

../gen_inc/_bits_to_bytes.h : 
	lua ../lua/cli_extract_func_decl.lua bits_to_bytes.c ${INCDIR}

../gen_inc/_write_bits_to_file.h : 
	lua ../lua/cli_extract_func_decl.lua write_bits_to_file.c ${INCDIR}

../gen_inc/_get_bit.h : 
	lua ../lua/cli_extract_func_decl.lua get_bit.c ${INCDIR}

../gen_inc/_is_valid_chars_for_num.h : 
	lua ../lua/cli_extract_func_decl.lua is_valid_chars_for_num.c ${INCDIR}

../gen_src/_bin_search_I1.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I1
../gen_src/_bin_search_I2.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I2
../gen_src/_bin_search_I4.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I4
../gen_src/_bin_search_I8.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua I8 
../gen_src/_bin_search_F4.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua F4
../gen_src/_bin_search_F8.c : bin_search.tmpl bin_search_generator.lua
	lua bin_search_generator.lua F8

bin_search_files = \
	../gen_src/_bin_search_I1.c  \
	../gen_src/_bin_search_I2.c  \
	../gen_src/_bin_search_I4.c \
	../gen_src/_bin_search_I8.c  \
	../gen_src/_bin_search_F4.c \
	../gen_src/_bin_search_F8.c 

hdr_files = \
	../gen_inc/_mix_UI4.h  \
	../gen_inc/_mix_UI8.h  \
	../gen_inc/_rand_file_name.h  \
	../gen_inc/_f_mmap.h \
	../gen_inc/_f_munmap.h \
	../gen_inc/_mmap.h \
	../gen_inc/_write_bits_to_file.h \
        ../gen_inc/_get_bit.h \
	../gen_inc/_is_valid_chars_for_num.h  \
	../gen_inc/_bytes_to_bits.h   \
	../gen_inc/_bits_to_bytes.h 

#--------
SRC_FILES=  \
	mix_UI4.c \
	mix_UI8.c \
	rand_file_name.c \
	f_mmap.c  \
	f_munmap.c \
	mmap.c \
	bytes_to_bits.c \
	bits_to_bytes.c \
	write_bits_to_file.c  \
        get_bit.c  \
	is_valid_chars_for_num.c 

libutils.so : ${bin_search_files} ${hdr_files}
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${INCS} ${SRC_FILES} ../gen_src/*.c -o libutils.so
	mkdir -p ${Q_BUILD_DIR}/include/
	mkdir -p ${Q_BUILD_DIR}/src/
	cp ${INCDIR}/*.h         ${Q_BUILD_DIR}/include/
	cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	cp ../inc/*          ${Q_BUILD_DIR}/include/

clean :
	rm -f ../gen_src/*
	rm -f ../gen_inc/*
	rm -f _*
	rm -f *.so
	rm -f *.o

asc2bin :
	echo TODO

bin2asc :
	echo TODO

