local common = require("scripts.common")

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return boolean
return function(player, entity)
  if not player.mod_settings["moc-enable-construction"].value then
    return false
  end

  if entity.type ~= "entity-ghost" then
    return false
  end

  if
    not player.can_place_entity({
      name = entity.ghost_name,
      position = entity.position,
      direction = entity.direction,
    })
  then
    storage.recheck_on_move[player.index] = player.position
    return false
  end

  local new_entity = common.build(player, entity, entity.ghost_prototype --[[@as LuaEntityPrototype]], entity.quality)

  return new_entity and true or false
end
