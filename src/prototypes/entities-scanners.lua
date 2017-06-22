local GRAPHICS_BASE = "__portal-research__/graphics/"
local ICON_BASE = GRAPHICS_BASE .. "icons/"
data:extend(
{
  {
    type = "assembling-machine",
    name = "observatory",
    icon = ICON_BASE .. "observatory.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    max_health = 150,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    minable = {mining_time = 1, result = "observatory"},
    light = {intensity = 0.75, size = 8, color = {r = 1.0, g = 1.0, b = 1.0}},
    animation =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 113,
          height = 91,
          frame_count = 33,
          line_length = 11,
          animation_speed = 1 / 3,
          shift = {0.2, 0.15}
          -- hr_version = { scale = 0.5 } -- see assembling machine
        }
      }
    },
    crafting_speed = 1,
    fixed_recipe = "observatory-scan-for-sites",
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/lab.ogg", -- TODO: Custom sound
        volume = 0.7
      },
      apparent_volume = 1
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "60kW",
    crafting_categories = {"astronomy"},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    ingredient_count = 1,
    module_specification =
    {
      module_slots = 2
    },
    -- Note: No productivity, since inputs are virtual it's meaningless
    -- TODO: *However*, maybe an actual input such as space science pack could actually make sense? (For earth-based ones at least...)
    allowed_effects = {"consumption", "speed", "pollution"}
  },
  {
    type = "assembling-machine",
    name = "space-telescope-worker",
    icon = ICON_BASE .. "observatory.png",
    flags = {},
    collision_mask = {},
    max_health = 150,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    -- TODO: Change to single frame since never seen
    animation =
    {
      layers =
      {
        {
          filename = "__base__/graphics/entity/lab/lab.png",
          width = 113,
          height = 91,
          frame_count = 33,
          line_length = 11,
          animation_speed = 1 / 3,
          shift = {0.2, 0.15}
          -- hr_version = { scale = 0.5 } -- see assembling machine
        }
      }
    },
    -- TODO: Provide a way to increase scan speed? Add free modules on certain research? Or additional worker entities?
    -- ... Can also just increase chance for successful scan.
    -- TODO: Also as satellite takes damage the scan speed should slow or scan chance goes down.
    -- Could potentially modulate this with power flow but that's probably worse for UPS...
    crafting_speed = 0.5,
    fixed_recipe = "observatory-scan-for-sites",
    --[[
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/lab.ogg", -- TODO: Custom sound
        volume = 0.7
      },
      apparent_volume = 1
    },
    ]]
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "100kW", 
    crafting_categories = {"astronomy"},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    ingredient_count = 1,
    module_specification =
    {
      module_slots = 2
    },
    allowed_effects = {"consumption", "speed", "pollution"}
  },
})