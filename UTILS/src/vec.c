#include "q_incs.h"
#include "mmap_types.h"
#include "vec.h"
#include "_mmap.h"
#include "_rand_file_name.h"
#include "_get_file_size.h"

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
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(-1); }

  if ( is_read_only ) { is_write = false; } else { is_write = true; }
  status = rs_mmap(file_name, &X, &nX, is_write);
  cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  // check nX
  ptr_vec->num_elements = nX / ptr_vec->field_size;
  if (( ptr_vec->num_elements * ptr_vec->field_size) != nX ) { go_BYE(-1);}
  ptr_vec->map_addr = X;
  ptr_vec->map_len  = nX;
  ptr_vec->is_nascent = false;
  ptr_vec->is_read_only = is_read_only;

BYE:
  return status;
}

int
vec_free(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ( ptr_vec->map_addr  != NULL ) && ( ptr_vec->map_len > 0 ) )  {
    munmap(ptr_vec->map_addr, ptr_vec->map_len);
  }
  if ( ptr_vec->chunk != NULL ) { 
    free(ptr_vec->chunk);
  }
  if ( ptr_vec->is_persist != 1 ) {
    if ( ptr_vec->file_name[0] != '\0' ) {
      status = remove(ptr_vec->file_name); cBYE(status);
    }
    if ( file_exists(ptr_vec->file_name) ) { go_BYE(-1); }
  }
  free(ptr_vec);
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
  ptr_vec->is_nascent = true;

BYE:
  return status;
}

VEC_REC_TYPE *
vec_new(
    const char * const field_type,
    uint32_t field_size,
    uint32_t chunk_size
    )
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;

  if ( field_size == 0 ) { go_BYE(-1); }
  if ( chunk_size == 0 ) { go_BYE(-1); }

  status = chk_field_type(field_type); cBYE(status);

  ptr_vec = malloc(sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));

  ptr_vec->field_size = field_size;
  ptr_vec->chunk_size = chunk_size; 
  strcpy(ptr_vec->field_type, field_type);

BYE:
  if ( status == 0 ) { return ptr_vec; } else { return NULL; }
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
  if ( ptr_vec->field_size == 0 ) { go_BYE(-1); }
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
    if ( ptr_vec->is_persist != 0    ) { go_BYE(-1); }
  }
  else {
    if ( ptr_vec->num_in_chunk != 0    ) { go_BYE(-1); }
    if ( ptr_vec->chunk        != NULL ) { go_BYE(-1); }
    status = file_exists(ptr_vec->file_name); cBYE(status);
    int64_t fsz = get_file_size(ptr_vec->file_name); 
    if ( fsz / ptr_vec->field_size != ptr_vec->num_elements ) {
      go_BYE(-1);
    }
    if ( (uint64_t)fsz !=  ptr_vec->map_len ) { go_BYE(-1); }
    if ( ptr_vec->map_addr == NULL ) { go_BYE(-1); }
  }

BYE:
  return status;
}

int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char *addr, 
    uint64_t idx, 
    uint32_t len
    )
{
  int status = 0;
  if ( addr == NULL ) { go_BYE(-1); }
  if ( len == 0 ) { go_BYE(-1); }
  if ( ptr_vec->is_nascent ) {
    if ( idx != 0 ) { go_BYE(-1); }
    uint64_t initial_num_elements = ptr_vec->num_elements;
    uint32_t num_left_to_copy = len;
    for ( ; ; ) {
      /*
         local space_in_chunk = qconsts.chunk_size - self._num_in_chunk
         if ( space_in_chunk == 0 )  then
         if ( self._is_memo ) then
         if ( not self._file_name ) then 
         local sz = qconsts.max_len_file_name + 1
         -- self._file_name = ffi.new("char[?]", sz)
         self._file_name = ffi.malloc(sz, qc.c_free)
         assert(self._file_name)
         ffi.fill(self._file_name, sz)
         qc['rand_file_name'](self._file_name, qconsts.max_len_file_name)
         end
         local use_c_code = true
         if ( use_c_code ) then 
         local status = qc["buf_to_file"](self._chunk,
         self._field_size, self._num_in_chunk, self._file_name)
         else 
         local fp = ffi.C.fopen(self._file_name, "a")
         print("L: Opened file")
         local nw = ffi.C.fwrite(self._chunk, self._field_size, 
         qconsts.chunk_size, fp);
         print("L: Wrote to file")
         -- assert(nw > 0 )
         ffi.C.fclose(fp)
         print("L: Done with file")
         end
         end
         self._num_in_chunk = 0
         self._chunk_num = self._chunk_num + 1
         space_in_chunk = qconsts.chunk_size
         ffi.fill(self._chunk, qconsts.chunk_size * self._field_size, 0)
         end

         local num_to_copy  = len
         if ( space_in_chunk < len ) then 
         num_to_copy = space_in_chunk
         end
         qc["c_copy"](self._chunk, addr, self._num_in_chunk, num_to_copy, 
         self._field_size)
         --[[ Not sure why following does not work.
         local dst = ffi.cast("char *", self._chunk) 
         + (self._num_in_chunk * self._field_size)
         ffi.copy(dst, addr, num_to_copy * self._field_size)
         --]]

         num_left_to_copy = num_left_to_copy - num_to_copy
         self._num_in_chunk = self._num_in_chunk + num_to_copy
         self._num_elements = self._num_elements + num_to_copy
         until num_left_to_copy == 0
         */
    }
    if ( ptr_vec->num_elements != initial_num_elements + len) {
      go_BYE(-1);
    }
  }
  else {
  }
}

  /*
     else
     print(self._is_nascent)
     os.exit()
     assert(self._is_write == true)
     assert(idx)
     assert(type(idx) == "number")
     assert(idx >= 0)
     assert(self._mmap)
     assert(idx < self._num_elements)
     assert(idx+len < self._num_elements)
     local dst = self._mmap.map_addr + (idx * self._field_size)
     local n = len * self._field_size
     ffi.copy(dst, addr, n)
     end
     if ( qconsts.debug ) then self:check() end
     end
     */
BYE:
  return status;
}
