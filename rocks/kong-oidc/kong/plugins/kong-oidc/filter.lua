local M = {}

local function shouldIgnoreRequest(config)
  if (config.filters) then
    for _, pattern in ipairs(config.filters) do
      local isMatching = not (string.find(ngx.var.uri, pattern) == nil)
      if (isMatching) then return true end
    end
  end
  if (config.allowed_methods) then
    for _, method in ipairs(config.allowed_methods) do
      local isMatching = (method == ngx.req.get_method())
      if (isMatching) then return true end
    end
  end
  if (config.allowed_origins) then
    for _, origin in ipairs(config.allowed_origins) do
      local isMatching = (origin == kong.client.get_forwarded_ip())
      if (isMatching) then return true end
    end
  end
  return false
end

function M.shouldProcessRequest(config)
  return not shouldIgnoreRequest(config)
end

return M
