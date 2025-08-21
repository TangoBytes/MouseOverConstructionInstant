local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
  require("scripts.deconstruct"),
  require("scripts.orchestrator"),
  require("scripts.repair"),
  require("scripts.shortcut"),
})
