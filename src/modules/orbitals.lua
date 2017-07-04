-- Orbitals units. Usually these are just data but sometimes we might need to hide
-- a real entity somewhere to do their work.

local Orbitals = {}

local orbital_update_time_min = 2250
local orbital_update_time_var = 1500

local function registerNextTick(orbital)
  orbital.next_update_tick = Ticks.after(orbital_update_time_min + math.random(orbital_update_time_var),
    "orbital.update", {orbital=orbital})
end

function Orbitals.init()
  if not global.orbital_counts then
    global.orbital_counts = {}
    for id,orbital in pairs(global.orbitals) do
      if not global.orbital_counts[orbital.name] then
        global.orbital_counts[orbital.name] = 1
      else
        global.orbital_counts[orbital.name] = global.orbital_counts[orbital.name] + 1
      end
    end
  end
  for i,orbital in pairs(global.orbitals) do
    if not orbital.next_update_tick then
      registerNextTick(orbital)
      orbital.health = 1000 -- Better health
    end
  end
end

function Orbitals.list(options)
  local orbitals = global.orbitals
  local k,v = next(orbitals)
  return function()
    if not k then return nil end
    while true do
      k,v = next(orbitals, k)
      if not k then break end
      if (not options.force or v.force == options.force)
        and (not options.orbital_type or v.name == options.orbital_type) then
        return v
      end
    end
  end
end

local orbital_types = {
  --['satellite'] = {

  --},
  ['portal-lander'] = {

  },
  ['solar-harvester'] = {

  },
  ['space-telescope'] = {

  }
}

function Orbitals.newUnit(name, force, launchSite, data)
  local orbital = {
    id = name .. "-" .. global.next_orbital_id,
    name = name,
    health = 1000,
    created_at = game.tick,
    is_orbital = true,
    force = force,
    data = data,
    site = launchSite
  }

  -- Store and increment id count
  global.orbitals[orbital.id] = orbital
  global.next_orbital_id = global.next_orbital_id + 1
  global.orbital_counts[orbital.name] = global.orbital_counts[orbital.name] + 1

  if orbital.name == "portal-lander" then
    global.landers[orbital.id] = orbital
  elseif orbital.name == "solar-harvester" then
    global.harvesters[orbital.id] = orbital
    global.transmitters[orbital.id] = orbital
    Power.updateMicrowaveTargets()
  elseif orbital.name == "space-telescope" then
    -- Create a worker entity
    Scanners.setupWorkerEntity(orbital)
    global.scanners[orbital.id] = orbital
  end

  -- TODO: Only open if nothing else focused? Or wait in a queue until thing is closed. Notification message.
  Gui.update{tab="orbitals", force=orbital.force, object=orbital, show=true}

  return orbital
end

function Orbitals.update(orbital)
  -- Lose a random amount of health, 2d6 / 2
  -- TODO: Shielding, and other factors
  orbital.health = orbital.health - math.floor((math.random(6) + math.random(6))/2)
  if orbital.health <= 0 then
    Gui.message{force=orbital.force,target=orbital,
      message={"portal-research.orbital-messages.orbital-died-disrepair", {"item-name." .. orbital.name}, Sites.getSiteName(orbital.site)}
    }
    Orbitals.remove(orbital)
  else
    -- TODO: Warn when health dips under 25%
    registerNextTick(orbital)
  end
end

Ticks.registerHandler("orbital.update", function(data)
  Orbitals.update(data.orbital)
end)

function Orbitals.remove(orbital)
  orbital.deleted = true
  global.orbitals[orbital.id] = nil
  if orbital.next_update_tick then
    Ticks.cancel(orbital.next_update_tick)
  end

  if orbital.name == "portal-lander" then
    global.landers[orbital.id] = nil
  elseif orbital.name == "solar-harvester" then
    global.harvesters[orbital.id] = nil
    global.transmitters[orbital.id] = nil
    Power.updateMicrowaveTargets()
  elseif orbital.name == "space-telescope" then
    global.scanners[orbital.id] = nil
    Scanners.destroyWorkerEntity(orbital)
  end
  
  global.orbital_counts[orbital.name] = global.orbital_counts[orbital.name] - 1
  Gui.update{tab="orbitals", force=orbital.force, object=orbital}
end

