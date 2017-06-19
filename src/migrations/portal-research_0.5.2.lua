for i, force in pairs(game.forces) do
  force.reset_technologies()
  force.reset_recipes()
  if force.technology["rocket-silo"] and force.technology["rocket-silo"].researched then
  -- Some additional components need to be available to build satellites
  local unlock_silo_recipes = {
    -- "communications-system" or "communication-systems" ??
    -- "satellite-housing"
    "navigation-computer",
    "solar-array"
  }
  for i,t in unlock_silo_recipes do
    force.recipes[t].enabled = true
  end
end
