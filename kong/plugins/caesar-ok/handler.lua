---
-- curl -X POST http://kong:8001/services/<service-name-or-id>/plugins \
--    -d "name=my-custom-plugin" \
--    -d "config.environment=development" \
--    -d "config.server.host=http://localhost"
---

local require     = require
local kong        = kong
local ngx         = ngx
local BasePlugin  = require "kong.plugins.base_plugin"

local CaesarOkHandler = BasePlugin:extend()

CaesarOkHandler.VERSION  = "0.0.1"
CaesarOkHandler.PRIORITY = 100

function CaesarOkHandler:access(conf)
  if kong.request.get_path() == "/ok" then
    ngx.status = ngx.HTTP_OK
    ngx.say("ok")
    ngx.exit(ngx.HTTP_OK)
  end
end

return CaesarOkHandler
