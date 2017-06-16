#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>
#include "macros.h"
#include "_qsort_asc_I4.h"
#include "approx_frequent.h"
#include "sorted_array_to_id_freq.h"
#include "update_counter.h"

/* Will not use more than (4*200) MB of memory, can change if you want */

/* README:

status = approx_frequent(x,cfld,siz,min_freq,err,y,f,out_siz,ptr_len,ptr_estimate_is_good) : The algorithm takes as input an array of integers, and lists out the "frequent" elements in the set approximately, where "frequent" elements are defined as elements occuring greater than or equal to "min_freq" number of times in the input. The approximated output has the following properties:

(1) all elements in x occuring greater than or equal to min_freq number of times  will definitely be listed in y (THESE ARE THE FREQUENT ELEMENTS (definition) )
(2) their corresponding frequency in f will be greater than or equal to (min_freq-err), i.e., the maximum error in estimating their frequencies is err.
(3) no elements in x occuring less than (min_freq-err) number of times will be listed in y

The approximation is two fold:
(i) the estimated frequencies of the "frequent" elements can be off by a maximum of err.
(ii) elements occuring between (min_freq-err) and (min_freq) number of times can also be listed in y.


For example: say min_freq = 500 and err = 100.  y will contain the id of all the elements occuring >= 500 definitely, and their corresponding estimated frequency in f would definitely be >= (500-100) = 400. No element in x which occurs less than 400 times will occur in y. Note that elements with frequency between 400 and 500 "can" be listed in y.

Author: Kishore Jaganathan

Algorithm: FREQUENT algorithm (refer to Cormode's paper "Finding Frequent Items in Data Streams")

NOTE: This implementation is a slight variant of the algorithm mentioned in the paper, so that some steps can be parallelized.

INPUTS:

x: The input array

cfld: two options - (1) NULL: All elements of x are processed.
(2) non-NULL: Array of same size as x. Acts as a select vector (only those elements with non-zero values in cfld are processed). ex: If x has 10 elements and cfld is {0,0,1,0,0,0,1,0,1,0}, then only the 3rd, 7th and 9th element are chosen for processing.

siz: Number of elements in the input array x

min_freq: elements occuring greater than or equal to min_freq times in x (among the ones selected for processing) are considered frequent elements. All of their id's will definitely be stored in y.

err: the measured frequencies of the "frequent" elements in x (i.e., occuring >= min_freq times in x, among the ones selected for processing) will definitely be greater than or equal to min_freq-err, and will be stored in f (corresponding to the id stored in y). Also, no element with frequency lesser than (min_freq-err) in x (among the ones selected for processing) will occur in y. Note: Lesser the error, more memory is needed for computation

out_siz: number of integers that can be written in y and f (prealloced memory). See y and f for how much to allocate.


OUTPUTS:

y: array containing the id's of the "frequent" elements. Need to malloc beforehand by atleast (number of elements to be processed)/(min_freq-err) * sizeof(int). If cfld is NULL, number of elements to be processed is siz, else it is equal to the number of non-zero entries in cfld.

f: array containing the corresponding frequencies of the "frequent" elements. Need to malloc beforehand by atleast (number of elements to be processed)/(min_freq-err) * sizeof(int). If cfld is NULL, number of elements to be processed is siz, else it is equal to the number of non-zero entries in cfld.

out_siz: number of integers that can be written in y and f (prealloced memory). See y and f for how much to allocate.

ptr_len: the size of y and f used by the algorithm to write the ids and frequencies of estimated approximate "frequent" elements

ptr_estimate_is_good: pointer to a location which stores 1, -1, -2 or -3
1: approximate calculations were successful, results stored in y,f and ptr_len
-1: something wrong with the input data. Check if sufficient malloc was done beforehand to y and f, in case you forgot.
-2: need too much memory, hence didn't do the calculations. Can retry with one of the following two things : (i) increase MAX_SZ if you are sure you have more RAM available (ii) increase err (the approximation parameter). Increasing err will result in more approximation (hence answer being less accurate) but memory requirements will be lesser.

status: will return 0 or -1
0: two cases - (i) calculations are successful, ptr_estimate_is_good will be set to 1 (ii) need too much memory and hence didn't do the calculations, ptr_estimate_is_good will be set to -2.
-1: Something wrong with inputs, ptr_estimate_is_good will also be set to -1

 */

#define MAX_SZ 200*1048576

int
allocate_persistent_data(
    long long siz,
    long long min_freq,
    long long err,
    long long max_chunk_siz,
    struct frequent_persistent_data *data)
{
  int status = 0;

  int *packet_space = NULL;
  int *cntr_id = NULL;
  int *cntr_freq = NULL;
  int cntr_siz;
  long long active_cntr_siz = 0;
  int *bf_id = NULL;
  int *bf_freq = NULL;

  cntr_siz = siz / err + 1;
  if (cntr_siz < 10000) { cntr_siz = 10000; } /* can be removed */

  if (cntr_siz * (1 + 2 + 6) > MAX_SZ) { // TODO: handle this gracefully
    go_BYE(1);
    /* Quitting if too much memory needed. Retry by doing one of the following:
       (i) Increase MAX_SZ if you think you have more RAM
       (ii) Increase eps (the approximation percentage) so that computations can be done within RAM
     */
  }
  if (max_chunk_siz < 1) {
    max_chunk_siz = cntr_siz;
  }

