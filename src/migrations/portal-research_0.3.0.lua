for i, force in pairs(game.forces) do
  force.reset_technologies()
end
for i, force in pairs(game.forces) do 
  force.reset_recipes()
end
for i, force in pairs(game.forces) do 
 if force.technologies["portal-research"].researched then 
   force.recipes["portal-control-unit"].enabled = true
   force.recipes["medium-portal"].enabled = false
   force.recipes["portal-lander"].enabled = false
   force.recipes["portal-science-pack"].enabled = true
 end
end
