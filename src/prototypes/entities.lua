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
    -- TODO: Would be nice to have a thinner collision box (in y-axis) but this makes placement and deconstruction weird.
    -- Is there a way to modify player collision separately? Or remove from player-layer collision mask and perform some manual collision?
    collision_box = {{-1.2, -0.6}, {1.2, 0.6}},
    --collision_box = {{-1.2, -0.1}, {1.2, 0.1}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    enable_gui = false,
    allow_copy_paste = false,
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
  },
  {
    type = "container",
    name = "portal-chest",
    icon = {icon="__base__/graphics/icons/logistic-chest-requester.png",tint = {r=1, g=0.8, b=1, a=1}},
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "portal-chest"},
    max_health = 500,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "impact",
        percent = 60
      }
    },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 10,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
      filename = "__base__/graphics/entity/logistic-chest/logistic-chest-requester.png",
      priority = "extra-high",
      width = 48,
      height = 34,
      shift = {0.1875, 0},
      tint = {r=1, g=0.8, b=1, a=1}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.734375, 0.453125},
        green = {0.609375, 0.515625},
      },
      wire =
      {
        red = {0.40625, 0.21875},
        green = {0.40625, 0.375},
      }
    },
    circuit_connector_sprites = get_circuit_connector_sprites({0.1875, 0.15625}, nil, 18),
    circuit_wire_max_distance = 9,
    electric_energy_source = "fake-power-consumer"
  },
  {
    type = "electric-energy-interface",
    name = "portal-chest-power",
    icon = {icon="__base__/graphics/icons/logistic-chest-requester.png",tint = {r=1, g=0.8, b=1, a=1}},
    flags = {"placeable-off-grid"},
    --flags = {"player-creation"},
    --minable = {hardness = 0.2, mining_time = 0.5, result = "fake-power-consumer"},
    --max_health = 150,
    --corpse = "medium-remnants",
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{0, 0}, {0, 0}},
    collision_mask = {"not-colliding-with-itself"},
    enable_gui = false,
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "5MJ",
      usage_priority = "terciary",
      input_flow_limit = "500MW",
      output_flow_limit = "0GW"
    },
    energy_production = "0GW",
    energy_usage = "200kW",
    -- also 'pictures' for 4-way sprite is available, or 'animation' resp. 'animations'
    --[[
    picture =
    {
      filename = "__base__/graphics/entity/accumulator/accumulator.png",
      priority = "extra-high",
      width = 124,
      height = 103,
      shift = {0.6875, -0.203125},
      tint = {r=1, g=0.8, b=1, a=1}
    },
    ]]--
    --vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
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
  },
  {
    type = "underground-belt",
    name = "portal-belt",
    icon = "__base__/graphics/icons/express-underground-belt.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "portal-belt"},
    max_health = 200,
    corpse = "small-remnants",
    max_distance = 50,
    underground_sprite =
    {
      filename = "__core__/graphics/arrows/underground-lines.png",
      priority = "high",
      width = 64,
      height = 64,
      x = 64,
      scale = 0.5
    },
    resistances =
    {
      {
        type = "fire",
        percent = 60
      },
      {
        type = "impact",
        percent = 30
      }
    },
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    animation_speed_coefficient = 32,
    belt_horizontal = express_belt_horizontal, -- specified in transport-belt-pictures.lua
    belt_vertical = express_belt_vertical,
    ending_top = express_belt_ending_top,
    ending_bottom = express_belt_ending_bottom,
    ending_side = express_belt_ending_side,
    starting_top = express_belt_starting_top,
    starting_bottom = express_belt_starting_bottom,
    starting_side = express_belt_starting_side,
    fast_replaceable_group = "underground-belt",
    -- TODO: This is maximum speed and is near instantaneous but still takes noticably
    -- longer at distance. Need to do some trickery on_tick to make it actually work. Also
    -- needs to draw power.
    speed = 1, --0.09375,
    structure =
    {
      direction_in =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/express-underground-belt/express-underground-belt-structure.png",
          priority = "extra-high",
          shift = {0.26, 0},
          tint = {r=1, g=0.8, b=1, a=1},
          width = 57,
          height = 43,
          y = 43,
          hr_version =
          {
            filename = "__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure.png",
            priority = "extra-high",
            shift = {0.15625, 0.0703125},
          tint = {r=1, g=0.8, b=1, a=1},
            width = 106,
            height = 85,
            y = 85,
            scale = 0.5
          }
        }
      },
      direction_out =
      {
        sheet =
        {
          filename = "__base__/graphics/entity/express-underground-belt/express-underground-belt-structure.png",
          priority = "extra-high",
          shift = {0.26, 0},
          width = 57,
          height = 43,
          tint = {r=1, g=0.8, b=1, a=1},
          hr_version =
          {
            filename = "__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure.png",
            priority = "extra-high",
            shift = {0.15625, 0.0703125},
          tint = {r=1, g=0.8, b=1, a=1},
            width = 106,
            height = 85,
            scale = 0.5
          }
        }
      }
    },
    ending_patch = ending_patch_prototype
  }

})