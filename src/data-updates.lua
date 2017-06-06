enable_productivity_recipes = {
  "factorium-processing",
  "portal-control-unit",
  "plexiglass-lens",
  "portal-science-pack",
  "telescope" -- TODO: *Could* be a player-usable item ... for ... what though?
}

for k, v in pairs(data.raw.module) do
  if v.name:find("productivity%-module") and v.limitation then
    for _, recipe in ipairs(enable_productivity_recipes) do
      if data.raw["recipe"][recipe] then
        table.insert(v.limitation, recipe)
      end
    end
  end
end

-- TODO: Could require a specialised Portal research lab.
table.insert(data.raw.lab.lab.inputs, "portal-science-pack")