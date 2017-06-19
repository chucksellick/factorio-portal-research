for i, force in pairs(game.forces) do
  force.reset_technologies()
  force.reset_technology_effects()
  force.reset_recipes()
end
