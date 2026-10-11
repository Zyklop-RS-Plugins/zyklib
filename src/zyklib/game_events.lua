--- Events and observables that originate from the game.
---
--- !doctype module
--- @class zyklib.game_events
local game_events = {
  native = require "zyklib/game_events/native",
  derived = require "zyklib/game_events/derived",
}

return game_events