  cntr_id = malloc(cntr_siz * sizeof(int)); return_if_malloc_failed(cntr_id);
  cntr_freq = malloc(cntr_siz * sizeof(int)); return_if_malloc_failed(cntr_freq);
  bf_id = malloc(max_chunk_siz * sizeof(int)); return_if_malloc_failed(bf_id);
  bf_freq = malloc(max_chunk_siz * sizeof(int)); return_if_malloc_failed(bf_freq);
  packet_space = malloc(max_chunk_siz * sizeof(int)); return_if_malloc_failed(packet_space);

  data->packet_space = packet_space;
  data->cntr_id = cntr_id;
  data->cntr_freq = cntr_freq;
  data->cntr_siz = cntr_siz;
  data->active_cntr_siz = active_cntr_siz;
  data->bf_id = bf_id;
  data->bf_freq = bf_freq;
  data->siz = siz;
  data->min_freq = min_freq;
  data->err = err;

 BYE:
  return status;
}

int
process_chunk(
    int *chunk,
    int chunk_siz,
    struct frequent_persistent_data *data)
{
  int NUM_THREADS = 1;
  int status = 0;

  int **packet_starts = NULL;
  int *packet_sizs = NULL;
  packet_starts = malloc(NUM_THREADS * sizeof(int*)); return_if_malloc_failed(packet_starts);
  packet_sizs = malloc(NUM_THREADS * sizeof(int)); return_if_malloc_failed(packet_sizs);

  // copy chunk into NUM_THREADS packets to be sorted in parallel
  for (int tid = 0; tid < NUM_THREADS; tid++) {
    int offset = tid * (chunk_siz / NUM_THREADS);
    int *src_start = chunk + offset;
    packet_starts[tid] = data->packet_space + offset;
    packet_sizs[tid] = chunk_siz / NUM_THREADS;
    if (tid == NUM_THREADS - 1) {
      packet_sizs[tid] = chunk_siz - offset;
    }

    memcpy(packet_starts[tid], src_start, packet_sizs[tid] * sizeof(int));
  }

  // sort packets
  #pragma omp parallel for
  for (int tid = 0; tid < NUM_THREADS; tid++) {
    if ( packet_sizs[tid] == 0 ) { continue; }
    qsort_asc_I4(packet_starts[tid], packet_sizs[tid]);
  }

  // update counters using sorted data
  for ( int tid = 0; tid < NUM_THREADS; tid++ ) {
    if ( packet_sizs[tid] == 0 ) { continue; }

    long long bf_siz = 0;
    status = sorted_array_to_id_freq(packet_starts[tid], packet_sizs[tid], data->bf_id, data->bf_freq, &bf_siz); cBYE(status);
    status = update_counter(data->cntr_id, data->cntr_freq, data->cntr_siz, &data->active_cntr_siz, data->bf_id, data->bf_freq, bf_siz); cBYE(status);
  }

 BYE:
  free_if_non_null(packet_starts);
  free_if_non_null(packet_sizs);
  return status;
}

int
process_output(
    struct frequent_persistent_data *data,
    int **y,
    int **f,
    int *out_len)
{
  int status = 0;

  long long j = 0;
  for (long long i = 0; i < data->active_cntr_siz; i++) {
    if (data->cntr_freq[i] >= (data->min_freq - data->err)) {
      data->cntr_id[j] = data->cntr_id[i];
      data->cntr_freq[j] = data->cntr_freq[i];
      j++;
    }
  }

  *y = NULL;
  *f = NULL;
  *y = malloc(j * sizeof(int)); return_if_malloc_failed(*y);
  *f = malloc(j * sizeof(int)); return_if_malloc_failed(*f);

  memcpy(*y, data->cntr_id, j * sizeof(int));
  memcpy(*f, data->cntr_freq, j * sizeof(int));
  *out_len = j;

 BYE:
  return status;
}

void free_persistent_data(struct frequent_persistent_data *data) {
  if (data == NULL) return;
  free_if_non_null(data->packet_space);
  free_if_non_null(data->cntr_id);
  free_if_non_null(data->cntr_freq);
  free_if_non_null(data->bf_id);
  free_if_non_null(data->bf_freq);
  free(data);
}

int
approx_frequent (
    int *x,
    long long siz,
    long long min_freq,
    long long err,
    int **y,
    int **f,
    int *out_len
    )
{
  int status = 0;

  struct frequent_persistent_data *data = NULL;
  data = malloc(sizeof(struct frequent_persistent_data)); return_if_malloc_failed(data);

  status = allocate_persistent_data(siz, min_freq, err, -1, data); cBYE(status);

  for (long long i = 0; i < siz; i += data->cntr_siz) {
    int *chunk_start = x + i;
    int chunk_siz = min(data->cntr_siz, siz - i);
    status = process_chunk(chunk_start, chunk_siz, data); cBYE(status);
  }

  status = process_output(data, y, f, out_len); cBYE(status);

 BYE:
  free_persistent_data(data);
  return status;
}
