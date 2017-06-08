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
      {type="item", name="iron-gear-wheel", amount=10},
      {type="item", name="iron-stick", amount=10},
      {type="fluid", name="lubricant", amount=50}
    },
    result = "telescope"
  },
  {
    type = "recipe-category",
    name = "astronomy"
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
    -- TODO: Randomise the result for % chance of finding nada
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
    name = "solar-array",
    energy_required = 60,
    enabled = false,
    category = "crafting",
    ingredients = {
      {"solar-panel", 100},
      {"accumulator", 84}, -- Crappy in-joke ;)
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
      {"microwave-transmitter", 1}, -- TODO: Butchered for radio transmissions. Could use a dedicated radio transmitter? No, communications-array
      {"advanced-circuit", 200},
      {"processing-unit", 50},
      {"rocket-fuel", 100} -- TODO: Or, a space-friendly fuel
    },
    result = "navigation-computer"
  },
  {
    type = "recipe",
    name = "solar-harvester",
    energy_required = 60,
    enabled = false,
    category = "crafting",
    ingredients = {
      {"satellite", 1},
      {"microwave-transmitter", 10}, -- Telescope? Lens?
      {"navigation-computer", 1},
      {"solar-array", 10} -- TODO: maybe 12? satellite normally needs 1 just to power itself, this can transmit about 10x worth of arrays, and power from 1x is lost in transit
    },
    result = "solar-harvester",
    stack_size = 1
  },
  -- TODO: Maybe update base satellite recipe to all separate components.
  -- Might look like:
  --[[
    energy_required = 10,
    ingredients =
    {
      {"satellite-housing", 1}, --  = low density structures ( + iron sticks?)
      {"navigation-computer", 1}, -- remove radars...?
      {"solar-harvester", 1}, --  = 100 solar panels + 100 accum ( + stuff to make it unfold)
      {"communications-system", 1}, -- = 5 radar + 100 proc units
      {"rocket-fuel", 50}
  ]]
  {
    type = "recipe",
    name = "portal-lander",
    energy_required = 20,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"medium-portal", 1},
      {"satellite", 1},
      {"navigation-computer", 1},
      --{"re-entry-boosters",1}, (...or foil parachute)
      {"rocket-fuel", 200}
      -- Plus, inserters or robots to unpack the portal on landing?
      -- How about batteries for the initial power, or some other kind of power method? (Could be a good 4th big component)
      --[[
      {"low-density-structure", 100},
      {"rocket-control-unit", 100},
      {"radar", 10}, -- 5 on satellite
      {"processing-unit", 100},
      {"medium-portal", 1},
      {"rocket-fuel", 200} -- 50 on satellite ]]--
      -- TODO: Perhaps require a different type of fuel for space operation?
      -- https://forums.factorio.com/viewtopic.php?f=6&t=3802
    },
    result = "portal-lander"
  }
  --[[
  ,
  {
    type = "recipe",
    name = "space-telescope",
    energy_required = 20,
    enabled = false,
    category = "crafting",
    ingredients =
    {
      {"telescope", 10},
      {"satellite", 1},
      {"navigation-computer", 1},
      {"iron-gear-wheel", 100},
      --{"radio-transmitter", 1},
      --{"radio-receiver", 1},
    },
    result = "space-telescope"
  }
  ]]
})
