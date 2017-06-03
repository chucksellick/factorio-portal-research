data:extend(
{
  {
    type = "recipe",
    name = "factorium-processing",
    energy_required = 10,
    enabled = false,
    category = "centrifuging",
    ingredients = {{"factorium-ore", 10}},
    icon = "__portal-research__/graphics/icons/factorium-processing.png",
    subgroup = "raw-material",
    order = "h[factorium-processing]",
    results =
    {
      {
        name = "large-factorium-crystal",
        probability = 0.02,
        amount = 1
      },
      {
        name = "medium-factorium-crystal",
        probability = 0.08,
        amount = 1
      },
      {
        name = "small-factorium-crystal",
        probability = 0.9,
        amount = 1
      }
    }
    --[[results =
    {
      {
        name = "large-factorium-crystal",
        probability = 0.01,
        amount = 1
      },
      {
        name = "medium-factorium-crystal",
        probability = 0.09,
        amount = 2
      },
      {
        name = "small-factorium-crystal",
        probability = 0.9,
        amount = 5
      }
    }]]--
  },
  {
    type = "recipe",
    name = "portal-control-unit",
    category = "crafting-with-fluid",
    subgroup = "intermediate-product",
    normal =
    {
      enabled = false,
      energy_required = 20,
      ingredients =
      {
        {"advanced-circuit", 15},
        {"processing-unit", 5},
        {"large-factorium-crystal", 1},
        {type = "fluid", name = "sulfuric-acid", amount = 5} -- TODO: Dry ice? Or some other fluid?
      },
      result = "portal-control-unit"
    },
    expensive =
    {
      enabled = false,
      energy_required = 20,
      ingredients =
      {
        {"advanced-circuit", 15},
        {"processing-unit", 5},
        {"large-factorium-crystal", 2},
        {type = "fluid", name = "sulfuric-acid", amount = 10}
      },
      result = "portal-control-unit"
    }
  },
  {
    type = "recipe",
    name = "medium-portal", -- Big enough for people
    energy_required = 5,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"accumulator", 10},
      {"radar", 1}, -- 5 on satellite
      -- {"lens", 2},
      {"stone-brick", 20},
      {"portal-control-unit", 10}
      -- Fluid?
    },
    result = "medium-portal"
  },
  {
    type = "recipe",
    name = "portal-lander",
    energy_required = 5,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"low-density-structure", 100},
      {"rocket-control-unit", 100},
      {"radar", 10}, -- 5 on satellite
      {"processing-unit", 100},
      {"medium-portal", 1},
      {"rocket-fuel", 200} -- 50 on satellite
    },
    result = "portal-lander"
  }
})
