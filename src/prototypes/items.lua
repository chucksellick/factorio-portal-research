local ICON_BASE = "__portal-research__/graphics/icons/"
data:extend(
{
  --[[
  {
    type = "item-group",
    name = "space",
    order = "da",
    icon = "__portal-research__/graphics/item-group/space.png",
  },
  {
    type = "item-subgroup",
    name = "satellite-components",
    group = "space",
    order = "b"
  },
  {
    type = "item-subgroup",
    name = "satellite",
    group = "space",
    order = "c"
  },]]
  {
    type = "item",
    name = "factorium-ore",
    icon = ICON_BASE .. "factorium-ore.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-resource",
    order = "g[factorium-ore]",
    stack_size = 50
  },
  {
    type = "item",
    name = "large-factorium-crystal",
    icon = ICON_BASE .. "factorium-crystal-large.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-material",
    order = "h[factorium-crystal]-c[large]",
    stack_size = 10
  },
  {
    type = "item",
    name = "medium-factorium-crystal",
    icon = ICON_BASE .. "factorium-crystal-medium.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-material",
    order = "h[factorium-crystal]-b[medium]",
    stack_size = 25
  }, 
  {
    type = "item",
    name = "small-factorium-crystal",
    icon = ICON_BASE .. "factorium-crystal-small.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-material",
    order = "h[factorium-crystal]-a[small]",
    stack_size = 100
  },
  {
    type = "item",
    name = "plastic-forming-plant",
    icons = {{icon="__base__/graphics/icons/chemical-plant.png", tint={r=0.9,g=0.9,b=1,a=1.5}}},
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "e[chemical-plant]a[plastic-forming-plant]",
    place_result = "plastic-forming-plant",
    stack_size = 10
  },
  {
    type = "item",
    name = "plexiglass-sheet",
    icon = ICON_BASE .. "plexiglass-sheet.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-material",
    order = "d[steel-plate]",
    stack_size = 100
  },
  {
    type = "item",
    name = "plexiglass-lens",
    icon = ICON_BASE .. "plexiglass-lens.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "h[plexiglass-lens]",
    stack_size = 100
  },
  {
    type = "item",
    name = "vacuum-tube",
    icon = ICON_BASE .. "vacuum-tube.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "h[vacuum-tube]",
    stack_size = 100
  },
  {
    type = "item",
    name = "telescope",
    icon = ICON_BASE .. "telescope.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "g[telescope]",
    stack_size = 50
  },
  {
    type = "item",
    name = "observatory",
    icon = ICON_BASE .. "observatory.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "production-machine",
    order = "g[observatory]",
    place_result = "observatory",
    stack_size = 10
  },
  {
    type = "item",
    name = "observatory-scan-result",
    icon = ICON_BASE .. "telescope.png",
    flags = {"goes-to-main-inventory", "hidden"},
    subgroup = "intermediate-product",
    order = "p[rocket-part]",
    stack_size = 10
  },
  {
    type = "tool",
    name = "portal-science-pack",
    icons = { {icon = "__base__/graphics/icons/science-pack-1.png", tint = {r=0.8, g=0.12, b=0.85}} },
    flags = {"goes-to-main-inventory"},
    subgroup = "science-pack",
    order = "h[portal-science-pack]",
    stack_size = 100,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount"
  },
  {
    type = "item",
    name = "portal-control-unit",
    icons = { {icon = "__base__/graphics/icons/processing-unit.png", tint = {r=0.8, g=0.12, b=0.85}} },
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "h[portal-control-unit]",
    stack_size = 100
  },
  {
    type = "item",
    name = "portal-chest",
    icons = { {icon = "__base__/graphics/icons/logistic-chest-requester.png", tint = {r=0.8, g=0.12, b=0.85}} },
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "b[storage]-c[portal-chest]",
    place_result = "portal-chest",
    stack_size = 50
  },
  {
    type = "item",
    name = "portal-chest-power",
    icons = { {icon = "__base__/graphics/icons/logistic-chest-requester.png", tint = {r=1, g=0.8, b=1, a=1}} },
    flags = {"goes-to-quickbar", "hidden"},
    subgroup = "energy",
    order = "e[electric-energy-interface]-b[portal-chest-power]",
    place_result = "electric-energy-interface",
    stack_size = 50
  },
  {
    type = "item",
    name = "portal-belt",
    icons = { {icon = "__base__/graphics/icons/express-underground-belt.png", tint = {r=1, g=0.8, b=1, a=1}} },
    flags = {"goes-to-quickbar"},
    subgroup = "belt",
    order = "b[underground-belt]-d[portal-belt]",
    place_result = "portal-belt",
    stack_size = 50
  },
  {
    type = "item",
    name = "medium-portal",
    icon = ICON_BASE .. "medium-portal.png",
    flags = {"goes-to-main-inventory"},
    place_result="medium-portal",
    subgroup = "transport",
    order = "a[portal-system]-c[medium-portal]",
    stack_size = 10
  },
  {
    type = "item",
    name = "radio-antenna",
    icons = {{icon = "__base__/graphics/icons/constant-combinator.png", tint={r=0,g=1,b=0}}},
    flags = {"goes-to-main-inventory"},
    --place_result = "radio-antenna",
    subgroup = "circuit-network",
    order = "e[radio]-a[radio-antenna]",
    stack_size = 50
  },
  {
    type = "item",
    name = "radio-transmitter",
    icons = {{icon = "__base__/graphics/icons/constant-combinator.png", tint={r=1,g=0,b=0}}},
    flags = {"goes-to-main-inventory"},
    --place_result = "radio-transmitter",
    subgroup = "circuit-network",
    order = "e[radio]-a[radio-antenna]",
    stack_size = 50
  },
  {
    type = "item",
    name = "microwave-antenna", -- real name "rectenna"
    icons = {{icon = "__base__/graphics/icons/radar.png", tint={r=0,g=1,b=0}}},
    --TODO: icon = ICON_BASE .. "microwave-antenna.png",
    flags = {"goes-to-main-inventory"},
    place_result = "microwave-antenna",
    subgroup = "energy",
    order = "d[solar-panel]-c[microwave-antenna]",
    stack_size = 50
  },
  {
    type = "item",
    name = "microwave-transmitter",
    icons = {{icon = "__base__/graphics/icons/radar.png", tint={r=1,g=0,b=0}}},
    --TODO: icon = ICON_BASE .. "microwave-transmitter.png",
    flags = {"goes-to-main-inventory"},
    place_result="microwave-transmitter",
    subgroup = "energy",
    order = "d[solar-panel]-c[microwave-transmitter]",
    stack_size = 50
  },
  {
    type = "item",
    name = "personal-microwave-antenna-equipment", -- real name "rectenna"
    icons = {{icon = "__base__/graphics/icons/fusion-reactor-equipment.png", tint={r=0,g=0,b=1}}},
    --TODO: icon = ICON_BASE .. "personal-microwave-antenna-equipment.png",
    placed_as_equipment_result = "personal-microwave-antenna-equipment",
    flags = {"goes-to-main-inventory"},
    subgroup = "equipment",
    order = "a[energy-source]-b[personal-microwave-antenna]",
    stack_size = 10
  },
  {
    type = "item",
    name = "satellite-housing",
    icon = ICON_BASE .. "satellite-housing.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "q[satellite-housing]",
    stack_size = 10
  },
  {
    type = "item",
    name = "communication-systems",
    icon = ICON_BASE .. "communication-systems.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "q[communication-systems]",
    stack_size = 10
  },
  {
    type = "item",
    name = "navigation-computer",
    icon = ICON_BASE .. "navigation-computer.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "q[navigation-computer]",
    stack_size = 10
  },
  {
    type = "item",
    name = "solar-array",
    icon = ICON_BASE .. "solar-array.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "p[solar-array]",
    stack_size = 10
  },
  {
    type = "item",
    name = "portal-lander",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "r[portal-system]-a[portal-lander]",
    stack_size = 1
  },
  {
    type = "item",
    name = "space-telescope",
    icon = ICON_BASE .. "space-telescope.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "production-machine",
    -- TODO: It's next to the observatory now, but maybe all satellites should be grouped together instead (entirely new tab?)
    order = "g[space-telescope]",
    stack_size = 1
  },
  {
    type = "item",
    name = "solar-harvester",
    icon = ICON_BASE .. "solar-harvester.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "energy",
    order = "d[solar-panel]-b[solar-harvester]",
    stack_size = 1
  },
  {
    type = "item",
    name = "orbital-mining-laser",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product", -- Subgroup production instead?
    order = "r[portal-system]-c[orbital-mining-laser]",
    stack_size = 1
  }
})