function Orbitals.orbitalArrivedAtSite(orbital)
  local site = orbital.transit_destination

  orbital.site = site
  orbital.transit_destination = nil
  orbital.in_transit = false
  orbital.transit_complete_tick = nil
  Gui.message{
    force = orbital.force,
    target = orbital,
    message = {"portal-research.orbital-messages.orbital-arrived-at", {"item-name." .. orbital.name}, Sites.getSiteName(orbital.site)}
  }
  if orbital.name == "portal-lander" and not site.surface_generated then
    -- Portal is deployeed, generate the asteroid and delete the orbital
    -- TODO: lander can revert to a normal satellite - justifies being able to carry on
    -- seeing/locating the portal, and receiving ongoing data about the asteroid
    -- BUT just a comms satellite, not a spy one
    local portal = Sites.generateSurface(site, orbital.force)
    Orbitals.remove(orbital)
    Gui.message{
      force = orbital.force,
      orbital = orbital,
      target = portal,
      message = {"portal-research.orbital-messages.portal-lander-deployed", Sites.getSiteName(orbital.site)}
    }
  end
  if orbital.name == "solar-harvester" then
    Power.updateMicrowaveTargets()
  end
  Gui.update{tab="orbitals", force=orbital.force, object=orbital}
end

-- TODO: Function should be optimised with a lookup of orbitals at each site. Also use
-- this information to show orbital counts etc on sites list.
function Orbitals.anyOrbitalsAtSite(site)
  for i,orbital in pairs(global.orbitals) do
    if orbital.site == site or orbital.transit_destination == site then
      return true
    end
  end
end

local function orbitalSpeed(orbital)
  -- TODO: Orbital speed should vary with research, mass of orbital, # of thrusters
  return 0.1
end

function Orbitals.sendOrbitalToSite(orbital, site)
  -- Because the model of space is simplified to 1D, we move the orbital a theoretical "maximum";
  -- i.e. it has to first move back to the origin, then move all the way to the target site.
  local distance_to_move = orbital.site.distance + site.distance
  local speed = orbitalSpeed(orbital)
  -- But if it was already in transit then it may already have gone part-way to origin or even further
  if orbital.in_transit then
    Ticks.cancel(orbital.transit_complete_tick)
    local distance_moved = (orbital.transit_complete_tick.tick - game.tick) * speed / 60
    local distance_to_origin = math.abs(distance_moved - orbital.site.distance)
    distance_to_move = distance_to_origin + site.distance
  end
  local ticks_to_move = 60 * distance_to_move / speed
  --orbital.force.print("Arrival in " .. ticks_to_move .. " ticks")
  -- TODO: Some ticks along the way for fun stuff to happen
  orbital.transit_complete_tick = Ticks.after(ticks_to_move, "orbital.arrive_at_destination", {orbital=orbital})
  orbital.transit_destination = site
  orbital.transit_distance = distance_to_move
  orbital.in_transit = true
  orbital.started_transit_at = game.tick

  Gui.message{
    force = orbital.force,
    orbital = orbital,
    target = site,
    message = {"portal-research.orbital-messages.orbital-will-arrive-in",
      {"item-name." .. orbital.name},
      Sites.getSiteName(orbital.transit_destination),
      Util.round(ticks_to_move/60, 1),
      Util.round(orbital.transit_distance,1)
    }
  }
end

Ticks.registerHandler("orbital.arrive_at_destination", function(data)
  Orbitals.orbitalArrivedAtSite(data.orbital)
end)

-- GUI

