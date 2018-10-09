
local T = {}

local function vsgeq(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col = pcall(expander, "vsgeq_val", a, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgeq_val")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsgeq_val', vsgeq)

local function vsgt(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col = pcall(expander, "vsgt_val", a, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgt_val")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsgt_val', vsgt)

local function vsleq(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col = pcall(expander, "vsleq_val", a, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsleq_val")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsleq_val', vsleq)

local function vslt(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col = pcall(expander, "vslt_val", a, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vslt_val")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vslt_val', vslt)

local function vseq(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col = pcall(expander, "vseq_val", a, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vseq_val")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vseq_val', vseq)

local function vsneq(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col = pcall(expander, "vsneq_val", a, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsneq_val")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsneq_val', vsneq)


T.vsgeq_val = vsgeq
T.vsgt_val = vsgt
T.vsleq_val = vsleq
T.vslt_val = vslt
T.vseq_val = vseq
T.vsneq_val = vsneq

return T
