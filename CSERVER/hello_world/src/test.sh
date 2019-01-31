#!/bin/bash
# curl -XPOST --url "http://localhost:8000/Restore?FileName=foo.meta.lua"
# curl -XPOST --url \
# "http://localhost:8000/Execute?FileName=batch_job.lua&Param1=xxx"

curl -XPOST --url "http://localhost:8000/Dummy?ABC=123"  \
  --data 'y = Q.mk_col({1,2,3}, "F4");'

curl -XPOST --url "http://localhost:8000/Dummy?ABC=123"  \
  --data 'Q.print_csv(y)'

curl -XPOST --url "http://localhost:8000/Dummy?ABC=123"  \
  --data 'print(y:fldtype())'
