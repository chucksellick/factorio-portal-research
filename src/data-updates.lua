local enable_productivity_recipes = {
  "factorium-processing",
  "portal-control-unit",
  "plexiglass-sheet",
  "plexiglass-lens",
  "vacuum-tube",
  "portal-science-pack",
  "telescope", -- TODO: *Could* be a player-usable item ... for ... what though?,
  "solar-array",
  "navigation-computer",
  "satellite-housing",
  "communication-systems",
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
-- TODO: Move satellites to a secondary tech that needs to be research in addition to Silos. Prequisites include Radio (not necessarily silo...?).
local unlock_silo_recipes = {
  "communication-systems",
  "satellite-housing",
  "navigation-computer",
  "solar-array"
}

for i, recipe in pairs(unlock_silo_recipes) do
  table.insert(data.raw["technology"]["rocket-silo"].effects, {type="unlock-recipe", recipe=recipe})
end

-- Modify base satellite recipe to match the new satellites
local satellite_recipe = data.raw["recipe"]["satellite"]
satellite_recipe.energy_required = 30
satellite_recipe.ingredients = {
  {"satellite-housing", 1},
  {"navigation-computer", 1},
  {"solar-array", 2},
  {"rocket-fuel", 50}
}

local rocket = data.raw["rocket-silo-rocket"]["rocket-silo-rocket"]
table.insert(rocket.result_items, {"space-science-pack", 2000, "solar-harvester"})
table.insert(rocket.result_items, {"space-science-pack", 3000, "portal-lander"})
table.insert(rocket.result_items, {"space-science-pack", 4000, "space-telescope"}) -- Telescopes are great for research!

-- Make labs support our new science pack
-- TODO: Could require a specialised Portal research lab.
table.insert(data.raw.lab.lab.inputs, "portal-science-pack")
