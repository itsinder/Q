int 
approx_quantile (
		 int *x, 
		 char * cfld,
		 long long siz, 
		 long long num_quantiles, 
		 double err, 
		 int *y,
		 long long y_siz,
		 int *ptr_estimate_is_good
		 );

typedef struct aq_rec_type {
  int b;
  int k;
  int ** buffers;
  int * weight;
} AQ_REC_TYPE;

