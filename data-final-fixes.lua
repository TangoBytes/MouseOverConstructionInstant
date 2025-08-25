local flib_prototypes = require("__flib__.prototypes")

--- @type Set<string>
local ignored_entities = {}

for _, entity in pairs(flib_prototypes.all("entity")) do
  if entity.moc_ignore then
    entity.moc_ignore = nil
    ignored_entities[entity.name] = true
  end
end

data:extend({
  {
    type = "mod-data",
    name = "moc-ignored-entities",
    data = ignored_entities,
  },
})
