package = "caesar-challenge-plugin"
version = "0.0.1-0"

source = {
  url = "git://github.com/rq0net/kong-plugin-proxy-cache",
  tag = "0.0.1"
}

supported_platforms = {"linux", "macosx"}

description = {
  summary = "HTTP Challenge for Kong, Developed By Caesar",
  license = "Apache 2.0",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.caesar-challenge.handler"]              = "kong/plugins/caesar-challenge/handler.lua",
    ["kong.plugins.caesar-challenge.schema"]               = "kong/plugins/caesar-challenge/schema.lua",
    ["kong.plugins.caesar-challenge.challenges"]           = "kong/plugins/caesar-challenge/challenges/init.lua",
    ["kong.plugins.caesar-challenge.challenges.anti"]        = "kong/plugins/caesar-challenge/challenges/anti.lua",
    ["kong.plugins.caesar-challenge.challenges.js"]        = "kong/plugins/caesar-challenge/challenges/js.lua",
    ["kong.plugins.caesar-challenge.challenges.cookie"]    = "kong/plugins/caesar-challenge/challenges/cookie.lua",
    ["kong.plugins.caesar-challenge.challenges.puzzle"]    = "kong/plugins/caesar-challenge/challenges/puzzle.lua"

  }
}
