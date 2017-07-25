#include "q_incs.h"
#include "mmap_types.h"
#include "core_vec.h"
#include "_mmap.h"
#include "_rand_file_name.h"
#include "_get_file_size.h"
#include "_buf_to_file.h"

#include "lauxlib.h"

extern luaL_Buffer g_errbuf;

int
chk_field_type(
    const char * const field_type
    )
{
  int status = 0;
  if ( field_type == NULL ) { go_BYE(-1); }
  // TODO Needs to be kept in wync with qtypes in q_consts.lua
  if ( ( strcmp(field_type, "I1") == 0 ) || 
       ( strcmp(field_type, "I2") == 0 ) || 
       ( strcmp(field_type, "I4") == 0 ) || 
       ( strcmp(field_type, "I8") == 0 ) || 
       ( strcmp(field_type, "F4") == 0 ) || 
       ( strcmp(field_type, "F8") == 0 ) || 
       ( strcmp(field_type, "SC") == 0 ) || 
       ( strcmp(field_type, "SC") == 0 ) ) {
    /* all is well */
  }
  else {
    fprintf(stderr, "Bad field type = [%s] \n", field_type);
    go_BYE(-1);
  }
BYE:
  return status;
}

int
vec_materialized(
    VEC_REC_TYPE *ptr_vec,
    const char *const file_name,
    bool is_read_only
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  bool is_write;

  // Sample error luaL_addstring(&g_errbuf, "hello world"); 

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(-1); }
  if ( strlen(file_name) > Q_MAX_LEN_FILE_NAME ) { go_BYE(-1); }

  if ( is_read_only ) { is_write = false; } else { is_write = true; }
  status = rs_mmap(file_name, &X, &nX, is_write);
  cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  // check nX
  ptr_vec->num_elements = nX / ptr_vec->field_size;
  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
    int64_t n = ptr_vec->num_elements/64;
    if ( ( n * 64 ) != ptr_vec->num_elements ) { n += 64; }
    int64_t num_bytes = n / 8;
    if ( num_bytes < nX ) { go_BYE(-1); }
  }
  else {
    if (( ptr_vec->num_elements * ptr_vec->field_size) != nX ) { 
      go_BYE(-1);
    }
  }
  ptr_vec->map_addr = X;
  ptr_vec->map_len  = nX;
  ptr_vec->is_nascent = false;
  ptr_vec->is_read_only = is_read_only;
  strcpy(ptr_vec->file_name, file_name);

BYE:
  return status;
}

int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char *opbuf
    )
{
  int status = 0;
  // TODO P3 This is slow. Can be speeded up
  char  buf[1024];
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  strcpy(opbuf, "return { ");
  if ( ptr_vec->file_name[0] != '\0' ) {
    sprintf(buf, "file_name = \"%s\", ", ptr_vec->file_name);
    strcat(opbuf, buf);
  }
  sprintf(buf, "field_type = \"%s\", ", ptr_vec->field_type);
  strcat(opbuf, buf);
  sprintf(buf, "field_size = %d, ", ptr_vec->field_size);
  strcat(opbuf, buf);
  sprintf(buf, "is_nascent = %s, ", ptr_vec->is_nascent ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_persist = %s, ", ptr_vec->is_persist ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_memo = %s, ", ptr_vec->is_memo ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_read_only = %s, ", ptr_vec->is_read_only ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_num = %" PRIu32 ", ", ptr_vec->chunk_num);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_size = %" PRIu32 ", ", ptr_vec->chunk_size);
  strcat(opbuf, buf);
  sprintf(buf, "num_in_chunk = %" PRIu32 ", ", ptr_vec->num_in_chunk);
  strcat(opbuf, buf);
  strcat(opbuf, "} ");
BYE:
  return status;
}

