local GRAPHICS_BASE = "__portal-research__/graphics/"
local ICON_BASE = GRAPHICS_BASE .. "icons/"
data:extend(
{
  {
    type = "electric-energy-interface",
    name = "medium-portal",
    icon = ICON_BASE .. "medium-portal.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = "medium-portal"},
    max_health = 300,
    corpse = "big-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    enable_gui = false,
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "1GJ",
      usage_priority = "secondary-input",
      input_flow_limit = "200MW",
      output_flow_limit = "0kW"
    },
    energy_production = "0kW",
    energy_usage = "500kW",
    -- also 'pictures' for 4-way sprite is available, or 'animation' resp. 'animations'
    picture =
    {
      filename = GRAPHICS_BASE .. "portals/medium-portal-base-ns.png", -- TODO: east-west variant
      priority = "extra-high",
      width = 113,
      height = 120,
      shift = {0.1, -0.5}
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
    },
    -- TODO: Can't be destroyed (with bullets at least)
    collision_mask = { "item-layer", "object-layer", "water-tile"} -- removed player_layer
  },
  {
    type = "container",
    name = "portal-chest",
    icon = "__base__/graphics/icons/logistic-chest-requester.png",
    --icon = {icon="__base__/graphics/icons/logistic-chest-requester.png",tint = {r=1, g=0.8, b=1, a=1}},
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
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}}, -- {{-0.3, -0.3}, {0.3, 0.3}},
    fast_replaceable_group = "container",
    inventory_size = 1,
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
    icon = "__base__/graphics/icons/logistic-chest-requester.png",
    flags = {"placeable-off-grid"},
    --flags = {"player-creation"},
    --minable = {hardness = 0.2, mining_time = 0.5, result = "fake-power-consumer"},
    --max_health = 150,
    --corpse = "medium-remnants",
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
    -- Can't be selected because it's masked by the chest (for unknown reasons but still), however
    -- the selection_box is used to draw the power connection blue square so it's good to have one.
    --selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},
    enable_gui = false,
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "40MJ",
      usage_priority = "secondary-input",
      input_flow_limit = "20MW",
      output_flow_limit = "0GW"
    },
    energy_production = "0GW",
    energy_usage = "200kW",
    -- also 'pictures' for 4-way sprite is available, or 'animation' resp. 'animations'
    --[[picture =
    {
      filename = "__base__/graphics/entity/accumulator/accumulator.png",
      priority = "extra-high",
      width = 124,
      height = 103,
      shift = {0.6875, -0.203125},
      tint = {r=1, g=0.8, b=1, a=1}
    },]]
    --vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 0.5
      },
      max_sounds_per_type = 3
    }
  },
  {
    type = "underground-belt",
    name = "portal-belt",
    icon = "__base__/graphics/icons/express-underground-belt.png",
    --icon = {icon="__base__/graphics/icons/express-underground-belt.png",tint = {r=1, g=0.8, b=1, a=1}},
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
  },
 {
    type = "electric-energy-interface",
    name = "portal-belt-power",
    icons = {{icon="__base__/graphics/icons/express-underground-belt.png",tint = {r=1, g=0.8, b=1, a=1}}},
    flags = {"placeable-off-grid"},
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = {"not-colliding-with-itself"},
    enable_gui = false,
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "40MJ",
      usage_priority = "secondary-input",
      input_flow_limit = "20MW",
      output_flow_limit = "0GW"
    },
    energy_production = "0GW",
    energy_usage = "50kW",
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 0.5
      },
      max_sounds_per_type = 3
    }
  },
  {
    type = "electric-energy-interface",
    name = "microwave-antenna",
    icons = {{icon = "__base__/graphics/icons/radar.png", tint={r=0,g=1,b=0}}},
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = "microwave-antenna"},
    max_health = 300,
    corpse = "big-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    -- TODO: Check resistances on all entities
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    enable_gui = true, -- TODO: Remove
    allow_copy_paste = false, -- TODO: Named, or autotarget?
    -- TODO: Simple version is to switch on or off when beam is sending. Excess is simply wasted and there's no real way
    -- to respond to power demand / usage. This is problematic for operation between base sites but great for orbitals. On base sites
    -- maybe we have GUI to set power transmission amount, but still need to know how *much* power was extracted from the network,
    -- a buffer can manage this but we have to check ticks frequently to make sure antenna's output matches transmitter's input...

    energy_source =
    {
      type = "electric",
      -- Note: Really hard to understand how these numbers all work. Setting buffer_capacity too low results in brownout,
      -- even if this is purely producing. Anyway the following combination seems to achieve what I required.
      -- TODO: Getting a red flashing icon when not enough power is available. Seems weird but in a way it's useful. Still inconsistent with other power sources :(
      buffer_capacity = "2MJ", 
      usage_priority = "secondary-output",
      input_flow_limit = "0MW",
      output_flow_limit = "100MW"
    },
    -- 1000 solar panels = 60MW on planet surface during daytime, but they are much more efficient in space, there is some loss in the microwave beam of course
    -- 100MW is more than enough to run a single outpost. (Maybe too much! But the player should be encouraged to share between outposts, use accumulators, )
    energy_production = "100MW",
    energy_usage = "0kW",
    animation =
    {
      filename = "__base__/graphics/entity/radar/radar.png",
      priority = "low",
      width = 153,
      height = 131,
      apply_projection = false,
      line_length = 8,
      frame_count = 64,
      shift = util.by_pixel(27.5,-12.5),
      tint={r=0,g=1,b=0}
    },
    -- TODO: Big energy beam from the sky!
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound =
      {
        filename = "__base__/sound/radar.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 5
    }
  },
  {
    type = "electric-energy-interface",
    name = "microwave-transmitter",
    icons = {{icon = "__base__/graphics/icons/radar.png", tint={r=1,g=0,b=0}}},
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = "microwave-transmitter"},
    max_health = 300,
    corpse = "big-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    -- TODO: Check resistances on all entities
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    enable_gui = true, -- TODO: Remove
    allow_copy_paste = false, -- TODO: Named, or autotarget?
    energy_source =
    {
      type = "electric",
      buffer_capacity = "20MJ",
      usage_priority = "secondary-input", -- TODO: Should be tertiary like accums. BUT this has nasty side-effect of showing on power screen as accumulators.
      input_flow_limit = "10.5MW", -- 10MW per transmitter = 100MW for solar harvester
      output_flow_limit = "0MW",
    },
    energy_production = "0MW",
    energy_usage = "0.5MW", -- Energy lost due to system inefficiency. TODO: Should scale with input flow. Are usage and drain the same? Should it be drain? Should it be 1/10th?
    animation =
    {
      filename = "__base__/graphics/entity/radar/radar.png",
      priority = "low",
      width = 153,
      height = 131,
      apply_projection = false,
      line_length = 8,
      frame_count = 64,
      shift = util.by_pixel(27.5,-12.5),
      tint={r=1,g=0,b=0},
      animation_speed = 1.5 -- TODO: Fix animation + effect
    },
    -- TODO: Energy beam towards receiver
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound =
      {
        filename = "__base__/sound/radar.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 5
    }
  },
})