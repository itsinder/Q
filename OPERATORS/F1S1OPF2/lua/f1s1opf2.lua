local T = {} 
local function vsadd(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsadd", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsadd")
    return col
  end
end
T.vsadd = vsadd
require('Q/q_export').export('vsadd', vsadd)
    
local function vssub(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vssub", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vssub")
    return col
  end
end
T.vssub = vssub
require('Q/q_export').export('vssub', vssub)
    
local function vsmul(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsmul", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsmul")
    return col
  end
end
T.vsmul = vsmul
require('Q/q_export').export('vsmul', vsmul)
    
local function vsdiv(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsdiv", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsdiv")
    return col
  end
end
T.vsdiv = vsdiv
require('Q/q_export').export('vsdiv', vsdiv)
    
local function vsltorgt(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsltorgt", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsltorgt")
    return col
  end
end
T.vsltorgt = vsltorgt
require('Q/q_export').export('vsltorgt', vsltorgt)
    
local function vsleqorgeq(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsleqorgeq", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsleqorgeq")
    return col
  end
end
T.vsleqorgeq = vsleqorgeq
require('Q/q_export').export('vsleqorgeq', vsleqorgeq)
    
local function vsgeqandleq(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsgeqandleq", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgeqandleq")
    return col
  end
end
T.vsgeqandleq = vsgeqandleq
require('Q/q_export').export('vsgeqandleq', vsgeqandleq)
    
local function vsgtandlt(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsgtandlt", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgtandlt")
    return col
  end
end
T.vsgtandlt = vsgtandlt
require('Q/q_export').export('vsgtandlt', vsgtandlt)
    
local function vseq(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vseq", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vseq")
    return col
  end
end
T.vseq = vseq
require('Q/q_export').export('vseq', vseq)
    
local function vsneq(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsneq", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsneq")
    return col
  end
end
T.vsneq = vsneq
require('Q/q_export').export('vsneq', vsneq)
    
local function vsgt(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsgt", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgt")
    return col
  end
end
T.vsgt = vsgt
require('Q/q_export').export('vsgt', vsgt)
    
local function vslt(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vslt", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vslt")
    return col
  end
end
T.vslt = vslt
require('Q/q_export').export('vslt', vslt)
    
local function vsgeq(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsgeq", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgeq")
    return col
  end
end
T.vsgeq = vsgeq
require('Q/q_export').export('vsgeq', vsgeq)
    
local function vsleq(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "vsleq", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsleq")
    return col
  end
end
T.vsleq = vsleq
require('Q/q_export').export('vsleq', vsleq)
    
local function exp(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "exp", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute exp")
    return col
  end
end
T.exp = exp
require('Q/q_export').export('exp', exp)
    
local function log(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "log", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute log")
    return col
  end
end
T.log = log
require('Q/q_export').export('log', log)
    
local function incr(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "incr", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute incr")
    return col
  end
end
T.incr = incr
require('Q/q_export').export('incr', incr)
    
local function decr(x, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "Column" then 
    local status, col = pcall(expander, "decr", x, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute decr")
    return col
  end
end
T.decr = decr
require('Q/q_export').export('decr', decr)
    
return T
