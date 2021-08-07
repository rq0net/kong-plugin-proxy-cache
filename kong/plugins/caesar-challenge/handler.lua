---
-- curl -X POST http://kong:8001/services/<service-name-or-id>/plugins \
--    -d "name=my-custom-plugin" \
--    -d "config.environment=development" \
--    -d "config.server.host=http://localhost"
---

local require     = require
local kong        = kong
local BasePlugin  = require "kong.plugins.base_plugin"


local CaesarChallengeHandler = BasePlugin:extend()

CaesarChallengeHandler.VERSION  = "0.0.2"
CaesarChallengeHandler.PRIORITY = 100


function CaesarChallengeHandler:init_worker()
  -- Implement logic for the init_worker phase here (http/stream)
  kong.log.err("init_worker: test challenge!")
  ngx.var.testcookie_var = "on"
end


function CaesarChallengeHandler:rewrite(config)
  -- Implement logic for the rewrite phase here (http)
  kong.log.err("test rewrite")
  CaesarChallengeHandler.super.preread(self)
end


-- https://stackoverflow.com/questions/64301671/how-to-set-proxy-http-version-in-lua-code-before-upstreaming-the-request-in-ngin
function CaesarChallengeHandler:access(conf)
  kong.log.err("access: testcookie!")
  ngx.var.testcookie_var = "on"

  local res = ngx.location.capture("@testcookie")
  if res then
      ngx.say("status: ", res.status)
      ngx.say("body:")
      ngx.print(res.body)
      return
  end

  CaesarChallengeHandler.super.access(self)
end

return CaesarChallengeHandler
