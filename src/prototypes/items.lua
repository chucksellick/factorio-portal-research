local ICON_BASE = "__portal-research__/graphics/icons/"
data:extend(
{
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
    name = "plexiglass-lens",
    icon = ICON_BASE .. "factorium-crystal-small.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "h[plexiglass-lens]",
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
    name = "observatory-scan",
    icon = ICON_BASE .. "telescope.png",
    flags = {"goes-to-main-inventory", "hidden"},
    subgroup = "intermediate-product",
    order = "p[rocket-part]",
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
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product", -- Subgroup??
    order = "r[portal-system]-b[space-telescope]",
    stack_size = 1
  },
  {
    type = "item",
    name = "medium-portal",
    icon = ICON_BASE .. "factorium-crystal-large.png",
    flags = {"goes-to-main-inventory"},
    place_result="medium-portal",
    subgroup = "transport",
    order = "a[portal-system]-c[medium-portal]",
    stack_size = 10
  },
  {
    type = "item",
    name = "solar-array",
    icon = "__base__/graphics/icons/satellite.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "energy",
    order = "d[solar-panel]-b[solar-array]",
    stack_size = 1
  },
  {
    type = "item",
    name = "microwave-antenna", -- real name "rectenna"
    icon = "__base__/graphics/icons/radar.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "energy",
    order = "d[solar-panel]-c[microwave-antenna]",
    stack_size = 50
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