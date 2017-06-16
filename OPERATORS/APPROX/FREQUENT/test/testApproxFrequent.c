#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "macros.h"
#include "approx_frequent.h"

int run_test(int *x, long long x_len, int *freq_ids, int *freq_counts, int freq_len, int min_freq, int err) {
  int status = 0;

  int *y = NULL;
  int *f = NULL;
  int out_len;
  status = approx_frequent(x, x_len, min_freq, err, &y, &f, &out_len); cBYE(status);

  int j = 0, i = 0;
  while (i < freq_len && j < out_len) {
    if (freq_ids[i] == y[j]) {
      if (f[j] < min_freq - err || abs(f[j] - freq_counts[i]) > err) {
        fprintf(stderr, "expected: (%d, %d), output: (%d, %d)", freq_ids[i], freq_counts[i], y[j], f[j]);
        go_BYE(2);
      } else {
        i++;
        j++;
      }
    } else if (freq_ids[i] < y[j]) {
      if (freq_counts[i] >= min_freq) {
        go_BYE(2);
      }
      i++;
    } else {
      go_BYE(2);
    }
  }
  if (j < out_len) {
    go_BYE(2);
  }
  for (; i < freq_len; i++) {
    if (freq_counts[i] >= min_freq) {
      go_BYE(2);
    }
  }

 BYE:
  free_if_non_null(y);
  free_if_non_null(f);
  return status;
}

int test_very_freq() {
  int status = 0;

  long long total_nums = 100000;
  int min_freq = 10000;
  int err = 10;
  int freq_len = total_nums - total_nums / 2 + 1;

  int *freq_ids = NULL;
  int *freq_counts = NULL;
  int *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int)); return_if_malloc_failed(x);

  freq_ids[0] = 1;
  freq_counts[0] = total_nums / 2;
  for (int i = 1; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = 1;
  }

  for (int i = 0; i < total_nums; i+=2) {
    x[i] = freq_ids[0];
    x[i + 1] = freq_ids[i / 2 + 1];
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

int test_barely_freq() {
  int status = 0;

  long long total_nums = 100000;
  int min_freq = 10000;
  int err = 10;
  int freq_len = total_nums - min_freq;

  int *freq_ids = NULL;
  int *freq_counts = NULL;
  int *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int)); return_if_malloc_failed(x);

  freq_ids[0] = 1;
  freq_counts[0] = min_freq;
  for (int i = 1; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = 1;
  }

  int per = total_nums / min_freq;
  for (int i = 0; i < min_freq; i ++) {
    x[i * per] = freq_ids[0];
    for (int j = 1; j < per; j++) {
      x[i * per + j] = freq_ids[(per - 1) * i + (j - 1)];
    }
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

int test_many_freq() {
  int status = 0;

  long long total_nums = 200000;
  int min_freq = 10000;
  int err = 10;
  int num_freq = 10;
  int freq_len = num_freq + (total_nums - min_freq * num_freq);

  int *freq_ids = NULL;
  int *freq_counts = NULL;
  int *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int)); return_if_malloc_failed(x);

  for (int i = 0; i < num_freq; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = min_freq;
  }
  for (int i = num_freq; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = 1;
  }

  int per = num_freq * 2;
  for (int i = 0; i < total_nums / per; i++) {
    for (int j = 0; j < num_freq; j++) {
      x[i * per + j * 2] = freq_ids[j];
      x[i * per + j * 2 + 1] = freq_ids[(i + 1) * num_freq + j];
    }
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

int test_no_freq() {
  int status = 0;

  long long total_nums = 100000;
  int min_freq = 10000;
  int err = 10;
  int num_per = 10;
  int freq_len = total_nums / num_per;

  int *freq_ids = NULL;
  int *freq_counts = NULL;
  int *x = NULL;

  freq_ids = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_ids);
  freq_counts = malloc(freq_len * sizeof(int)); return_if_malloc_failed(freq_counts);
  x = malloc(total_nums * sizeof(int)); return_if_malloc_failed(x);

  for (int i = 0; i < freq_len; i++) {
    freq_ids[i] = i + 1;
    freq_counts[i] = num_per;
  }

  for (int i = 0; i < freq_len; i ++) {
    for (int j = 0; j < num_per; j++) {
      x[j * freq_len + i] = freq_ids[i];
    }
  }

  status = run_test(x, total_nums, freq_ids, freq_counts, freq_len, min_freq, err);

 BYE:
  free_if_non_null(freq_ids);
  free_if_non_null(freq_counts);
  free_if_non_null(x);
  return status;
}

int main (int argc, char **argv) {
  int num_tests = 4;

  int (*tests[num_tests])();
  char *test_names[num_tests];
  tests[0] = test_very_freq; test_names[0] = "VERY_FREQ";
  tests[1] = test_barely_freq; test_names[1] = "BARELY_FREQ";
  tests[2] = test_many_freq; test_names[2] = "MANY_FREQ";
  tests[3] = test_no_freq; test_names[3] = "NO_FREQ";

  for (int i = 0; i < num_tests; i++) {
    int status = tests[i]();
    if (status != 0) {
      printf("ERROR on test %s\n", test_names[i]);
    } else {
      printf("great success on test %s!\n", test_names[i]);
    }
  }
}
