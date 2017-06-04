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
    },
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
    -- TODO: If anything else is going to use plexiglass (e.g. space shuttles) should make it a
    -- separate recipe. Real plexiglass production (simplified) might take
    -- acetone (made from propene ~= heavy oil? cumene process) + sodium cyanide + (methyl) alchohol + mould (what is the mould made from? stone/iron?)
    -- TODO: Alternately, could be making lenses directly from diamond or factorium ...
    type = "recipe",
    name = "plexiglass-lens",
    category = "chemistry",
    enabled = false,
    energy_required = 5,
    ingredients =
    { 
      {type="item", name="plastic-bar", amount=2},
      -- Wood is for producing methyl alcohol. Might need a way to automate wood.
      -- Alternative recipe could use CO2 (Natural sources include volcanoes, hot springs and geysers,
      -- and it is freed from carbonate rocks by dissolution in water and acids). And/Or Carbon Monoxide
      -- from burning coals.
      -- Or bacteria.
      {type="item", name="raw-wood", amount=10},
      {type="fluid", name="lubricant", amount=25}, -- TODO: Dry ice for cooling? Lava?
      {type="fluid", name="steam", amount=50} -- Steam for destructive distillation of wood (but should it be higher temperature?)
    },
    result = "plexiglass-lens",
    crafting_machine_tint =
    {
      primary = {r=0.0, g=0.0, b=0.85, a=1.00},
      secondary = {r=0.8, g=0.8, b=0.9, a=1.00},
      tertiary = {r=0.6, g=0.65, b=0.85, a=1.00},
    }
    --TODO: Expensive version?
  },
  {
    type = "recipe",
    name = "portal-science-pack",
    enabled = false,
    energy_required = 20,
    ingredients =
    { 
      {"portal-control-unit", 1},
      {"effectivity-module-2", 1},
      {"plexiglass-lens", 4},
      {"stone-brick", 20} -- Could use logistic chests instead? Or some crystals? Bricks are everywhere...
    },
    result_count = 2,
    result = "portal-science-pack"
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
    name = "portal-belt",
    category = "crafting-with-fluid",
    enabled = false,
    energy_required = 5,
    ingredients =
    {
      {"portal-control-unit", 2}, -- TODO: Decide whether to have multiple sizes of PCU and use small ones here.
                                  -- Or simplify Factorium output. Or use the large crystals differently.
      {"express-transport-belt", 2},
      {"stone-brick", 10}, -- TODO: Additional item, circuits or copper wire or something? Or lenses?
      {type="fluid", name="lubricant", amount=40},
    },
    result_count = 2,
    result = "portal-belt"
  },
  {
    type = "recipe",
    name = "portal-chest",
    enabled = false,
    energy_required = 5,
    ingredients =
    {
      {"portal-control-unit", 2}, -- TODO: As for portal-belt
      {"steel-chest", 2}, -- TODO: Alternatively, use two logistic chests (passive+requester? active+storage?)
      {"radar", 2},
      {"advanced-circuit", 2}
    },
    result_count = 2,
    result = "portal-chest"
  },
  {
    type = "recipe",
    name = "medium-portal", -- Big enough for people
    energy_required = 5,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"accumulator", 50},
      {"radar", 2},
      {"plexiglass-lens", 5},
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
      -- TODO: Perhaps require a different type of fuel for space operation?
      -- https://forums.factorio.com/viewtopic.php?f=6&t=3802
    },
    result = "portal-lander"
  }
})
