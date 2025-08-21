-- TODO: Execute logic if enabled while entity is selected.
-- TODO: Cancel logic if disabled while entity is selected.

--- @param e EventData.on_lua_shortcut|EventData.CustomInputEvent
local function toggle_mouseover(e)
  local name = e.input_name or e.prototype_name
  if name ~= "moc-toggle" then
    return
  end
  local player = game.get_player(e.player_index)
  if not player then
    return
  end
  local new_value = not storage.mouseover_active[e.player_index]
  storage.mouseover_active[e.player_index] = new_value
  player.set_shortcut_toggled("moc-toggle", new_value)
  if e.input_name then
    player.create_local_flying_text({
      text = new_value and { "message.moc-enabled" } or { "message.moc-disabled" },
      create_at_cursor = true,
    })
  end
end

--- @class shortcut_handler : event_handler
local shortcut_handler = {}

function shortcut_handler.on_init()
  --- @type Set<PlayerIndex>
  storage.mouseover_active = {}
  for _, player in pairs(game.players) do
    player.set_shortcut_toggled("moc-toggle", false)
  end
end

shortcut_handler.on_configuration_changed = shortcut_handler.on_init

shortcut_handler.events = {
  [defines.events.on_lua_shortcut] = toggle_mouseover,
  ["moc-toggle"] = toggle_mouseover,
}

return shortcut_handler
