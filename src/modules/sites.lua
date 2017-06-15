local Sites = {}

local site_sizes = {
  {
    name = "very-small",
    min_size = 20,
    max_size = 40
  },
  {
    name = "small",
    min_size = 35,
    max_size = 80
  },
  {
    name = "medium",
    min_size = 70,
    max_size = 120
  },
  {
    name = "large",
    min_size = 100,
    max_size = 160
  },
  {
    name = "very-large",
    min_size = 150,
    max_size = 250
  }
}

function Sites.getSize(size)
  return site_sizes[size]
end

function Sites.list(force)
  -- TODO: Getting a bit painful (and not very optimal) to have to filter
  -- everything by force. Probably better to separate all the data now rather
  -- than have a really complex migration later.
  -- But do give this some thought, data management also needs to be optimal
  -- and this iterator is probably quite efficient. Also functions like this
  -- are typically only called when rendering GUIs
  local sites = global.sites
  local k,v = next(sites)
  return function()
    if not k then return nil end
    while true do
      k,v = next(sites, k)
      if not k then break end
      if v.force == force.name or v.surface and v.surface.name == "nauvis" then
        return v
      end
    end
  end
end

-- TODO: Provide an interface to add new ores
local offworld_resources = {
  {
    name="iron-ore",
    weight=1.2
  },
  {
    name="copper-ore",
    weight=1
  },
  {
    name="stone",
    weight=2
  },
  {
    name="uranium",
    weight=0.01
  }
}

function Sites.generateRandom(force, scanner)
  forceData = getForceData(force)
  local site = {
    size = math.random(3), -- TODO: Use scanner.scan_strength
    name = "",
    resources = {},
    resources_estimated = true,
    force = force.name,
    surface_generated = false,
    -- TODO: This directly translates to a light level but the exact curve is not clear. 0 is full daylight, 0.5 is midnight ... in between there is a curve.
    -- Solar panels still give 100% at 0.25 but start losing power at 0.3 and have lost most at 0.4.
    daytime = math.random(),
    portals = {},
    is_offworld = true,
    has_portal = false
  }

  -- TODO: Needs quite a bit of tweaking
  -- TODO: Use scanner.scan_strength
  site.distance = 1 + math.random() * forceData.site_distance_multiplier

  -- Simple random asteroid name generator "ABC-1234"
  -- TODO: Check no duplicate names
  for i = 1, 3 do
    site.name = site.name .. Util.charset[26 + math.random(24)]
  end
  site.name = site.name .. "-"
  for i = 1, 4 do
    site.name = site.name .. Util.charset[52 + math.random(10)]
  end
  site.surface_name = "Asteroid " .. site.name

  -- Store in global table
  global.sites[site.surface_name] = site
  -- TODO: Currently surfaces can never be destroyed but if they ever can, need to handle deletion of sites
  -- Also if all portals are removed due to catastrophe then we could remove the site

  -- Resource estimation
  -- First, copy and shuffle the raw resource table
  local resources = {}
  -- TODO: Slow, precache this list at startup, shuffle the same table each time
  for _, entity in pairs(game.entity_prototypes) do
    if entity.type == "resource" then
      table.insert(resources, entity)
    end
  end
  Table.shuffle(resources)

  -- Give each resource in turn a chance to be spawned
  local chance = 0.95 -- 1/20 chance of barren asteroid, 42.5% chance of secondary resource
  -- TODO: Actually restrict the resources to iron, copper, stone, uranium (v rare). Player still
  -- needs trains to get coal, stone, factorium, oil, poss uranium, and any other modded ores.
  -- Should provided a script interface allowing mods to make their ores available.
  -- (Well. Would be nice to have liquid logistics. Consider allowing oil, or a whole new type
  -- of liquid. Possible candidates are lava on volcanic asteroids/moons {process to acquire metal
  -- ores? use heat for power generation?}, or a liquid that Factorium can be extracted from,
  -- or something else...)
  for _, resource in pairs(resources) do
    if (math.random() > chance) then break end

    table.insert(site.resources, {
      resource = resource,
      -- TODO: More control over resource sizes
      -- TODO: Also vary chance of different resources based on scarcity
      amount = math.random()
    })
    -- Halve the chance next time
    chance = chance / 2
  end

  return site
end

-- Creates the actual game surface
function Sites.generateSurface(site)

  local sizeSpec = site_sizes[site.size]
  site.width = math.random(sizeSpec.max_size - sizeSpec.min_size) + sizeSpec.min_size
  site.height = math.random(sizeSpec.max_size - sizeSpec.min_size) + sizeSpec.min_size

  -- TODO: Use a similar thing from Factorissimo where surfaces are reused with asteroids very far apart.
  -- However this would preclude the possibility of space platform building :(

  local surface = game.create_surface(site.surface_name, {width=2,height=2})--mapgen)
  surface.daytime = site.daytime or 0
  surface.freeze_daytime = true -- TODO: For now, implement variable day/night later
  --surface.request_to_generate_chunks({0, 0}, 3) -- More?

  local tiles = {}
  local halfWidth = math.ceil(site.width / 2)
  local halfHeight = math.ceil(site.height / 2)
  local estimate = site.resource_estimate[1]

  local resources = {}

  for x = -halfWidth, halfWidth do
    for y = -halfHeight, halfHeight do
      -- TODO: Distort shape with perlin
      local dist = math.sqrt(math.pow(x/halfWidth,2) + math.pow(y/halfHeight,2))
      if dist<=1 then
        -- TODO: Vary the ground tiles used, add some custom ones
        table.insert(tiles, {name="red-desert-dark", position={x=x,y=y}})
        surface.create_entity({
          name=estimate.resource.name,
          -- TODO: Improve this formula a lot, e.g. distance scaling (both site distance and position distance from center of patch), better estimate of total resource amount depending on # of tiles, different resources, oil, blah blah blah
          amount = math.max(1, 5000 * (estimate.amount + (math.random() - 0.5 / 2))),
          position={x=x,y=y}
        })
      end
    end
  end

  --[[
      richness_multiplier = 6000,
      richness_multiplier_distance_bonus = 50,
      richness_base = 500,
  ]]

  site.resources = resources
  surface.set_tiles(tiles)

  -- TODO: Randomise landing position
  local gate = surface.create_entity{name="medium-portal", position={x=0,y=0}, force = game.forces[site.force]}
  -- Ensure the entity has data, onCreated event (probably) doesn't fire when placing entities like this
  -- TODO: Check the above!
  local newPortal = getEntityData(gate)
  newPortal.fully_charged = true

  -- TODO: Create some crater marks and a little fire and debris on the ground, maybe some other deployment-related entities.

  -- TODO: Update site data with real resource count

  site.surface = surface
  site.surface_generated = true

  -- To make void chunks show up on the map, you need to tell them they've finished generating.
  for cx = -2,1 do
    for cy = -2,1 do
      surface.set_chunk_generated_status({cx, cy}, defines.chunk_generated_status.entities)
    end
  end

  -- TODO: force.chart to reveal map properly?
  if site.force then
    game.forces[site.force].chart(surface, {{-halfWidth,-halfHeight},{halfWidth,halfHeight}})
  end

  -- Updates the sites_by_surface table
  -- TODO: Not really happy with this, if these kind of calls are getting silly then need some
  -- system for central entity/force/player/data management.
  verifySiteData(site)

  return newPortal
end

return Sites