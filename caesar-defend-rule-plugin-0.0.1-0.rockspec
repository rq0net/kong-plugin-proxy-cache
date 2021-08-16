package = "caesar-defend-rule-plugin"
version = "0.0.1-0"

source = {
  url = "git://github.com/rq0net/kong-plugin-proxy-cache",
  tag = "0.0.8"
}

supported_platforms = {"linux", "macosx"}

description = {
  summary = "Custimize Rules for Kong, Customerize By Caesar",
  license = "Apache 2.0",
}

dependencies = {
  "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.caesar-defend-rule.handler"]              = "kong/plugins/caesar-defend-rule/handler.lua",
    ["kong.plugins.caesar-defend-rule.schema"]               = "kong/plugins/caesar-defend-rule/schema.lua",
  }
}
