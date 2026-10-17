local http = {}

---
---@param domain PluginURL
---@param path string
function http.get(domain, path)
  local zyklib = require("zyklib")

  ---@type zyklib.async.Promise<string>
  local promise = zyklib.async.Promise.new()

  HTTPRequest.new(domain, path)
      :Get(function(req)
        if req.successful then
          promise:resolve(req.data)
        else
          promise:reject(req.errorCode .. ": " .. req.errorInfo)
        end
      end)

  return promise
end

return http
