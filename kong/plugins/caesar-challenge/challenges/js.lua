local cjson = require "cjson.safe"
local anti = require "kong.plugins.caesar-challenge.challenges.anti_ddos_challenge"

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
  res.status = anti.authentication_page_status_output
  res.body = anti.anti_ddos_html_output
  res.header.content_type = "text/html; charset=" .. anti.default_charset

  return res
end

return _M