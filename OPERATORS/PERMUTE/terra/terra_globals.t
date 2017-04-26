terra_types = {} 
terra_types['I1'] = int8
terra_types['I2'] = int16
terra_types['I4'] = int32
terra_types['I8'] = int64
terra_types['F4'] = float
terra_types['F8'] = double
terra_types['SV'] = int32
-- terra_types['SC'] = "char"
terra_types['B1'] = uint64  

C = terralib.includec("stdlib.h")

-- TODO belongs in utils
function Array(typ)
    -- TODO HOW TO FREE IT ?!
    return terra(N : int)
        var r : &typ = [&typ](C.malloc(sizeof(typ) * N))
        return r
    end
end

-- TODO added temporarily for use with Terra due to Vector code; discard later
g_chunk_size = nil
g_valid_meta = nil