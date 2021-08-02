package = "caesar-hostname-plugin"
version = "0.0.1-0"

source = {
  url = "git://github.com/rq0net/kong-plugin-proxy-cache",
  tag = "0.0.1"
}

supported_platforms = {"linux", "macosx"}

description = {
  summary = "Add hostname in header",
  license = "Apache 2.0",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.caesar-hostname.handler"]              = "kong/plugins/caesar-hostname/handler.lua",
    ["kong.plugins.caesar-hostname.schema"]               = "kong/plugins/caesar-hostname/schema.lua",
  }
}
