local cjson = require "cjson.safe"


local ngx          = ngx
local type         = type
local time         = ngx.time
local shared       = ngx.shared
local setmetatable = setmetatable


local _M = {}


  
  
  --- Store a new request entity in the shared memory
  -- @string key The request key
  -- @table req_obj The request object, represented as a table containing
  --   everything that needs to be cached
  -- @int[opt] ttl The TTL for the request; if nil, use default TTL specified
  --   at strategy instantiation time
  function _M:access()
    ngx.var.testcookie_var = "on"
  end

  return _M