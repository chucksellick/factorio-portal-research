local GRAPHICS_BASE = "__portal-research__/graphics/"
local ICON_BASE = GRAPHICS_BASE .. "icons/"

function mastSprite(name)

  return {
    filename = GRAPHICS_BASE .. "radio/" .. name .. ".png",
    width = 156,
    height = 165,
    frame_count = 1,
    shift = {1.5, -1.3}
  }

end

function mastCircuit()
  return
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.38125, 0.35625},
          green = {-0.21875, 0.35625}
        }
      }

end

-- These entities are sort of a merge between constant combinator and big electric pole. (And lamp for receiver mode.)
data:extend(
{
  {
    type = "constant-combinator",
    name = "orbital-logistics-combinator",
    icon = ICON_BASE .. "orbital-logistics-combinator.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "orbital-logistics-combinator"},
    max_health = 150,
    corpse = "medium-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    collision_box = {{-0.65, -0.65}, {0.65, 0.65}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box = {{-1, -3}, {1, 0.5}},

    item_slot_count = 18,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    sprites =
    {
      north = mastSprite("orbital-logistics-combinator"),
      east = mastSprite("orbital-logistics-combinator"),
      south = mastSprite("orbital-logistics-combinator"),
      west = mastSprite("orbital-logistics-combinator")
    },

    -- TODO: Place LED on the dish
    activity_led_sprites =
    {
      north =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      east =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      south =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      west =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      }
    },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
      color = {r = 1.0, g = 1.0, b = 1.0}
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      mastCircuit(),
      mastCircuit(),
      mastCircuit(),
      mastCircuit()
    },

    circuit_wire_max_distance = 9
  },
  {
    type = "constant-combinator",
    name = "radio-mast",
    icon = ICON_BASE .. "radio-mast.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "radio-mast"},
    max_health = 150,
    corpse = "medium-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    collision_box = {{-0.65, -0.65}, {0.65, 0.65}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box = {{-1, -3}, {1, 0.5}},

    item_slot_count = 18,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    sprites =
    {
      north = mastSprite("radio-mast"),
      east = mastSprite("radio-mast"),
      south = mastSprite("radio-mast"),
      west = mastSprite("radio-mast")
    },

    activity_led_sprites =
    {
      north =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      east =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      south =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      },
      west =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/combinator-led-constant-south.png",
        width = 11,
        height = 11,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
      }
    },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
      color = {r = 1.0, g = 1.0, b = 1.0}
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      mastCircuit(),
      mastCircuit(),
      mastCircuit(),
      mastCircuit()
    },

    circuit_wire_max_distance = 9
  }  
}
)