local ICON_BASE = "__portal-research__/graphics/icons/"
data:extend(
{
  {
    type = "item-group",
    name = "space",
    order = "da",
    icon = "__portal-research__/graphics/item-group/space.png",
    icon_size = 64,
  },
  {
    type = "item-subgroup",
    name = "cargo-drop",
    group = "space",
    order = "a"
  },
  {
    type = "item-subgroup",
    name = "satellite-component",
    group = "space",
    order = "b"
  },
  {
    type = "item-subgroup",
    name = "satellite",
    group = "space",
    order = "c"
  },
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
    icons = {{icon="__base__/graphics/icons/chemical-plant.png", tint={r=0.5,g=0.5,b=1,a=1}}},
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
    name = "radio-mast",
    icon = ICON_BASE .. "radio-mast.png",
    flags = {"goes-to-main-inventory"},
    place_result = "radio-mast",
    subgroup = "circuit-network",
    order = "e[radio]-a[radio-mast]",
    stack_size = 50
  },
  {
    type = "item",
    name = "orbital-logistics-combinator",
    icon = ICON_BASE .. "orbital-logistics-combinator.png",
    flags = {"goes-to-main-inventory"},
    place_result = "orbital-logistics-combinator",
    subgroup = "circuit-network",
    order = "e[radio]-a[orbital-logistics-combinator]",
    stack_size = 50
  },
  {
    type = "item",
    name = "cargo-container",
    icons = {{icon = "__base__/graphics/icons/cargo-wagon.png", tint={r=0.8,g=0.8,b=0.8}}},
    flags = {"goes-to-main-inventory"},
    --place_result = "cargo-container",
    subgroup = "cargo-drop",
    order = "a[cargo-container]",
    stack_size = 50
  },
  {
    type = "item",
    name = "cargo-catapult",
    icons = {{icon = "__base__/graphics/icons/rail.png", tint={r=0.4,g=0.4,b=1}}},
    flags = {"goes-to-main-inventory"},
    --place_result = "cargo-catapult",
    subgroup = "cargo-drop",
    order = "c[cargo-catapult]",
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
    icon = ICON_BASE .. "personal-microwave-antenna-equipment.png",
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
    subgroup = "satellite-component",
    order = "b[satellite-housing]",
    stack_size = 10
  },
  {
    type = "item",
    name = "communication-systems",
    icon = ICON_BASE .. "communication-systems.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite-component",
    order = "c[communication-systems]",
    stack_size = 10
  },
  {
    type = "item",
    name = "navigation-computer",
    icon = ICON_BASE .. "navigation-computer.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite-component",
    order = "d[navigation-computer]",
    stack_size = 10
  },
  {
    type = "item",
    name = "solar-array",
    icon = ICON_BASE .. "solar-array.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite-component",
    order = "e[solar-array]",
    stack_size = 10
  },
  {
    type = "item",
    name = "satellite-hangar",
    --icon = ICON_BASE .. "solar-array.png",
    icons = {{icon="__base__/graphics/icons/assembling-machine-1.png", tint={r=0.8,g=0.8,b=1,a=1}}},
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite-component",
    order = "a[satellite-hangar]",
    place_result = "satellite-hangar",
    stack_size = 10
  },
  {
    type = "item",
    name = "space-probe",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "b[space-probe]",
    stack_size = 10 -- TODO: Too much? Maybe 8 instead
  },
  {
    type = "item",
    name = "portal-lander",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "c[portal-lander]",
    stack_size = 1
  },
  {
    type = "item",
    name = "solar-harvester",
    icon = ICON_BASE .. "solar-harvester.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "d[solar-harvester]",
    stack_size = 1
  },
  {
    type = "item",
    name = "space-telescope",
    icon = ICON_BASE .. "space-telescope.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "e[space-telescope]",
    stack_size = 1
  },
  {
    type = "item",
    name = "orbital-repair-station",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "f[orbital-repair-station]",
    stack_size = 1
  },
  {
    type = "item",
    name = "spy-satellite",
    icon = "__base__/graphics/icons/satellite.png",
    --icon = ICON_BASE .. "spy-satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "e[space-telescope]",
    stack_size = 1
  },
  {
    type = "item",
    name = "orbital-mining-laser",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "satellite",
    order = "g[orbital-mining-laser]",
    stack_size = 1
  }
})