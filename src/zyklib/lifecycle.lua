local reactive = require "zyklib/reactive"

---Plugin lifecycle handling, such as shutdown notification.
---
---!doctype module
---@class zyklib.lifecycle
local lifecycle = {}

---The shutdown event.
---@type zyklib.Event<nil, nil>
lifecycle.shutdown_event = reactive.Event.new()

---Set up the global PluginShutdown function to automatically be notified of the shutdown.
---If a global PluginShutdown already exists, it will also be called as part of the new shutdown function
function lifecycle.setupGlobals()
  -- Save any existing PluginShutdown
  local old_global = PluginShutdown

  -- Set up the global function to hook into the lifecycle call
  function PluginShutdown()
    if old_global ~= nil then
      old_global()
    end

    lifecycle.notifyShutdown()
  end
end

local is_shutting_down = false

---Manually notify the shutdown event. Use this when you have a custom PluginShutdown function.
function lifecycle.notifyShutdown()
  -- Ensure that the event is only triggered once, even if the user calls this function more than once.
  if not is_shutting_down then
    is_shutting_down = true
    lifecycle.shutdown_event:trigger(nil)
  end
end

return lifecycle
