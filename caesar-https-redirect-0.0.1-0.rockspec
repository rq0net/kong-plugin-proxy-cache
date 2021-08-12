package = "caesar-https-redirect"
version = "0.0.1-0"
source = {
    url = "git://github.com/HappyValleyIO/kong-http-to-https-redirect",
    branch = "master"
}
description = {
    summary = "A Kong plugin for redirecting HTTP traffic to HTTPS.",
    detailed = [[
      Redirects traffic from HTTP to HTTPS (currently only offers 301 redirect).
    ]],
    homepage = "https://github.com/HappyValleyIO/kong-http-to-https-redirect",
    license = "MIT"
}
dependencies = {
}
build = {
    type = "builtin",
    modules = {
    ["kong.plugins.caesar-https-redirectt.handler"] = "kong/plugins/caesar-https-redirect/handler.lua",
    ["kong.plugins.caesar-https-redirect.schema"] = "kong/plugins/caesar-https-redirect/schema.lua",
    }
}
