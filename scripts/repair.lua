--- @param player_index PlayerIndex
local function cancel(player_index)
  storage.repairing[player_index] = nil
end

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return boolean
local function start(player, entity)
  if not player.mod_settings["moc-enable-repairing"].value then
    return false
  end

  if not entity.health or entity.health == entity.prototype.get_max_health(entity.quality) then
    return false
  end

  storage.repairing[player.index] = entity.position
  return true
end

local function on_tick()
  if not storage.repairing then
    return
  end

  for player_index, position in pairs(storage.repairing) do
    local player = game.get_player(player_index)
    if not player then
      cancel(player_index)
      goto continue
    end
    local entity = player.selected
    if entity and entity.health and entity.health < entity.prototype.get_max_health(entity.quality) then
      player.repair_state = { repairing = true, position = position }
    else
      cancel(player_index)
    end
    ::continue::
  end
end

local function init()
  --- @type table<PlayerIndex, MapPosition>
  storage.repairing = {}
end

--- @class repair_handler : event_handler
local repair_handler = {}

repair_handler.on_init = init
repair_handler.on_configuration_changed = init

repair_handler.events = {
  [defines.events.on_tick] = on_tick,
}

repair_handler.cancel = cancel
repair_handler.start = start

return repair_handler
