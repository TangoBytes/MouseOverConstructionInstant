--- @param player_index PlayerIndex
local function cancel(player_index)
  storage.deconstructing[player_index] = nil
end

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return boolean started
local function start(player, entity)
  if not (entity and entity.valid) then return false end
  if not player.mod_settings["moc-enable-deconstruction"].value then return false end
  if not entity.to_be_deconstructed() then return false end

  -- If the entity belongs to the player’s force, attempt instant mine
  if entity.force and entity.force == player.force then
    local ok = player.mine_entity(entity)
    -- If it succeeds, we're done — no need for the timed mining
    if ok then
      player.play_sound{ path = "utility/deconstruct_robot" }
      storage.deconstructing[player.index] = nil
      return true
    end
    -- If it fails (inventory full, unreachable, etc.), fall through to timed
  end

  -- Default: timed mining (progress bar behavior)
  storage.deconstructing[player.index] = entity.position
  return true
end


local function on_tick()
  if not storage.deconstructing then
    return
  end

  for player_index, position in pairs(storage.deconstructing) do
    local player = game.get_player(player_index)
    if not player then
      cancel(player_index)
      goto continue
    end

    player.mining_state = { mining = true, position = position }
    ::continue::
  end
end

local function init()
  --- @type table<PlayerIndex, MapPosition>
  storage.deconstructing = {}
end

--- @class deconstruct_handler : event_handler
local deconstruct_handler = {}

deconstruct_handler.on_init = init
deconstruct_handler.on_configuration_changed = init

deconstruct_handler.events = {
  [defines.events.on_tick] = on_tick,
}

deconstruct_handler.cancel = cancel
deconstruct_handler.start = start

return deconstruct_handler
