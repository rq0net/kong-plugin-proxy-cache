local cjson = require "cjson.safe"
local anti = require "kong.plugins.caesar-challenge.challenges.anti"


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

function _M:check_authorization(authorization, authorization_dynamic)
    return anti.check_authorization(authorization, authorization_dynamic)
end

function _M:challenge()
    return anti:challenge()
end

return _M