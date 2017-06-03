for i, force in pairs(game.forces) do
  force.reset_technologies()
end
for i, force in pairs(game.forces) do 
  force.reset_recipes()
end
for i, force in pairs(game.forces) do 
 if force.technologies["portal-research"].researched then 
   force.recipes["portal-control-unit"].enabled = true
   force.recipes["medium-portal"].enabled = true
   force.recipes["portal-lander"].enabled = true
 end
end
