---
-- curl -X POST http://kong:8001/services/<service-name-or-id>/plugins \
--    -d "name=my-custom-plugin" \
--    -d "config.environment=development" \
--    -d "config.server.host=http://localhost"
---

local require     = require


local kong             = kong


local CaesarHelloHandler = {
  VERSION  = "0.0.1",
  PRIORITY = 100,
}


function CaesarHelloHandler:init_worker()
  -- Implement logic for the init_worker phase here (http/stream)
  kong.log("init_worker: hello!")
end


function CaesarHelloHandler:access(conf)
  CaesarHelloHandler.super.access(self)

  kong.log.inspect(config.environment) -- "development"
  kong.log.inspect(config.server.host) -- "http://localhost"
  kong.log.inspect(config.server.port) -- 80

end

return CaesarHelloHandler
