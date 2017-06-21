for i, force in pairs(game.forces) do
  force.reset_technologies()
  force.reset_recipes()
  if force.technologies["rocket-silo"] and force.technologies["rocket-silo"].researched then
    -- Some additional components need to be available to build satellites
    local unlock_silo_recipes = {
      "communication-systems",
      "satellite-housing",
      "navigation-computer",
      "solar-array"
    }
    for i,t in pairs(unlock_silo_recipes) do
      force.recipes[t].enabled = true
    end
  end
end
