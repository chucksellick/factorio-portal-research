for i, force in pairs(game.forces) do
  force.reset_technologies()
  force.reset_technology_effects()
end
for i, force in pairs(game.forces) do 
  force.reset_recipes()
end
