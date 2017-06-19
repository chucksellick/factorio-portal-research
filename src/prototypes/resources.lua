
data:extend(
{
  {
    type = "noise-layer",
    name = "factorium-ore"
  },
  {
    type = "autoplace-control",
    name = "factorium-ore",
    richness = true,
    order = "b-g"
  },
  {
    type = "resource",
    name = "factorium-ore",
    icon = "__portal-research__/graphics/icons/factorium-ore.png",
    flags = {"placeable-neutral"},
    order="a-b-e",
    minable =
    {
      hardness = 0.9,
      mining_particle = "stone-particle",
      mining_time = 8, -- uranium is 4, normal is 2
      result = "factorium-ore",
      fluid_amount = 20,
      required_fluid = "sulfuric-acid"
    },
    collision_box = {{ -0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
    autoplace =
    {
      control = "factorium-ore",
      sharpness = 1,
      richness_multiplier = 2000,
      richness_multiplier_distance_bonus = 30,
      richness_base = 500,
      coverage = 0.008,
      peaks =
      {
        {
          noise_layer = "factorium-ore",
          noise_octaves_difference = -1.5,
          noise_persistence = 0.3,
        },
      },
      starting_area_size = 600 * 0.005,
      starting_area_amount = 100
    },
    stage_counts = {1000, 600, 400, 200, 100, 50, 20, 1},
    stages =
    {
      sheet =
      {
        filename = "__portal-research__/graphics/factorium-ore/factorium-ore.png",
        priority = "extra-high",
        width = 64,
        height = 64,
        frame_count = 8,
        variation_count = 8,
        hr_version = {
          filename = "__portal-research__/graphics/factorium-ore/hr-factorium-ore.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          frame_count = 8,
          variation_count = 8,
          scale = 0.5
        }
      }
    },
    stages_effect =
    {
      sheet =
      {
        filename = "__portal-research__/graphics/factorium-ore/factorium-ore-glow.png",
        priority = "extra-high",
        width = 64,
        height = 64,
        frame_count = 8,
        variation_count = 8,
        blend_mode = "additive",
        flags = {"light"},
        hr_version = {
          filename = "__portal-research__/graphics/factorium-ore/hr-factorium-ore-glow.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          frame_count = 8,
          variation_count = 8,
          scale = 0.5,
          blend_mode = "additive",
          flags = {"light"},
        }
      }
    },
    effect_animation_period = 5,
    effect_animation_period_deviation = 1,
    effect_darkness_multiplier = 3.6,
    min_effect_alpha = 0.2,
    max_effect_alpha = 0.3,
    map_color = {r=0.8, g=0.12, b=0.85}
  }
})
