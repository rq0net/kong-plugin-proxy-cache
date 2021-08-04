--[[
Add hostname to header

curl -X POST http://kong:8001/services/<service-name-or-id>/plugins \
    -d "name=my-custom-plugin" \
    -d "config.environment=development" \
    -d "config.server.host=http://localhost"

]]

local require     = require


local kong             = kong
local ngx              = ngx

local HostnameHandler = {
  VERSION  = "0.0.1",
  PRIORITY = 100,
}



function HostnameHandler:access(conf)
  HostnameHandler.super.access(self)

  kong.response.set_header("x-sitename", ngx.var.hostname)

end

return HostnameHandler
