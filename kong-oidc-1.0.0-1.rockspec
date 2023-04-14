package = "kong-oidc"
version = "1.0.0-1"
source = {
    url = "file:///home/runner/work/luarocks/luarocks/rocks/kong-oidc.tar.gz",
}
description = {
    summary = "A Kong plugin for implementing the OpenID Connect Relying Party (RP) functionality",
    homepage = "https://github.com/ptonini/luarocks",
    license = "Apache 2.0"
}
dependencies = {
    "lua-resty-openidc ~> 1.6.1-1"
}
build = {
    type = "builtin",
    modules = {
        ["kong.plugins.kong-oidc.filter"]  = "kong/plugins/kong-oidc/filter.lua",
        ["kong.plugins.kong-oidc.handler"] = "kong/plugins/kong-oidc/handler.lua",
        ["kong.plugins.kong-oidc.schema"]  = "kong/plugins/kong-oidc/schema.lua",
        ["kong.plugins.kong-oidc.session"] = "kong/plugins/kong-oidc/session.lua",
        ["kong.plugins.kong-oidc.utils"]   = "kong/plugins/kong-oidc/utils.lua"
    }
}
