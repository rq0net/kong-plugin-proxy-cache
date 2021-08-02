package = "caesar-proxy-cache-plugin"
version = "0.0.1-0"

source = {
  url = "git://github.com/rq0net/kong-plugin-proxy-cache",
  tag = "0.0.1"
}

supported_platforms = {"linux", "macosx"}

description = {
  summary = "HTTP Proxy Caching for Kong, Customerize By Caesar",
  license = "Apache 2.0",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.caesar-proxy-cache.handler"]              = "caesar/plugins/proxy-cache/handler.lua",
    ["kong.plugins.caesar-proxy-cache.cache_key"]            = "caesar/plugins/proxy-cache/cache_key.lua",
    ["kong.plugins.caesar-proxy-cache.schema"]               = "caesar/plugins/proxy-cache/schema.lua",
    ["kong.plugins.caesar-proxy-cache.api"]                  = "caesar/plugins/proxy-cache/api.lua",
    ["kong.plugins.caesar-proxy-cache.strategies"]           = "caesar/plugins/proxy-cache/strategies/init.lua",
    ["kong.plugins.caesar-proxy-cache.strategies.memory"]    = "caesar/plugins/proxy-cache/strategies/memory.lua",
    ["kong.plugins.caesar-proxy-cache.strategies.redis"]    = "caesar/plugins/proxy-cache/strategies/redis.lua",
    ["kong.plugins.caesar-proxy-cache.strategies.file"]    = "caesar/plugins/proxy-cache/strategies/file.lua",
  }
}
