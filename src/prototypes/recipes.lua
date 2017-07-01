local ICON_BASE = "__portal-research__/graphics/icons/"
-- TODO: Expensive versions
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
  },
  {
    -- Science note: Real plexiglass production (simplified) might take
    -- acetone (made from propene ~= heavy oil? cumene process) + sodium cyanide +
    -- (methyl) alchohol + shape mould (what is the mould made from? stone/iron?)
    type = "recipe",
    name = "plexiglass-sheet",
    category = "chemistry",
    enabled = false,
    energy_required = 5,
    ingredients =
    { 
      {type="item", name="plastic-bar", amount=10},
      -- Wood is for producing methyl alcohol. Might need a way to automate wood.
      -- Alternative recipe could use CO2 (Natural sources include volcanoes, hot springs and geysers,
      -- and it is freed from carbonate rocks by dissolution in water and acids).
      -- And/Or Carbon Monoxide from burning coals. Or bacteria.
      {type="item", name="raw-wood", amount=10},
      {type="fluid", name="steam", amount=50} -- Steam for destructive distillation of wood (but should it be higher temperature?)
    },
    result = "plexiglass-sheet",
    crafting_machine_tint =
    {
      primary = {r=0.0, g=0.0, b=0.85, a=1.00},
      secondary = {r=0.8, g=0.8, b=0.9, a=1.00},
      tertiary = {r=0.6, g=0.65, b=0.85, a=1.00},
    }
  },
  {
    type = "recipe",
    name = "plastic-forming-plant",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      -- TODO: These are ingredients for chemical plant, need to tweak
      {"steel-plate", 5},
      {"iron-gear-wheel", 5},
      {"electronic-circuit", 5},
      {"pipe", 5}
    },
    result = "plastic-forming-plant"
  },
  {
    type = "recipe-category",
    name = "plastic-forming"
  },
  {
    type = "recipe",
    name = "plexiglass-lens",
    icon = ICON_BASE .. "plexiglass-lens.png",
    category = "plastic-forming",
    subgroup = "intermediate-product",
    enabled = false,
    energy_required = 2,
    ingredients =
    { 
      {type="item", name="plexiglass-sheet", amount=2},
      {type="item", name="iron-plate", amount=2}, -- TODO: Concave-mould, becomes an output
      --{type="fluid", name="lubricant", amount=20}, 
      {type="fluid", name="steam", amount=20}, -- Steam for heating
      {type="fluid", name="water", amount=50} -- Water for cooling, results in steam. TODO: Need some tactic to dispose of the steam.
      -- TODO: Dry ice for cooling?
    },
    results =
    {
      {
        name = "plexiglass-lens",
        amount = 1
      },
      {
        type="fluid",
        name = "steam",
        amount = 20
      },
    },
    crafting_machine_tint =
    {
      primary = {r=0.0, g=0.0, b=0.85, a=1.00},
      secondary = {r=0.8, g=0.8, b=0.9, a=1.00},
      tertiary = {r=0.6, g=0.65, b=0.85, a=1.00},
    }
  },
  {
    type = "recipe",
    name = "vacuum-tube",
    icon = ICON_BASE .. "vacuum-tube.png",
    category = "plastic-forming",
    subgroup = "intermediate-product",
    enabled = false,
    energy_required = 2,
    ingredients =
    {
      {type="item", name="plexiglass-sheet", amount=2},
      {type="item", name="copper-plate", amount=2},
      {type="item", name="copper-cable", amount=10},
      {type="fluid", name="steam", amount=20}, -- Steam for blow molding
      {type="fluid", name="water", amount=50}, -- Water for coolant
    },
    results =
    {
      {
        name = "vacuum-tube",
        amount = 1
      },
      {
        type="fluid",
        name = "steam",
        amount = 20
      },
    },
    crafting_machine_tint =
    {
      primary = {r=0.0, g=0.0, b=0.85, a=1.00},
      secondary = {r=0.8, g=0.8, b=0.9, a=1.00},
      tertiary = {r=0.6, g=0.65, b=0.85, a=1.00},
    }
  },
  {
    type = "recipe",
    name = "telescope",
    category = "crafting-with-fluid",
    subgroup = "intermediate-product",
    enabled = false,
    energy_required = 2,
    ingredients =
    { 
      -- TODO: Review amounts
      {type="item", name="plexiglass-lens", amount=5},
      {type="item", name="copper-plate", amount=20},
      {type="item", name="iron-stick", amount=10},
      {type="fluid", name="lubricant", amount=50}
    },
    result = "telescope"
  },
  {
    type = "recipe",
    name = "observatory",
    category = "crafting",
    enabled = false,
    energy_required = 20,
    ingredients =
    { 
      -- TODO: Review amounts
      {type="item", name="telescope", amount=1},
      {type="item", name="steel-plate", amount=20},
      {type="item", name="landfill", amount=12},
      {type="item", name="concrete", amount=10}, -- stone-brick instead/aswell?
      {type="item", name="advanced-circuit", amount=20},
      {type="item", name="iron-gear-wheel", amount=50}
    },
    result = "observatory"
  },
  {
    type = "recipe-category",
    name = "astronomy"
  },
  {
    -- Recipe used behind the scenes
    type = "recipe",
    name = "observatory-scan-for-sites",
    category = "astronomy",
    enabled = true,
    energy_required = 100,
    hidden = true,
    icon = "__portal-research__/graphics/icons/telescope.png",
    ingredients =
    { 
      --{type="item", name="observatory-scan", amount=1}
    },
    result = "observatory-scan-result"
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
        {"medium-factorium-crystal", 1},
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
        {"medium-factorium-crystal", 2},
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
      {"stone-brick", 20},
      {"portal-control-unit", 10},
      {"plexiglass-lens", 5},
      {"large-factorium-crystal", 1}
      -- Fluid?
    },
    result = "medium-portal"
  },
  {
    type = "recipe",
    name = "microwave-antenna",
    energy_required = 20,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"plexiglass-lens", 50},
      {"radar", 10},
      {"substation", 10},
      -- TODO: Having 100 accumulators implies the battery should be able to store 500MJ energy...
      {"accumulator", 100},
      {"processing-unit", 50}, -- TODO: A bit expensive? ... Where we're doing things like asking for tons of accumulators everywhere, maybe make
                               -- some shared intermediate.
    },
    result = "microwave-antenna"
  },
  {
    type = "recipe",
    name = "microwave-transmitter",
    energy_required = 20,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"plexiglass-lens", 50},
      {"laser-turret", 10},
      {"substation", 10},
      {"accumulator", 100},
      {"processing-unit", 50}, -- TODO: A bit expensive? 
    },
    result = "microwave-transmitter"
  },
  {
    type = "recipe",
    name = "personal-microwave-antenna-equipment",
    energy_required = 30,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"plexiglass-lens", 10},
      {"radar", 1},
      {"processing-unit", 20},
      {"copper-cable", 100},
      {"energy-shield-mk2-equipment", 10},
      {"battery-mk2-equipment", 10}, -- TODO: Batteries or no? Really depends on the internall buffering question...
      -- TODO: Copper cable is for grounding but we need electrical insulation. Energy shield is kind of a nod towards this but maybe some insulation component would be interesting.
    },
    result = "personal-microwave-antenna-equipment"
  },
  {
    type = "recipe",
    name = "radio-mast",
    enabled = false,
    ingredients =
    {
      {"copper-cable", 5},
      {"advanced-circuit", 5},
      {"vacuum-tube", 2},
      {"big-electric-pole", 1}
    },
    result = "radio-mast"
  },
  {
    type = "recipe",
    name = "orbital-logistics-combinator",
    enabled = false,
    ingredients =
    {
      {"copper-cable", 5},
      {"electronic-circuit", 5},
      {"iron-plate", 4},
      {"radio-mast", 1},
    },
    result = "orbital-logistics-combinator"
  },
  {
    type = "recipe",
    name = "cargo-container",
    enabled = false,
    ingredients =
    {
      {"iron-gear-wheel", 10},
      {"iron-plate", 20},
      {"low-density-structure", 5}
    },
    result = "cargo-container"
  },
  {
    type = "recipe",
    name = "cargo-catapult",
    enabled = false,
    ingredients =
    {
      {"iron-gear-wheel", 10},
      {"rail", 10},
      {"accumulator", 10},
      {"copper-cable", 20}
    },
    result = "cargo-catapult"
  },
  --[[
      --{
        --type = "unlock-recipe",
        --recipe = "cargo-loader" -- ideally doubles as an unloader...
      --},
      { 
        type = "unlock-recipe",
        recipe = "cargo-drop-site"
      },]]

  {
    type = "recipe",
    name = "satellite-housing",
    energy_required = 60,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"low-density-structure", 100},
      {"rocket-control-unit", 100},
      {"rocket-fuel", 100}
    },
    result = "satellite-housing"
  },
  {
    type = "recipe",
    name = "solar-array",
    energy_required = 60,
    enabled = false,
    category = "crafting-with-fluid",
    ingredients = {
      {"solar-panel", 100},
      --{"plexiglass-sheet", 100},
      {"accumulator", 84},
      {"iron-gear-wheel", 50},
      --{"iron-stick", 20},
      {type="fluid", name="lubricant", amount=100},
    },
    result = "solar-array",
    stack_size = 20
  },
  {
    type = "recipe",
    name = "navigation-computer",
    energy_required = 60,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"radar", 10},
      {"processing-unit", 100},
      {"vacuum-tube", 50},
      {"speed-module", 10}
    },
    result = "navigation-computer"
  },
  {
    type = "recipe",
    name = "communication-systems",
    energy_required = 60,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"radio-mast", 20},
      {"advanced-circuit", 200},
      -- TODO: Needs some extra bells and whistles really. Maybe a speaker combinator?
    },
    result = "communication-systems"
  },
  {
    type = "recipe",
    name = "solar-harvester",
    energy_required = 60,
    enabled = false,
    category = "crafting",
    ingredients = {
      {"satellite-housing", 1},
      {"navigation-computer", 1},
      {"communication-systems", 1},
      {"microwave-transmitter", 10},
      -- 12 arrays: satellite normally needs 1 just to power itself, leaving 10x
      -- worth of arrays to transmit, and power from 1x is lost in transit == 100MW total
      {"solar-array", 12}
    },
    result = "solar-harvester",
    stack_size = 1
  },
  {
    type = "recipe",
    name = "portal-lander",
    energy_required = 90,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"medium-portal", 1},
      {"satellite-housing", 1},
      {"navigation-computer", 5},
      {"solar-array", 1},
      {"rocket-fuel", 200},
      {"construction-robot", 10},
      -- How about batteries for the initial power, or some other kind of power method?
      -- TODO: Perhaps require a different type of fuel for space operation?
      -- https://forums.factorio.com/viewtopic.php?f=6&t=3802
    },
    result = "portal-lander"
  },
  {
    type = "recipe",
    name = "space-telescope",
    energy_required = 90,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"satellite-housing", 1},
      {"navigation-computer", 1},
      {"communication-systems", 10},
      {"solar-array", 4},
      {"telescope", 50},
      {"iron-gear-wheel", 200}
    },
    result = "space-telescope"
  },
  {
    type = "recipe",
    name = "orbital-repair-station",
    energy_required = 120,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"satellite-housing", 1},
      {"navigation-computer", 1},
      {"communication-systems", 5},
      {"solar-array", 10},
      {"construction-robot", 100},
      {"roboport", 5},
      {"repair-pack", 1000}
      -- TODO: A whole new assembler for satellites! (satellite hangar?) and have them all require 7-8 ingredients
    },
    result = "orbital-repair-station"
  }
  --[[
  -- TODO: Spy satellite and space telescope could have an imaging system in common?
  {
    type = "recipe",
    name = "spy-satellite",
    energy_required = 45,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"satellite-housing", 1},
      {"navigation-computer", 2},
      {"communication-systems", 2},
      {"solar-array", 2},
      {"telescope", 20},
      {"radar", 20},
      {"vacuum-tube", 50},
      {"processing-unit", 100},
    },
    result = "spy-satellite"
  },
  {
    type = "recipe",
    name = "orbital-mining-laser",
    energy_required = 20,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"satellite-housing", 1},
      {"navigation-computer", 1},
      {"communication-systems", 1},
      {"telescope", 2},
      {"solar-array", 20},
      -- TODO: Or some combination of lenses/tubes to make a super laser?
      -- Also use the super laser for a new 
      {"laser-turret", 50},
    },
    result = "orbital-mining-laser"
  },
  ]]
})
