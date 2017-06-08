local enable_productivity_recipes = {
  "factorium-processing",
  "portal-control-unit",
  "plexiglass-lens",
  "portal-science-pack",
  "telescope", -- TODO: *Could* be a player-usable item ... for ... what though?,
  "solar-array",
  "navigation-computer",
  "satellite-housing",
  "communications-system"
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

-- Some additional components need to be available to build satellites
local unlock_silo_recipes = {
  -- "communications-system" or "communication-systems" ??
  -- "satellite-housing"
  "navigation-computer",
  "solar-array"
}

for i, recipe in pairs(unlock_silo_recipes) do
  table.insert(data.raw["technology"]["rocket-silo"].effects, {type="unlock-recipe", recipe=recipe})
end

-- TODO: Could require a specialised Portal research lab.
table.insert(data.raw.lab.lab.inputs, "portal-science-pack")