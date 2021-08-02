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
    ["caesar.plugins.proxy-cache.handler"]              = "caesar/plugins/proxy-cache/handler.lua",
    ["caesar.plugins.proxy-cache.cache_key"]            = "caesar/plugins/proxy-cache/cache_key.lua",
    ["caesar.plugins.proxy-cache.schema"]               = "caesar/plugins/proxy-cache/schema.lua",
    ["caesar.plugins.proxy-cache.api"]                  = "caesar/plugins/proxy-cache/api.lua",
    ["caesar.plugins.proxy-cache.strategies"]           = "caesar/plugins/proxy-cache/strategies/init.lua",
    ["caesar.plugins.proxy-cache.strategies.memory"]    = "caesar/plugins/proxy-cache/strategies/memory.lua",
    ["caesar.plugins.proxy-cache.strategies.redis"]    = "caesar/plugins/proxy-cache/strategies/redis.lua",
    ["caesar.plugins.proxy-cache.strategies.file"]    = "caesar/plugins/proxy-cache/strategies/file.lua",
  }
}
