CC=gcc -O4 -std=gnu99 -fopenmp
LINKOPTIONS= -lm -g

#CC=icc -O3 -std=c99
#LINKOPTIONS=-ipp -DIPP -DCILK -lm -g

CFLAGS = -c -Wall

INCLUDES = -I ../../SORT/gen_inc/ -I ./includes
TARGET_DIR = bin
SRC_DIR = src
TEST_DIR = test

SRCOBJS = bin/approx_frequent.o \
	../../SORT/gen_src/_qsort_asc_I4.o \
	bin/sorted_array_to_id_freq.o \
	bin/update_counter.o \


all: testApproxFrequent

$(TARGET_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) $< $(LINKOPTIONS) -o $@

$(TARGET_DIR)/%.o: $(TEST_DIR)/%.c
	$(CC)  $(CFLAGS) $(INCLUDES) $< $(LINKOPTIONS) -o $@

testApproxFrequent: $(SRCOBJS) bin/testApproxFrequent.o
	$(CC) $(INCLUDES) $(SRCOBJS) $(TARGET_DIR)/testApproxFrequent.o $(LINKOPTIONS) -o $(TEST_DIR)/testApproxFrequent
	$(TEST_DIR)/testApproxFrequent

clean:
	rm -f $(TARGET_DIR)/*.o test/testApproxFrequent



