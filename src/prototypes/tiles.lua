local BASE = "__portal-research__/graphics/terrain/"
data:extend(
{
  {
    type = "tile",
    name = "deep-space",
    collision_mask =
    {
      "water-tile", --marking as "water-tile" so "stones" and "concrete" can not be placed on it.
      "floor-layer",--marking as "floor-layer" so "landfill" can not be placed on it, (landfill is modified by the modify script to add this condition)
      "item-layer",
      "resource-layer",
      "player-layer",
      "doodad-layer"
    },
    layer = 40,
    variants =
    {
      main =
        {
          {
            picture = BASE .. "space1.png",
            count = 16,
            size = 1
          },
          {
            picture = BASE .. "space2.png",
            count = 4,
            size = 2,
            probability = 0.39,
          },
          {
            picture = BASE .. "space4.png",
            count = 4,
            size = 4,
            probability = 1,
          },
        },
      inner_corner =
      {
        picture = "__base__/graphics/terrain/out-of-map-inner-corner.png",
        count = 0
      },
      outer_corner =
      {
        picture = "__base__/graphics/terrain/out-of-map-outer-corner.png",
        count = 0
      },
      side =
      {
        picture = "__base__/graphics/terrain/out-of-map-side.png",
        count = 0
      }
    },
    --allowed_neighbors = { "space-platform" },
    ageing=0,
    map_color={r=0.0, g=0.0, b=0.0}
  }
}
)
