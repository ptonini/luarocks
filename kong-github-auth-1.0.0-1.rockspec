package = "kong-github-auth"
version = "1.0.0-1"
source = {
    url = "file:///home/runner/work/luarocks/luarocks/rocks/kong-github-auth.tar.gz",
}
description = {
    summary = "",
    detailed = [[ ]],
    homepage = "https://ptonini.github.io/luarocks",
    license = "Apache 2.0"
}
dependencies = {
    "luasec",
    "luasocket",
    "lua-cjson"
}

build = {
    type = "builtin",
    modules = {
        ["kong.plugins.kong-github-auth.access"] = "kong/plugins/kong-github-auth/access.lua",
        ["kong.plugins.kong-github-auth.handler"] = "kong/plugins/kong-github-auth/handler.lua",
        ["kong.plugins.kong-github-auth.exceptions"] = "kong/plugins/kong-github-auth/exceptions.lua",
        ["kong.plugins.kong-github-auth.schema"] = "kong/plugins/kong-github-auth/schema.lua",
    }
}
