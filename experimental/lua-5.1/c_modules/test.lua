local mod = require 'sayhi'
mod = require 'sayhi'
mod.fn()

fn, err = package.loadlib('./libtime.so','luaopen_time')

print(type(fn))

time = require 'time'
