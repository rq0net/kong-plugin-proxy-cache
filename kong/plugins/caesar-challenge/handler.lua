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

CaesarChallengeHandler.VERSION  = "0.0.9"
CaesarChallengeHandler.PRIORITY = 90

local CHALLENGE_PATH = "kong.plugins.caesar-challenge.challenges"

-- function CaesarChallengeHandler:init_worker()
--   -- Implement logic for the init_worker phase here (http/stream)
--   kong.log.info("init_worker: test challenge!")
-- end

-- function CaesarChallengeHandler:rewrite(config)
--   CaesarChallengeHandler.super.preread(self)
-- end

-- https://stackoverflow.com/questions/64301671/how-to-set-proxy-http-version-in-lua-code-before-upstreaming-the-request-in-ngin
function CaesarChallengeHandler:access(conf)
  -- try to fetch the cached object from the computed cache key
  local challenge = require(CHALLENGE_PATH)({
    challenge_name = conf.challenge,
    challenge_opts = conf[conf.challenge],
  })

  local res, err = challenge:grant_access()
  if res == ngx.OK then
    return --Go to content
  elseif res then
    return kong.response.exit(res.status, res.body, res.headers)
  end

  res, err = challenge:challenge()
  if res then
    return kong.response.exit(res.status, res.body, res.headers)
  end

end

return CaesarChallengeHandler
