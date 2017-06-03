data:extend(
{
  {
    type = "electric-energy-interface",
    name = "medium-portal",
    icon = "__base__/graphics/icons/accumulator.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = "medium-portal"},
    max_health = 300,
    corpse = "big-remnants",
    collision_box = {{-1.2, -0.1}, {1.2, 0.1}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    enable_gui = true,
    allow_copy_paste = true,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "1GJ",
      usage_priority = "terciary",
      input_flow_limit = "1MW",
      output_flow_limit = "0kW"
    },

    energy_production = "0kW",
    energy_usage = "100kW",
    -- also 'pictures' for 4-way sprite is available, or 'animation' resp. 'animations'
    picture =
    {
      filename = "__base__/graphics/entity/accumulator/accumulator.png",
      priority = "extra-high",
      width = 124,
      height = 103,
      shift = {0.6875, -0.203125},
      tint = {r=1, g=0.8, b=1, a=1}
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 0.8},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound =
      {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 5
    }
  }
})