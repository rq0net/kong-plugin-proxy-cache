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


function _M:challenge()
    -- ngx.var.testcookie_var = "on"
    res = {}
    res.status = 200
    res.body = "hello"
    res.header.content_type = "text/html"
  
    return res, nil
end
  


return _M