int
vec_free(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  // fprintf(stderr, "file = %s \n", ptr_vec->file_name);
  if ( ( ptr_vec->map_addr  != NULL ) && ( ptr_vec->map_len > 0 ) )  {
    munmap(ptr_vec->map_addr, ptr_vec->map_len);
    ptr_vec->map_addr = NULL;
    ptr_vec->map_len  = 0;
  }
  if ( ptr_vec->chunk != NULL ) { 
  // fprintf(stderr, "FREE: chunk = %llu \n", (unsigned long long)ptr_vec->chunk);
    // printf("%8x\n", ptr_vec->chunk);
    free(ptr_vec->chunk);
    ptr_vec->chunk = NULL;
  }
  if ( !ptr_vec->is_persist ) { 
    if ( ptr_vec->file_name[0] != '\0' ) {
      printf("Deleting %s \n", ptr_vec->file_name); 
      status = remove(ptr_vec->file_name); 
      if ( status != 0 ) { 
        printf("Unable to delete %s \n", ptr_vec->file_name); WHEREAMI;
      }
    }
    if ( file_exists(ptr_vec->file_name) ) { go_BYE(-1); }
    memset(ptr_vec->file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  }
  else {
    if ( ptr_vec->file_name[0] != '\0' ) {
      printf("NOT Deleting %s \n", ptr_vec->file_name); 
    }
  }
  // Don't do this in C. Lua will do it: free(ptr_vec);
BYE:
  return status;
}

int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  uint32_t sz = ptr_vec->field_size * ptr_vec->chunk_size;
  ptr_vec->chunk = malloc(sz);
  // fprintf(stderr, "MALLOC: chunk = %llu \n", (unsigned long long)ptr_vec->chunk);
  ptr_vec->is_nascent = true;

BYE:
  return status;
}

int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_size,
    uint32_t chunk_size
    )
{
  int status = 0;

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  if ( field_size == 0 ) { go_BYE(-1); }
  if ( chunk_size == 0 ) { go_BYE(-1); }

  status = chk_field_type(field_type); cBYE(status);
  ptr_vec->field_size = field_size;
  ptr_vec->chunk_size = chunk_size; 
  ptr_vec->is_memo    = true; // default
  strcpy(ptr_vec->field_type, field_type);

BYE:
  return status;
}

bool 
file_exists (
    const char * const filename
    )
{
  int status = 0; struct stat buf;
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
  status = stat(filename, &buf );
  if ( status == 0 ) { /* File found */
    return true;
  }
  else {
    return false;
  }
}

int
vec_check(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  status = chk_field_type(ptr_vec->field_type);
  cBYE(status);
  if ( strcmp(ptr_vec->field_type, "B1") == 0 )  {
    if ( ptr_vec->field_size != 8 ) { go_BYE(-1); }
  }
  else {
    if ( ptr_vec->field_size == 0 ) { go_BYE(-1); }
  }
  if ( strcmp(ptr_vec->field_type, "SC") == 0 )  {
    if ( ptr_vec->field_size < 2 ) { go_BYE(-1); }
  }
  if ( ptr_vec->is_nascent ) {
    if ( ptr_vec->chunk == NULL ) { go_BYE(-1); }
    if ( ( ptr_vec->is_memo == 1 ) && ( ptr_vec->chunk_num >= 1 ) ) {
      status = file_exists(ptr_vec->file_name); cBYE(status);
      int64_t fsz = get_file_size(ptr_vec->file_name); 
      if ( fsz / ptr_vec->field_size != 
          ( ptr_vec->chunk_num * ptr_vec->chunk_size ) ) {
        go_BYE(-1);
      }
    }
    else {
      if ( ptr_vec->file_name[0] != '\0' ) { go_BYE(-1); }
    }
    if ( ptr_vec->num_elements != 
        ( ( ptr_vec->chunk_num * ptr_vec->chunk_size) + 
          ptr_vec->num_in_chunk ) ) {
      go_BYE(-1);
    }
    if ( ptr_vec->map_addr   != NULL ) { go_BYE(-1); }
    if ( ptr_vec->map_len    != 0    ) { go_BYE(-1); }
    if ( ptr_vec->is_persist         ) { go_BYE(-1); }
  }
  else {
    if ( ptr_vec->num_in_chunk != 0    ) { go_BYE(-1); }
    if ( ptr_vec->chunk        != NULL ) { go_BYE(-1); }
    int is_file = file_exists(ptr_vec->file_name); 
    if ( is_file != 1 ) { 
      fprintf(stderr, "File does not exist [%s]\n", ptr_vec->file_name);
      go_BYE(-1); }
    int64_t fsz = get_file_size(ptr_vec->file_name); 
    if ( (uint64_t)(fsz / ptr_vec->field_size) != ptr_vec->num_elements ) {
      go_BYE(-1);
    }
    if ( (uint64_t)fsz !=  ptr_vec->map_len ) { go_BYE(-1); }
    if ( ptr_vec->map_addr == NULL ) { go_BYE(-1); }
  }

BYE:
  return status;
}

