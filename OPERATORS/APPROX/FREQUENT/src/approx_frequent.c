#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>
#include "macros.h"
#include "_qsort_asc_I4.h"
#include "approx_frequent.h"

/*

This algorithm takes in a number of elements, a min_freq and an err and produces two outputs, y and f satisfying:

(1) all elements in x occuring greater than or equal to min_freq number of times  will definitely be listed in y (THESE ARE THE FREQUENT ELEMENTS (definition) )
(2) their corresponding frequency in f will be greater than or equal to (min_freq-err), i.e., the maximum error in estimating their frequencies is err.
(3) no elements in x occuring less than (min_freq-err) number of times will be listed in y

The approximation is two fold:

(i) the estimated frequencies of the "frequent" elements can be off by a maximum of err.
(ii) elements occuring between (min_freq-err) and (min_freq) number of times can also be listed in y.

For example: say min_freq = 500 and err = 100.  y will contain the id of all the elements occuring >= 500 definitely, and their corresponding estimated frequency in f would definitely be >= (500-100) = 400. No element in x which occurs less than 400 times will occur in y. Note that elements with frequency between 400 and 500 "can" be listed in y.

Author: Kishore Jaganathan

Algorithm: Based on the FREQUENT algorithm (refer to Cormode's paper "Finding Frequent Items in Data Streams")
We actually run the FREQUENT algorithm with min_freq = err, which is what ends up guaranteeing our error bounds.
We are also running a variant of that FREQUENT algorithm so that some steps can be done in parallel.

USAGE: Can use approx_frequent(...) to process all data at once, or "allocate_persistent_data" and then the
       various "process" functions to process data lazily.

STATUS: will return 1, 0 or -1
1: warning that function will use an unusually high amount of memory, consider decreasing err.
0: all good.
-1: Unrecoverable error
-2: Something wrong with inputs

 */

// HELPERS

int
sorted_array_to_id_freq (
                         int * buf,
                         long long num_buf,
                         int * bf_id,
                         int * bf_freq,
                         long long * ptr_bf_siz
                         )
{

  int status = 0;

  /* check inputs */

  if ( buf == NULL ) { go_BYE(-1); }
  if ( bf_id == NULL ) { go_BYE(-1); }
  if ( bf_freq == NULL ) { go_BYE(-1); }
  if ( ptr_bf_siz == NULL ) { go_BYE(-1); }

  /* (id, freq) conversion of sorted data */

  long long ii = 0, jj = 0;
  int temp_freq = 1;

  while ( ii < num_buf-1 ) {

    if ( buf[ii] == buf[ii+1] ) {
      temp_freq++;
    }
    else {
      bf_id[jj] = buf[ii];
      bf_freq[jj] = temp_freq;
      temp_freq = 1;
      jj++;
    }
    ii++;
  }
  bf_id[jj] = buf[ii];
  bf_freq[jj] = temp_freq;
  jj++;

  *ptr_bf_siz = jj;


 BYE:
  return(status);

}

int
update_counter (
		int * cntr_id,
		int * cntr_freq,
		long long cntr_siz,
		long long *ptr_active_cntr_siz,
		int * bf_id,
		int * bf_freq,
		long long bf_siz
		)
{

  int status = 0;

  int * temp_cntr_id = NULL;
  int * temp_cntr_freq = NULL;

  /* check inputs */

  if ( cntr_id == NULL ) { go_BYE(-1); }
  if ( cntr_freq == NULL ) { go_BYE(-1); }
  if ( ptr_active_cntr_siz == NULL ) { go_BYE(-1); }
  if ( bf_id == NULL ) { go_BYE(-1); }
  if ( bf_freq == NULL ) { go_BYE(-1); }

  //------------------------------------------------------------------------

  /* (temp_cntr_id,temp_cntr_freq) stores the merged and sorted (sorted in id) data of the counters (cntr_id,cntr_freq) and (bf_id, bf_freq) */

  long long ii = 0, jj = 0, kk = 0;

  temp_cntr_id = (int *)malloc( ((*ptr_active_cntr_siz)+bf_siz)*sizeof(int) );
  temp_cntr_freq = (int *)malloc( ((*ptr_active_cntr_siz)+bf_siz)*sizeof(int) );


  while (1) {

    if ( ii < (*ptr_active_cntr_siz) && jj < bf_siz ) {

      if ( cntr_id[ii] < bf_id[jj] ) {
        temp_cntr_id[kk] = cntr_id[ii];
        temp_cntr_freq[kk++] = cntr_freq[ii++];
      }
      else if ( bf_id[jj] < cntr_id[ii] ) {
        temp_cntr_id[kk] = bf_id[jj];
        temp_cntr_freq[kk++] = bf_freq[jj++];
      }
      else {
        temp_cntr_id[kk] = bf_id[jj];
        temp_cntr_freq[kk++] = bf_freq[jj++] + cntr_freq[ii++];
      }

    }
    else if ( ii < (*ptr_active_cntr_siz) && jj == bf_siz ) {
      temp_cntr_id[kk] = cntr_id[ii];
      temp_cntr_freq[kk++] = cntr_freq[ii++];
    }
    else if ( ii == (*ptr_active_cntr_siz) && jj < bf_siz ) {
      temp_cntr_id[kk] = bf_id[jj];
      temp_cntr_freq[kk++] = bf_freq[jj++];
    }
    else {
      break;
    }
  }

  *ptr_active_cntr_siz = kk;

  //------------------------------------------------------------------------

  /* If the size of (temp_cntr_id,temp_cntr_freq) is less than cntr_siz (i.e., the total number of counters available for use) then we just copy the data to (cntr_id, cntr_freq) (overwriting). Else, keep dropping elements with low frequencies (according to FREQUENT algorithm's rules so that theoretical guarantees hold)till the size of (temp_cntr_id,temp_cntr_freq) becomes less than cntr_siz and then copy the data to (cntr_id, cntr_freq). */


  while ( *ptr_active_cntr_siz > cntr_siz ) {

    for ( long long kk = 0; kk < *ptr_active_cntr_siz; kk++ ) {
      temp_cntr_freq[kk]--;
    }

    jj = 0;
    for ( long long kk = 0; kk < *ptr_active_cntr_siz; kk++ ) {
      if ( temp_cntr_freq[kk] > 0 ) {
        temp_cntr_freq[jj] = temp_cntr_freq[kk];
        temp_cntr_id[jj++] = temp_cntr_id[kk];
      }
    }
    *ptr_active_cntr_siz = jj;

  }

  memcpy(cntr_id, temp_cntr_id, *ptr_active_cntr_siz*sizeof(int));
  memcpy(cntr_freq, temp_cntr_freq, *ptr_active_cntr_siz*sizeof(int));

 BYE:
  free_if_non_null(temp_cntr_id);
  free_if_non_null(temp_cntr_freq);

  return(status);

}

// END HELPERS

// memory bound
#define HIGH_MEM 200*1048576

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

  if (cntr_siz * 4 + max_chunk_siz * 5 > HIGH_MEM) {
    status = 1;
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
