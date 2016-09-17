local config = {
  paths = {
    ["/Users/aalraha/popo/dem.txt"] = {
      tag = 'access',
    },
  },
  parsers = {
    access = {
      path = "access_parser"
    }
  }
}
local tunnel = require 'tunnel'
local input_block = tunnel.Block(1, function()  end)
local filter_block = tunnel.Block(1, function()  end)
local output_block = tunnel.Block(1, function()  end)
local in_vector = tunnel.Vector(1000)
local out_vector = tunnel.Vector(1000)
local printer = tunnel.Printer()

input_block:add(printer, in_vector)
filter_block:add(printer, in_vector, out_vector)
output_block:add(printer, out_vector)

input_block:run(
    function (printer, vector) 
     local tailInput = require("tail_input")
      local tail_input = function () 
         input = tailInput:new(config.paths, vector)
         input:start()
      end
      tail_input()
    end
)


filter_block:run(
  function (printer, in_vector, out_vector)
   printer("waiting for input")
   local d = require 'pl.pretty' 
   local parsers = {}
   for id, value in pairs(config.parsers) do
     local r = require(value.path)
     parsers[id] = r:new()
   end
   while true do
     local input = in_vector:popBack()
     if parsers[input.tag] then 
       local o = parsers[input.tag]:parse(input.line)
       if o then 
        out_vector:pushBack(o)
       end 
     end 
   end
  end
)
output_block:run(
  function (printer, vector)
   local socket = require("socket")
   local json = require ("dkjson")
   local client = socket.connect("138.68.12.53", 12201)
   while true do
      local msg = vector:popBack()
      client:send(json.encode(msg, {}) .. "\0")
   end
   client:close()
  end
)