int
vec_memo(
    VEC_REC_TYPE *ptr_vec,
    bool is_memo
    )
{
  int status = 0;
  if ( ptr_vec->is_nascent ) {
    if ( ptr_vec->chunk_num >= 1 ) { go_BYE(-1); }
    ptr_vec->is_memo = is_memo;
  }
  else {
    go_BYE(-1);
  }

BYE:
  return status;
}
int
vec_get(
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx, 
    uint32_t len
    )
{
  int status = 0;
  char *addr = NULL;
  ptr_vec->ret_addr = NULL;
  ptr_vec->ret_len  = 0;
  if ( ptr_vec->is_nascent ) {
    uint32_t chunk_num = idx / ptr_vec->chunk_size;
    if ( chunk_num != ptr_vec->chunk_num ) { go_BYE(-1); }
    uint32_t chunk_idx = idx %  ptr_vec->chunk_size;
    if ( chunk_idx + len > ptr_vec->chunk_size ) { go_BYE(-1); }
    addr = ptr_vec->chunk + (chunk_idx * ptr_vec->field_size);
    ptr_vec->ret_len  = mcr_min(len, (ptr_vec->num_in_chunk - chunk_idx));
    /*
     * Consider a following use-case
     * - Create a nascent vector of any type say I4
     *   - Append 10 elements to it (num_in_chunk = 10)
     *   - Get first two elements i.e index=0 and length=2
     *
     *   Is this a valid use-case? 
     *   If yes, then what will the value of ret_len?
     *
     *   I tried this test (test_read_write.lua) and 
     *   my expectation was value of ret_len will be 2
     *   but I got different value i.e 10.
     *
     *   ret_len should be min(ptr_vec->num_in_chunk - chunk_idx, len)
     */
  }
  else {
    if ( idx >= ptr_vec->num_elements ) { go_BYE(-1); }
    if ( idx+len > ptr_vec->num_elements ) { go_BYE(-1); }
    addr = ptr_vec->map_addr + ( idx * ptr_vec->field_size);
    ptr_vec->ret_len  = mcr_min(ptr_vec->num_elements - idx, len);
  }
  ptr_vec->ret_addr = addr; 
BYE:
  return status;
}

