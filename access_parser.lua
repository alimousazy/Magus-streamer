local l = require 'lpeg'
l.locale(l)

local st = l.P' ' ^ 1 + l.P'\t' ^ 1 
local text = l.C((l.alpha + l.alnum) ^ 1)
local dash = l.P('-')
local time_del = l.P':' 
local number = l.digit^1
local qouted_text = function(pat) return l.P'"' * pat * l.P'"' end
local space = l.P' '^1
local except  = function(pat)  return  (1 - l.S(pat)) ^ 1 end

local ip = l.C((l.digit^1 + l.P'.') ^ 1)
local u_date =  l.Cg(l.digit^1/tonumber, '_day') * l.P'/' * l.Cg(l.alpha^1/tonumber, '_mon') * l.P'/' * l.Cg(number/tonumber, '_year')
local u_time =  l.Cg(number/tonumber, '_hour') * time_del * l.Cg(number/tonumber, '_min') * time_del * l.Cg(number/tonumber, '_sec') * space * l.Cg((l.P'-' ^ -1 * number)/tonumber, '_time_offset')
local time_sec = l.P'[' *  u_date * l.P':' * u_time * l.P']'
local request  = qouted_text(except('"'))
local status  = number 
local size = number 
local resource = qouted_text(except('"'))
local browser = qouted_text(except('"')) 

--127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
local access = l.Ct(
  l.Cg(ip, "_ip") * st *
  l.Cg(text + dash, "_identity") * st *
  l.Cg(text + dash, "_user") * st *
  time_sec * st *
  l.Cg(request, "_request") * st *
  l.Cg(status/tonumber, "_status") * st *
  l.Cg(size/tonumber, "_size") * st *
  l.Cg(resource, "_referer") * st *
  l.Cg(browser, "_user_agent") 
)

local Parser = {
}

function Parser.new(self, o) 
  o = o or {}
  setmetatable(o, Parser)
  self.__index = self
  return o
end

function Parser.parse(self, text) 
  local o =  access:match(text)
  if o ~= nil then
    o.short_message = text
    o.full_message = text
    o.level = 1
    o.version = "1.1"
    o.host = "dododod"
  end
  return o
end

return Parser;

