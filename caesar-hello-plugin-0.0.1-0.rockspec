package = "caesar-hello-plugin"
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
    ["kong.plugins.caesar-hello.handler"]              = "kong/plugins/caesar-hello/handler.lua",
    ["kong.plugins.caesar-hello.schema"]               = "kong/plugins/caesar-hello/schema.lua",
  }
}
