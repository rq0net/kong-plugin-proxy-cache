local cjson = require "cjson.safe"


local ngx          = ngx
local type         = type
local time         = ngx.time
local shared       = ngx.shared
local setmetatable = setmetatable


local _M = {}


--- Create new js challange object
-- @table opts Strategy options: contains 'dictionary_name' and 'ttl' fields
function _M.new(opts)
    local self = {
      opts = opts,
    }
  
    return setmetatable(self, {
      __index = _M,
    })
  end

  
return _M
