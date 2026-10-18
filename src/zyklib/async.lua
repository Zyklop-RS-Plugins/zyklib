--- @class zyklib.async
local async = {
  Task = require("zyklib/async/Task"),
  Promise = require("zyklib/async/Promise"),
}

function async.async(f)
  local zyklib = require("zyklib")

  local promise = zyklib.async.Promise.new()

  local cor = coroutine.create(function()
    local success, result = pcall(f)
    if success then
      promise:resolve(result)
    else
      promise:reject(result)
    end
  end)

  local ok, err = coroutine.resume(cor)
  if not ok then
    promise:reject(err)
  end

  return promise
end

function async.task(f)
  return async.Task.new(f):start()
end

function async.interval(f, interval)
  local t = async.Task.new(function()
    while true do
      async.Task.maybeYield()
      f()
    end
  end)
  t.timeshare = { ticks = interval }
  return t:start()
end

return async
