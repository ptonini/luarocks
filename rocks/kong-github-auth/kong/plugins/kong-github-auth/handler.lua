local access = require "kong.plugins.kong-github-auth.access"
local exceptions = require "kong.plugins.kong-github-auth.exceptions"

local GitHubAuthHandler = {
    PRIORITY = 1001,
    VERSION = "0.1.0",
}

function GitHubAuthHandler:access(conf)

    if exceptions.shouldIgnoreRequest(conf) then
        ngx.log(ngx.DEBUG, "GitHubAuthHandler ignoring request, path: " .. ngx.var.request_uri)
    else
        access.execute(conf)
    end

end


return GitHubAuthHandler