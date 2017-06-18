local inspect = require("lib.inspect")
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

function Sites.list(force, predicate)
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
      if (v.force == force or v.surface and v.surface.name == "nauvis")
        and (predicate == nil or predicate(v)) then
        return v
      end
    end
  end
end

function Sites.generateAsteroidName()
  local name
  local done
  while not done do
    -- Simple random asteroid name generator "ABC-1234"
    name = ""
    for i = 1, (math.random(2)+math.random(2)) do
      name = name .. Util.charset[26 + math.random(24)]
    end
    name = name .. "-"
    for i = 1, (math.random(3)+math.random(2)) do
      name = name .. Util.charset[52 + math.random(10)]
    end
    -- Check the name isn't a duplicate
    done = true
    for i,site in pairs(global.sites) do
      if site.name == name then
        done = false
        break
      end
    end
  end
  return name
end

function Sites.generateRandom(force, scanner)
  forceData = getForceData(force)
  local site = {
    size = math.random(3), -- TODO: Use scanner.scan_strength
    name = "",
    resources = {},
    resources_estimated = true,
    force = force,
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

  site.name = Sites.generateAsteroidName()
  site.surface_name = "Asteroid " .. site.name

  -- Store in global table
  global.sites[site.surface_name] = site
  -- TODO: Have a sites_by_surface lookup, sites should be by name, to optimise duplicate checking
  -- TODO: Handle deletion of sites

  Sites.generateResourceEstimate(site)
  return site
end

local function averageResourceAmountOnTile(resource, site)
  return math.floor(5000 * site.distance * resource.richness * 0.5)
end

local function resourceAmountOnTile(resource, site)
  return math.max(0, math.floor(5000 * site.distance * resource.richness * (math.random() - 0.1)))
end

  -- TODO: Actually restrict the resources to iron, copper, stone, uranium (v rare). Player still
  -- needs trains to get coal, stone, factorium, oil, poss uranium, and any other modded ores.
  -- Should provided a script interface allowing mods to make their ores available.
  -- (Well. Would be nice to have liquid logistics. Consider allowing oil, or a whole new type
  -- of liquid. Possible candidates are lava on volcanic asteroids/moons {process to acquire metal
  -- ores? use heat for power generation?}, or a liquid that Factorium can be extracted from,
  -- or something else...)
-- TODO: Provide an interface to add new ores
local offworld_resources = {
  {
    name="iron-ore",
    weight=120,
    richness=1
  },
  {
    name="copper-ore",
    weight=100,
    richness=1.2
  },
  {
    name="stone",
    weight=200,
    richness=0.8
  },
  {
    name="uranium",
    weight=1,
    richness=0.05
  }
}

function Sites.generateResourceEstimate(site)
  -- Resource estimation
  site.resources = {}

  -- Give each resource in turn a chance to be spawned
  local chance = 0.95 -- 1/20 chance of barren asteroid, slim chance of secondary resource
  while true do
    if (math.random() > chance) then break end

    local picked = Util.randomWeighted(offworld_resources)
    if site.resources[picked.name] then
      -- Same one twice, bump the amount
      site.resources[picked.name].richness = site.resources[picked.name].richness + math.random() * picked.richness
    else
      site.resources[picked.name] = {
        resource = picked,
        -- TODO: More control over resource sizes, also adjust amounts against game settings
        richness = math.random() * picked.richness
      }
    end
    -- Reduce chance for secondary/more resources
    chance = chance / 3
  end

  -- Now estimate total quantities for everything
  -- TODO: More variance in the final result - occasionally not even finding the resource / finding
  -- different ones
  local sizeSpec = site_sizes[site.size]
  local avgSize = (sizeSpec.max_size + sizeSpec.min_size)/2
  local avgArea = math.ceil(math.pi * avgSize * avgSize)
  for i,estimate in pairs(site.resources) do
    -- Note: This estimate doesn't really work properly when multiple types of a resource,
    -- probably can improve the math (but, hey, it's only supposed to be an estimate)
    estimate.amount = averageResourceAmountOnTile(estimate, site) * avgArea
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
  -- TODO: For now; implement variable day/night later
  surface.freeze_daytime = true
  --surface.request_to_generate_chunks({0, 0}, 3) -- More?

  local halfWidth = math.ceil(site.width / 2)
  local halfHeight = math.ceil(site.height / 2)

  local actual_resources = {}
  local tiles = {}

  -- TODO: Loads of improvements to terrain generation: Distort asteroid shape with perlin, use
  -- some custom ground tiles, tidy up the edges, have mixed resources generate in more
  -- interesting patterns. Misc debris and junk.
  for x = -site.width, site.width do
    for y = -site.height, site.height do
      local dist = math.sqrt(math.pow(x/halfWidth,2) + math.pow(y/halfHeight,2))
      if dist<=1 then
        table.insert(tiles, {name="red-desert-dark", position={x=x,y=y}})

        -- Use whichever resources comes out bigger
        local max_resource = nil
        local max_amount = 0
        for i,estimate in pairs(site.resources) do
          local amount = resourceAmountOnTile(estimate, site)
          if amount > max_amount then
            max_resource = estimate
            max_amount = amount
          end
        end
        if max_resource then
          -- Create the resource tile and update the actual count
          surface.create_entity({
            name=max_resource.resource.name,
            amount=max_amount,
            position={x=x,y=y}
          })
          if not actual_resources[max_resource.resource.name] then
            actual_resources[max_resource.resource.name] = {
              resource = max_resource.resource,
              amount = max_amount
            }
          else
            actual_resources[max_resource.resource.name].amount = actual_resources[max_resource.resource.name].amount + max_amount
          end
        end
      else
        table.insert(tiles, {name="deep-space", position={x=x,y=y}})
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
  local gate = surface.create_entity{name="medium-portal", position={x=0,y=0}, force = site.force}
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
    site.force.chart(surface, {{-halfWidth,-halfHeight},{halfWidth,halfHeight}})
  end

  -- Updates the sites_by_surface table
  -- TODO: Not really happy with this, if these kind of calls are getting silly then need some
  -- system for central entity/force/player/data management.
  verifySiteData(site)

  return newPortal
end

return Sites