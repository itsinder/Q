#!/bin/bash
curl -XPOST --url "http://localhost:8000/Restore?FileName=foo.meta.lua"

curl -XPOST --url "http://localhost:8000/Dummy?ABC=123" --data 'x = Q.mk_col({1,2,3}, "I4")'
