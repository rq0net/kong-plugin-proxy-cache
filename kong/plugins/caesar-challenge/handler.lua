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


local CHALLENGE_PATH = "kong.plugins.caesar-challenge.challenges"


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
  kong.log.err("access: caesar challenges!")

  kong.log.err("access: caesar challenges!" .. conf.challenge .. conf[conf.challenge].dictionary_name)

  local secret = " abcdefg"

  -- try to fetch the cached object from the computed cache key
  local challenge = require(CHALLENGE_PATH)({
    challenge_name = conf.challenge,
    challenge_opts = conf[conf.challenge],
  })

  local res, err = challenge:challenge()

  --if res then
  return kong.response.exit(res.status, res.body, res.headers)
  

end

return CaesarChallengeHandler
