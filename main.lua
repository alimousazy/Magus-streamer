local tunnel = require 'tunnel'
local input_block = tunnel.Block(1, function()  end)
local filter_block = tunnel.Block(1, function()  end)
local output_block = tunnel.Block(1, function()  end)
local vector = tunnel.Vector(1000)
local printer = tunnel.Printer()

input_block:add(printer, vector)
filter_block:add(printer, vector)
output_block:add(printer, vector)

input_block:run(
    function (printer, vector) 
     local tailInput = require("tail_input")
      local tail_input = function () 
         local paths = {}
         table.insert(paths, "/Users/aalraha/popo/dem.txt")
         table.insert(paths, "/Users/aalraha/popo/fat.txt")
         input = tailInput:new(paths, vector)
         input:start()
      end
      tail_input()
    end
)

filter_block:run(
  function (printer, vector)
    printer("waiting for input")
    while true do
      printer(vector:popBack())
    end
  end
)


