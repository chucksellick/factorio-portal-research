local ICON_BASE = "__portal-research__/graphics/technology/"
data:extend(
{
  {
    -- TODO: This could be "space plastics" to be a bit different, and require space science(?).
    -- But satellites couldn't have comms systems because they would need this prereq, so comms systems
    -- would be for spy satellites only (need better term for this)
    type = "technology",
    name = "advanced-plastics",
    icon = "__base__/graphics/technology/plastics.png",
    --icon = ICON_BASE .. "advanced-materials.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "plexiglass-sheet"
      },
      {
        type = "unlock-recipe",
        recipe = "plastic-forming-plant"
      }
    },
    prerequisites = {"plastics"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1}
      },
      time = 30,
      count = 200
    }
  },
  {
    type = "technology",
    name = "advanced-optics",
    icon = "__base__/graphics/technology/optics.png",
    --icon = ICON_BASE .. "advanced-optics.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "plexiglass-lens"
      }
      -- TODO: Concave mould?
      -- TODO: Unlock an advanced laser or laser gun or something to make this immediately useful
    },
    prerequisites = {"laser","advanced-plastics"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1}
      },
      time = 30,
      count = 200
    }
  },
  {
    type = "technology",
    name = "radio",
    icon = ICON_BASE .. "radio.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "vacuum-tube"
      },
      {
        type = "unlock-recipe",
        recipe = "radio-mast"
      }
    },
    prerequisites = {"electric-energy-distribution-1", "advanced-electronics"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        {"high-tech-science-pack", 1},
      },
      time = 30,
      count = 250
    }
  },
  {
    type = "technology",
    name = "astronomy",
    icon = ICON_BASE .. "astronomy.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "telescope"
      },
      {
        type = "unlock-recipe",
        recipe = "observatory"
      }--[[, -- TODO: If ever allowing different recipes in observatories (e.g. looking for different kinds of things, specific ores...) then this needs
             -- unlocking here and set enabled = false in recipe, disenable on migration
      {
        type = "unlock-recipe",
        recipe = "observatory-scan-for-sites"
      }]]
    },
    prerequisites = {"advanced-optics"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        {"production-science-pack", 2},
      },
      time = 30,
      count = 250
    }
  },
  {
    type = "technology",
    name = "microwave-power-transmission",
    icon = ICON_BASE .. "microwave-power-transmission.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "microwave-antenna"
      },
      {
        type = "unlock-recipe",
        recipe = "microwave-transmitter"
      }
    },
    -- TODO: Accumulator tech only needed if antenna has built-in battery... of course you probably want them anyway...
    prerequisites = {"electric-energy-distribution-2", "electric-energy-accumulators-1" , "radio"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"high-tech-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30,
      count = 750
    }
  },
  {
    type = "technology",
    name = "personal-microwave-antenna",
    icon = ICON_BASE .. "personal-microwave-antenna.png",
    icon_size = 128,
    -- miltary
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "personal-microwave-antenna-equipment"
      }
    },
    prerequisites = {"fusion-reactor-equipment", "microwave-power-transmission"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"military-science-pack", 1},
        {"high-tech-science-pack", 1}
      },
      time = 30,
      count = 1000
    }
  },
  {
    type = "technology",
    name = "portal-research",
    icon = ICON_BASE .. "portal-research.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "factorium-processing"
      },
      {
        type = "unlock-recipe",
        recipe = "portal-control-unit"
      },
      {
        type = "unlock-recipe",
        recipe = "portal-science-pack"
      }
    },
    prerequisites = {"advanced-electronics-2"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1}
      },
      time = 60,
      count = 500
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "short-range-teleportation",
    icon = ICON_BASE .. "short-range-teleportation.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "portal-belt"
      },
      {
        type = "unlock-recipe",
        recipe = "portal-chest"
      }
    },
    prerequisites = {"portal-research", "logistics-3", "logistic-system"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"high-tech-science-pack", 1},
        {"production-science-pack", 1},
        {"portal-science-pack", 1}
      },
      time = 60,
      count = 750
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "large-mass-teleportation",
    icon = ICON_BASE .. "large-mass-teleportation.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "medium-portal"
      }
    },
    prerequisites = {"short-range-teleportation"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"military-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"portal-science-pack", 1}
      },
      time = 60,
      count = 750
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "orbital-network",
    icon = ICON_BASE .. "rocket-silo.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "satellite-hangar"
      },
      {
        type = "unlock-recipe",
        recipe = "communication-systems"
      },
      {
        type = "unlock-recipe",
        recipe = "satellite-housing"
      },
      {
        type = "unlock-recipe",
        recipe = "navigation-computer"
      },
      {
        type = "unlock-recipe",
        recipe = "solar-array"
      },
      -- TODO: Quite a lot unlocked here now. Move probe to a different tech? With space telescopes maybe?
      {
        type = "unlock-recipe",
        recipe = "space-probe"
      },
      {
        type = "unlock-recipe",
        recipe = "satellite"
      }
    },
    prerequisites = {"rocket-silo", "astronomy"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"high-tech-science-pack", 1},
        {"production-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 45,
      count = 1000
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "interplanetary-teleportation",
    icon = ICON_BASE .. "interplanetary-teleportation.png",
    icon_size = 128,
    effects =
    {
      -- TODO: Also virtual effect of increasing belt distances? And allow boxes to be further apart
      {
        type = "unlock-recipe",
        recipe = "portal-lander"
      }
    },
    prerequisites = {"orbital-network", "large-mass-teleportation", "astronomy"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"high-tech-science-pack", 1},
        {"production-science-pack", 1},
        {"military-science-pack", 1},
        {"portal-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60,
      count = 1500
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "high-resolution-imaging", -- ? must be a better name than this
    icon = ICON_BASE .. "optics.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "spy-satellite"
      },
    },
    prerequisites = {"orbital-network", "advanced-optics", "radio"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60,
      count = 1500,
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "space-based-solar-power",
    icon = ICON_BASE .. "space-based-solar-power.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "solar-harvester"
      }
    },
    prerequisites = {"orbital-network", "microwave-power-transmission", "solar-energy"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60,
      count = 2000
    }
  },
  {
    type = "technology",
    name = "astronomy-2",
    icon = ICON_BASE .. "space-telescopy.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "space-telescope"
      }
    },
    prerequisites = {"orbital-network", "astronomy", "radio"},
    unit =
    {
      count = 2500,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "orbital-logistics",
    icon = ICON_BASE .. "orbital-logistics.png",
    icon_size = 128,
    prerequisites = {"interplanetary-teleportation", "logistics-3", "radio"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "orbital-logistics-combinator"
      },--[[
      {
        type = "unlock-recipe",
        recipe = "cargo-container"
      },
      {
        type = "unlock-recipe",
        recipe = "cargo-loader"
      },
      {
        type = "unlock-recipe",
        recipe = "cargo-catapult"
      },
      { 
        type = "unlock-recipe",
        recipe = "cargo-drop-site"
      },]]
    },
    unit =
    {
      -- TODO: This is quite easy now but needs to be harder once cargo stuff unlocked
      count = 1000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
  },
  {
    type = "technology",
    name = "zero-gravity-robotics",
    icon = "__base__/graphics/technology/construction-robotics.png",
    prerequisites = {"construction-robotics", "orbital-logistics"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "orbital-repair-station"
      }
    },
    unit =
    {
      count = 3000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
  }--[[
  {
    type = "technology",
    name = "orbital-mining",
    prerequisites = {"long-range-optics"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "orbital-mining-laser"
      },
      {
        type = "unlock-recipe",
        recipe = "orbital-mining-target"
      }
    }
  },

  {
    type = "technology",
    name = "portal-robotics",
    prerequisites = {"construction-robotics", "orbital-logistics"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "portal-construction-robot"
      }
      --,
      --{
--        type = "unlock-recipe",
    --    recipe = "portal-logistics-robot"
  --    }
    }
  },

  {
    type = "technology",
    name = "reusable-rockets",
    icon = "__base__/graphics/technology/rocket-silo.png",
    prerequisites = {"rocket-silo", "orbital-logistics"}, --? uses same landing site as cargo ?--
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "reusable-rocket-part"
      }
    },
    unit =
    {
      count = 3000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1},
        {"military-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
  }

  ]]--
})
