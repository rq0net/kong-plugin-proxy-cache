package = "caesar-geoip-plugin"
version = "0.1.0" 
local pluginName = package:match("^(.+)-plugin%$")
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/newageio/kong-plugin-geoip",
  tag = "0.1.0"
}

description = {
  summary = "Working with MaxMind's GeoIP Lib",
  homepage = "http://newage.io",
  license = "MIT"
}

dependencies = {
  'lua-geoip >= 0.2-1'
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}
