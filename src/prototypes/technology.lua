local ICON_BASE = "__portal-research__/graphics/technology/"
data:extend(
{
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
      -- TODO: Unlock an advanced laser or laser gun or something to make this immediately useful
    },
    prerequisites = {"laser"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 2},
      },
      time = 30,
      count = 200
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
        {"high-tech-science-pack", 1}
      },
      time = 30,
      count = 1000
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
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        {"high-tech-science-pack", 2},
        {"portal-science-pack", 1}
      },
      time = 30,
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
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        {"high-tech-science-pack", 2},
        {"portal-science-pack", 1}
      },
      time = 30,
      count = 500
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
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        {"high-tech-science-pack", 2},
        {"portal-science-pack", 1}
      },
      time = 30,
      count = 500
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
    prerequisites = {"large-mass-teleportation", "astronomy"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        {"high-tech-science-pack", 2},
        {"portal-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 30,
      count = 500
    },
    order = "e-p-b-c"
  },
  {
    type = "technology",
    name = "astronomy",
    icon = ICON_BASE .. "astronomy.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "telescope"
      },
      {
        type = "unlock-recipe",
        recipe = "observatory"
      }
    },
    prerequisites = {"advanced-optics"},
    unit =
    {
      ingredients =
      {
        {"science-pack-1", 2},
        {"science-pack-2", 2},
        {"science-pack-3", 2},
        -- TODO: Slightly on the fence about this, but it might be nice to start looking
        -- for some juicy asteroids well before sending an actual lander up there.
        --{"space-science-pack", 1}, 
      },
      time = 30,
      count = 250
    }
  }--[[,
  {
    type = "technology",
    name = "long-range-optics",
    icon = ICON_BASE .. "long-range-optics.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "space-telescope"
      }
      -- TODO: 
    },
    prerequisites = {"astronomy", "rocket-silo"},
  },
  {
    type = "technology",
    name = "microwave-power-transmission",
    prerequisites = {"long-range-optics"},
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
    }
  },
  {
    type = "technology",
    name = "personal-microwave-antenna",
    -- miltary
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "personal-microwave-antenna-equipment"
      }
    },
    prerequisites = {"modular-armour", "microwave-power-transmission"},
  },
  {
    type = "technology",
    name = "space-based-solar-power",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "solar-array"
      }
    },
    prerequisites = {"long-range-optics", "microwave-power-transmission"},
  },
--[[,
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
    name = "extraplanetary-logistics", -- Does orbital logistics sound betteer even if less accurate?
    prerequisites = {"interplanetary-teleportation", "logistics-3"},
    -- The container could still be used without the catapult to improve throughput if using
    -- another method of cargo delivery (trains, portal boxes/belts), which WILL be necessary anyway.
    -- So could move the catapult unlock to e.g. gravitational mechanics. I dunno...
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "cargo-container"
      },
      {
        type = "unlock-recipe",
        recipe = "cargo-loader" -- ideally doubles as an unloader...
      },
      {
        type = "unlock-recipe",
        recipe = "cargo-catapult"
      },
      { 
        type = "unlock-recipe",
        recipe = "cargo-drop-site"
      },
      {
        type = "unlock-recipe",
        recipe = "orbital-logistics-combinator"
      }
    }
  },
  {
    type = "technology",
    name = "portal-robotics",
    prerequisites = {"construction-robotics", "extraplanetary-logistics"},
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
    name = "zero-gravity-robotics",
    prerequisites = {"construction-robotics", "extraplanetary-logistics"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "orbital-repair-station"
      }
    }
  }]]--
  -- TODO: teletrains! personal teleport. phase ammo.
  -- Portal destruction planner. portal bulk move, orbital factory deployment...
})
