
-- Add a "floor-layer" condition to each placeable tile item. PPrevents you from using landfill on space tiles.
for item, data in pairs(data.raw["item"]) do
  if data["place_as_tile"] ~= nil --[[and data["place_as_tile"].result ~= "space-platform"]] then
    --table.insert(data.place_as_tile.condition, "deep-space")
  end
end
