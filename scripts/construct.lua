local common = require("scripts.common")

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return boolean
return function(player, entity)
  if not entity.valid then
    return false
  end

  if not player.mod_settings["moc-enable-construction"].value then
    return false
  end

  if entity.type ~= "entity-ghost" then
    return false
  end

  local entity_prototype = entity.ghost_prototype --[[@as LuaEntityPrototype]]

  if not common.check_can_place_entity(player, entity, entity_prototype) then
    return false
  end

  local new_entity = common.build(player, entity, entity_prototype, entity.quality)

  return new_entity and new_entity.valid and true or false
end
