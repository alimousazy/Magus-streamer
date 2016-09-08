local lfs = require('lfs')
local ffi = require('ffi')
local fswatch = require("fswatch")


local TailInput = {
  position = {
  },
}

function TailInput.new(self, paths, output, o) 
  o = o or {}
  setmetatable(o, TailInput)
  self.__index = self
  for id, x in ipairs(paths) do 
    attr = lfs.attributes(x)
    if attr ~= nil then 
      o.position[x] = attr.size
    end
  end 
  o.paths = paths
  o.output = output
  return o
end

function TailInput.start(self) 
  local fsw = fswatch:new()
  local position = self.position
  local output = self.output
  local onFileChange = function(list, ids, obj) 
    for x=0, ids - 1 do 
      local event = list[x]
      local eventType = {}
      local path  = ffi.string(event.path)
      local x = 1
      for x=0, event.flags_num  - 1 do 
        local etype = tonumber(event.flags[x])
        eventType[fswatch.eventFlags[etype]] = 1
      end
      if eventType['Removed'] ~= nil then
        position[path] = nil
        return 
      elseif eventType['Created'] ~= nil then
        position[path] = 0
      end
      local sem = io.open(path, "r")
      local size = sem:seek("end")
      if position[path] > size then
        position[path] = 0
      end
      local size = sem:seek("set", position[path])
      local line = sem:read()
      while  line ~= nil do
        output:pushBack(line)
        line = sem:read()
      end
      position[path] = sem:seek("end")
      sem:close()
    end
  end
  for i, x in  ipairs(self.paths) do 
   fsw:add_path(x)
  end
  fsw:set_callback(onFileChange, nil)
  fsw:start_monitor()
end

return TailInput
