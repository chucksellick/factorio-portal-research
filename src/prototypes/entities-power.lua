local GRAPHICS_BASE = "__portal-research__/graphics/"
local ICON_BASE = GRAPHICS_BASE .. "icons/"
data:extend(
{
  {
    type = "electric-energy-interface",
    name = "portal-research-hidden-worker-power",
    icon = "__base__/graphics/icons/accumulator.png",
    flags = {},
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-1, -1}, {1, 1}},
    collision_mask = {},
    enable_gui = true,
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "1MJ",
      usage_priority = "secondary-output",
      input_flow_limit = "1MW",
      output_flow_limit = "1MW"
    },
    energy_production = "1MW",
    energy_usage = "0kW",
    --[[
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 0.5
      },
      max_sounds_per_type = 3
    }
    ]]
  },
})