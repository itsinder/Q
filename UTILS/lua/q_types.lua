local dictionary = require 'Q/UTILS/lua/dictionary'
local lVector    = require 'Q/RUNTIME/lua/lVector'
local lScalar    = require 'Q/RUNTIME/lua/lScalar'
local Reducer    = require 'Q/RUNTIME/lua/Reducer.lua'
local Scalar     = require 'libsclr'

local original_type = type

type = function(obj)
  local m_table = getmetatable(obj)
  if m_table ~= nil then
    if m_table == dictionary then
      return "Dictionary"
    elseif m_table == lVector then
      return "lVector"
    elseif m_table == lScalar then
      return "lScalar"
    elseif m_table == Scalar then
      return "Scalar"
    elseif m_table == Reducer then
      return "Reducer"
    end
  end
  return original_type(obj)
end
