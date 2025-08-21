--- @class common
local common = {}

--- Builds an entity over the top of an existing entity.
--- @param player LuaPlayer
--- @param entity LuaEntity
--- @param new_prototype LuaEntityPrototype
--- @param new_quality LuaQualityPrototype
--- @return LuaEntity?
function common.build(player, entity, new_prototype, new_quality)
  local item, consume_count = common.get_item(player, new_prototype, new_quality)
  if not item then
    return nil
  end

  local new_entity = player.surface.create_entity({
    name = new_prototype.name,
    position = entity.position,
    direction = entity.direction,
    quality = new_quality,
    force = entity.force,
    fast_replace = true,
    player = player,
    character = player.character,
    raise_built = true,
    create_build_effect_smoke = true,
    spawn_decorations = true,
    move_stuck_players = true,
    item = item,
    register_plant = true,
    --- Undergound belt
    type = entity.type == "underground-belt" and entity.belt_to_ground_type or nil,
  })
  if not new_entity then
    return nil
  end

  item.count = item.count - consume_count

  player.play_sound({
    path = "entity-build/" .. new_entity.name,
    position = new_entity.position,
  })

  return new_entity
end

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @param new_prototype LuaEntityPrototype
--- @return boolean
function common.check_can_place_entity(player, entity, new_prototype)
  -- TODO: Remote interface for mods to conditionally decide if placement is allowed.
  if
    not player.can_place_entity({
      name = new_prototype.name,
      position = entity.position,
      direction = entity.direction,
    })
  then
    storage.recheck_on_move[player.index] = true
    return false
  end
  return true
end

--- Returns the first LuaItemStack that can build the given entity and quality.
--- @param player LuaPlayer
--- @param prototype LuaEntityPrototype
--- @param quality LuaQualityPrototype
--- @return LuaItemStack?, uint?
function common.get_item(player, prototype, quality)
  local cursor_stack = player.cursor_stack
  local inventory = player.get_main_inventory()
  for _, item_to_place in pairs(prototype.items_to_place_this or {}) do
    if
      cursor_stack
      and cursor_stack.valid_for_read
      and cursor_stack.name == item_to_place.name
      and cursor_stack.quality == quality
      and cursor_stack.count >= item_to_place.count
    then
      return cursor_stack, item_to_place.count
    end
    if inventory then
      local item = inventory.find_item_stack({ name = item_to_place.name, quality = quality.name })
      if item and item.count >= item_to_place.count then
        return item, item_to_place.count
      end
    end
  end
end

return common
