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
  }
}
