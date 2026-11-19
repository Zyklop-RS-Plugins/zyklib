--- Reports errors that zyklib catches to keep the rest of the plugin running, such as a failing event listener.
--- Each distinct error is printed once, as a failure that repeats on every tick would otherwise flood the console.
---
--- !doctype module
--- @class zyklib.errors
local errors = {}

-- Distinct errors printed at most, so the table of printed errors can't grow without bound.
local MAX_REPORTED = 100

--- @type table<string, boolean>
local reported = {}
local reported_count = 0

--- Prints an error caught by zyklib to the console, tagged with the plugin's name, unless the same error was printed
--- before.
--- @param context string What failed, e.g. "event listener failed"
--- @param err any The caught error
function errors.report(context, err)
  local message = tostring(err)
  -- Keyed by the first line, which holds the error and where it was raised, but not a stack trace that may differ.
  local key = context .. "\n" .. message:match("^[^\n]*")
  if reported[key] or reported_count > MAX_REPORTED then return end

  reported_count = reported_count + 1
  if reported_count > MAX_REPORTED then
    log("%s", "ERROR [zyklib] more than " .. MAX_REPORTED .. " different errors, further errors are not printed")
    return
  end

  reported[key] = true
  -- Through "%s", as log takes a format string and the message may contain a "%".
  log("%s", "ERROR [zyklib] " .. context .. ": " .. message)
end

return errors