function Orbitals.commonOrbitalDetails(playerData, orbital, gui, window_options)
  gui.add{type="sprite", sprite="item/" .. orbital.name}
  gui.add{type="label", caption={"portal-research.orbital-location-caption"}}  
  siteMiniDetails(playerData.player, orbital.site, gui)
  if orbital.in_transit then
    gui.add{type="label", caption={"portal-research.orbital-transitting-caption"}}
    siteMiniDetails(playerData.player, orbital.transit_destination, gui)
    -- TODO: Assumptions here and elsewhere that speed is constant (for now it is).
    local time_to_arrival = (orbital.transit_complete_tick.tick - game.tick)/60
    gui.add{type="label", caption={"portal-research.orbital-eta-caption", Util.round(time_to_arrival, 1), Util.round(orbital.transit_distance,1)}}
    gui.add{type="progressbar", size=200, value = (game.tick - orbital.started_transit_at)/(orbital.transit_complete_tick.tick - orbital.started_transit_at)}
  else
    -- TODO: Add a function to build a "standard" camera widget with map toggle^B^B^B^B and zoom support
    if orbital.site.is_offworld and orbital.site.surface_generated then
      local preview_size = 200
      local camera = gui.add{
        type="camera",
        position={x=0,y=0},
        surface_index = orbital.site.surface.index,
        zoom = 0.15
      }
      camera.style.minimal_width = preview_size
      camera.style.minimal_height = preview_size
    end
  end
  Gui.createButton(playerData.player, gui, {
    name = "change-orbital-destination-" .. orbital.id,
    caption={"portal-research.change-destination-caption"},
    action={name="change-orbital-destination",orbital=orbital,window="secondary-pane"},
    window="object-detail"
  })
    -- TODO: Tick to update every second
end

function Orbitals.buildOrbitalsList(player, root, options)
  local options = options or {}
  local list = Orbitals.list{force=player.force, orbital_type=options.orbital_type}
  local playerData = getPlayerData(player)
  local filter_row = root.add{type="flow",direction="horizontal"}

  for name,data in pairs(orbital_types) do
    Gui.createButton(player, filter_row, {
      name="filter-orbitals-list-" .. name,
      sprite="item/" .. name,
      action={name="filter-orbitals-list",type=name,window=options.window},
      caption={"item-name." .. name}
    })
  end
  local table = root.add{type="table",colspan=6}
  for orbital in list do
    --local row = root.add{type="flow",direction="horizontal"}
    local name_base = "-orbital-" .. orbital.id .. "-button"

    table.add{
      type="sprite",
      sprite="item/" .. orbital.name,
      tooltip={"item-name." .. orbital.name}
    }

    --[[local healthSprite = table.add{
      type="sprite",
      sprite="util/bonus-icon",
      tooltip={"portal-research.health-bar-caption"}
      }
    healthSprite.style.maximal_width = 32
    healthSprite.style.maximal_height = 32]]

    table.add{type="progressbar", size=32, value = orbital.health/1000, tooltip={"portal-research.health-bar-caption"}}

    if orbital.in_transit then
      siteMiniDetails(player, orbital.transit_destination, table, false)
      table.add{type="progressbar", size=32, value=(game.tick - orbital.started_transit_at)/(orbital.transit_complete_tick.tick - orbital.started_transit_at),
        -- TODO: Display actual ETA on tooltip
        tooltip={"portal-research.orbital-eta-bar-caption"}
      }
    else
      siteMiniDetails(player, orbital.site, table, false)
      -- Empty cells
      table.add{type="flow"}
    end

    Gui.createButton(player, table, {
      name="view-orbital-details-" .. orbital.id,
      caption={"portal-research.portal-details-button-caption"},
      action={name="orbital-details",orbital=orbital},
      window=options.window
    })
  end
    -- TODO: Tick to update every second
end

function Orbitals.pickOrbitalDestination(player, orbital, options)
  local window_options = {
    window="secondary-pane",
    caption={"gui-portal-research.orbital-destination-select-caption." .. orbital.name},
    object=orbital
  }
  local gui = Gui.openWindow(player, window_options)
  local playerData = getPlayerData(player)

  local predicate = function(site)
    -- Landers must go to a site without a portal; everything else can go to asteroids
    -- or nauvis. TODO: Maybe miners should only go to asteroids?
    return (orbital.name == "portal-lander" and site.is_offworld
      and not site.surface_generated and not site.has_portal) 
      or (orbital.name ~= "portal-lander" and (site.is_offworld or site.name=="nauvis"))
  end

  -- TODO: The buttons system is pretty horrible, could be improved
  Gui.buildSitesList(player, Sites.list(player.force, predicate), gui, {
    extra_buttons = {
      function(site)
        return {
          name="orbital-" .. orbital.id .. "-pick-destination-" .. site.name,
          caption={"portal-research.pick-destination-button-caption"},
          action={name="pick-orbital-destination",orbital=orbital,destination=site},
          window="secondary-pane"
        }
      end
    }
  })
end

function Orbitals.getCounts()
  return global.orbital_counts
end

return Orbitals