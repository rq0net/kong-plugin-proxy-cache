package = "caesar-geoip-plugin"
version = "0.1.0-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/rq0net/kong-plugin-proxy-cache",
  tag = "0.1.0"
}

description = {
  summary = "Working with MaxMind's GeoIP Lib",
  license = "MIT"
}

dependencies = {
  'lua-geoip >= 0.2-1'
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.caesar-geoip.handler"] = "kong/plugins/caesar-geoip/handler.lua",
    ["kong.plugins.caesar-geoip.schema"] = "kong/plugins/caesar-geoip/schema.lua",
  }
}