int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint64_t idx, 
    uint32_t len,
    bool bit_val // for B1 special case
    )
{
  int status = 0;
  if ( addr == NULL ) { go_BYE(-1); }
  if ( len == 0 ) { go_BYE(-1); }
  if ( ptr_vec->is_nascent ) {
    // idx is implicit for nascent case
    // TODO: PUT THIS BACK if ( idx != 0 ) { go_BYE(-1); }
    uint64_t initial_num_elements = ptr_vec->num_elements;
    uint32_t num_copied = 0;
    for ( uint32_t num_left_to_copy = len; num_left_to_copy > 0; ) {
      uint32_t space_in_chunk = 
        ptr_vec->chunk_size - ptr_vec->num_in_chunk;
      if ( space_in_chunk == 0 )  {
        if ( ptr_vec->is_memo ) {
          if ( ptr_vec->file_name[0] == '\0' ) {
            status = rand_file_name(ptr_vec->file_name, Q_MAX_LEN_FILE_NAME);
            cBYE(status);
          }
          status = buf_to_file(ptr_vec->chunk, ptr_vec->field_size, 
              ptr_vec->num_in_chunk, ptr_vec->file_name);
          cBYE(status);
        }
        ptr_vec->num_in_chunk = 0;
        ptr_vec->chunk_num++;
        memset(ptr_vec->chunk, '\0', 
            (ptr_vec->field_size * ptr_vec->chunk_size));
      }
      else {
        uint32_t num_to_copy = mcr_min(space_in_chunk, len);
        char *dst = ptr_vec->chunk + 
          (ptr_vec->num_in_chunk * ptr_vec->field_size);
        char *src = addr + (num_copied * ptr_vec->field_size);
        memcpy(dst, src, (num_to_copy * ptr_vec->field_size));
        ptr_vec->num_in_chunk += num_to_copy;
        ptr_vec->num_elements += num_to_copy;
        num_left_to_copy      -= num_to_copy;
        num_copied            += num_to_copy;
      }
    }
    if ( num_copied != len ) { go_BYE(-1); }
    if ( ptr_vec->num_elements != initial_num_elements + len) {
      go_BYE(-1);
    }
  }
  else {
    if ( ptr_vec->is_read_only ) { go_BYE(-1); }
    if ( idx >= ptr_vec->num_elements ) { go_BYE(-1); }
    if ( idx+len > ptr_vec->num_elements ) { go_BYE(-1); }
    if ( strcpy(ptr_vec->field_type, "B1") == 0 ) { 
      if ( ( len == 1 ) || ( ( len % 64 ) == 0 ) ) {
        if ( len == 1 ) {
          if ( addr != NULL ) { go_BYE(-1); }
          int64_t word_idx = idx / 64;
          int64_t bit_idx = idx % 64;
          int64_t *X  =(int64_t *)ptr_vec->map_addr;
          if ( bit_val ) { 
            X[word_idx] = X[word_idx] | (1 << bit_idx);
          }
          else {
          }
        }
        else {
          if ( ( idx % 64 ) != 0 ) { go_BYE(-1); }
        }
        // all is well
      }
      else {
        go_BYE(-1);
      }
    }
    else {
      char *dst = ptr_vec->map_addr + ( idx * ptr_vec->field_size);
      memcpy(dst, addr, len * ptr_vec->field_size);
    }
  }
BYE:
  return status;
}

int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    )
{
  int status = 0;
  if ( ptr_vec->is_nascent ) { go_BYE(-1); }
  ptr_vec->is_persist = is_persist;
BYE:
  return status;
}

int
vec_eov(
    VEC_REC_TYPE *ptr_vec,
    bool is_read_only
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;

  if ( ptr_vec->is_nascent == false ) { go_BYE(-1); }
  if ( ptr_vec->chunk == NULL ) { go_BYE(-1); }
  if ( ptr_vec->num_elements == 0 ) { go_BYE(-1); }
  // If memo NOT set, return now; do not persist to disk
  if ( ptr_vec->is_memo == false ) { goto BYE; }
  // this is the case when all data fits into one chunk
  if ( ptr_vec->file_name[0] == '\0' ) {
    status = rand_file_name(ptr_vec->file_name, Q_MAX_LEN_FILE_NAME);
    cBYE(status);
  }
  status = buf_to_file(ptr_vec->chunk, ptr_vec->field_size, 
      ptr_vec->num_in_chunk, ptr_vec->file_name);
  cBYE(status);
  ptr_vec->is_nascent = false;
  free_if_non_null(ptr_vec->chunk);
  ptr_vec->chunk_num = 0;
  ptr_vec->num_in_chunk = 0;

  // open as materialized vector
  bool is_write;
  if ( is_read_only ) { is_write = false; } else { is_write = true; }
  status = rs_mmap(ptr_vec->file_name, &X, &nX, is_write);
  cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  ptr_vec->map_addr = X;
  ptr_vec->map_len  = nX;
  ptr_vec->is_read_only = is_read_only;

BYE:
  return status;
}

int
is_eq_I4(
    void *X,
    int val
    )
{
  int *iptr = (int *)X;
  if ( *iptr == val ) { return 0; } else { return 1; }
}

