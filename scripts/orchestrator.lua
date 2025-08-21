local flib_position = require("__flib__.position")

local construct = require("scripts.construct")
local deconstruct = require("scripts.deconstruct")
local repair = require("scripts.repair")
local upgrade = require("scripts.upgrade")

--- @param player LuaPlayer
--- @param entity LuaEntity
local function try_execute(player, entity)
  if not storage.mouseover_active[player.index] then
    return
  end

  if not player.can_reach_entity(entity) then
    storage.recheck_on_move[player.index] = player.position
    return
  end

  local cursor_stack = player.cursor_stack
  if not cursor_stack then
    return
  end

  local is_empty = not cursor_stack.valid_for_read
  local is_repair_tool = not is_empty and cursor_stack.type == "repair-tool"

  local upgrade_prototype, upgrade_quality = entity.get_upgrade_target()
  local entity_name, entity_quality = entity.name, entity.quality
  if upgrade_prototype then
    --- @cast upgrade_quality -?
    entity_name = upgrade_prototype.name
    entity_quality = upgrade_quality
  elseif entity.type == "entity-ghost" then
    entity_name = entity.ghost_name
  end
  local matches_selected = not is_empty
    and cursor_stack.prototype.place_result
    and cursor_stack.prototype.place_result.name == entity_name
    and cursor_stack.quality == entity_quality

  local should_execute = matches_selected or is_empty or is_repair_tool

  if not should_execute then
    return
  end

  if construct(player, entity) then
    return
  end

  if is_repair_tool and repair.start(player, entity) then
    return
  end

  if upgrade(player, entity) then
    return
  end

  deconstruct.start(player, entity)
end

--- @param e EventData.on_selected_entity_changed
local function on_selected_entity_changed(e)
  deconstruct.cancel(e.player_index)
  repair.cancel(e.player_index)
  storage.recheck_on_move[e.player_index] = nil

  local player = game.get_player(e.player_index)
  --- @cast player -?

  local selected = player.selected
  if not selected then
    return
  end

  try_execute(player, selected)
end

local function on_tick()
  for player_index, last_position in pairs(storage.recheck_on_move) do
    if not storage.mouseover_active[player_index] then
      storage.recheck_on_move[player_index] = nil
      goto continue
    end

    local player = game.get_player(player_index)
    if not player then
      storage.recheck_on_move[player_index] = nil
      goto continue
    end

    if flib_position.eq(player.position, last_position) then
      goto continue
    end

    local selected = player.selected
    if not selected then
      storage.recheck_on_move[player_index] = nil
      goto continue
    end

    storage.recheck_on_move[player_index] = nil

    try_execute(player, selected)

    ::continue::
  end
end

--- @class orchestrator_handler : event_handler
local orchestrator_handler = {}

function orchestrator_handler.on_init()
  --- @type table<PlayerIndex, MapPosition>
  storage.recheck_on_move = {}
end

orchestrator_handler.events = {
  [defines.events.on_selected_entity_changed] = on_selected_entity_changed,
  [defines.events.on_tick] = on_tick,
}

return orchestrator_handler
