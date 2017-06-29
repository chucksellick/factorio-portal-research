-- Orbitals units. Usually these are just data but sometimes we might need to hide
-- a real entity somewhere to do their work.

-- TODO: hidden surface for placing fake worker entities

local Orbitals = {}

function Orbitals.list(force)
  local orbitals = global.orbitals
  local k,v = next(orbitals)
  return function()
    if not k then return nil end
    while true do
      k,v = next(orbitals, k)
      if not k then break end
      if v.force == force then
        return v
      end
    end
  end
end

function Orbitals.newUnit(name, force, launchSite, data)
  local orbital = {
    id = name .. "-" .. global.next_orbital_id,
    name = name,
    health = 100,
    created_at = game.tick,
    is_orbital = true,
    force = force,
    data = data,
    site = launchSite
  }

  -- Store and increment id count
  global.orbitals[orbital.id] = orbital
  global.next_orbital_id = global.next_orbital_id + 1

  if orbital.name == "portal-lander" then
    global.landers[orbital.id] = orbital
  elseif orbital.name == "space-telescope" then
    -- Create a worker entity
    Scanners.setupWorkerEntity(orbital)
    global.scanners[orbital.id] = orbital
  elseif orbital.name == "solar-harvester" then
    global.harvesters[orbital.id] = orbital
    global.transmitters[orbital.id] = orbital
    Power.updateMicrowaveTargets()
  end

  -- TODO: Only open if nothing else focused? Or wait in a queue until thing is closed. Notification message.
  Gui.update{tab="orbitals", force=orbital.force, object=orbital, show=true}

  return orbital
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

function Orbitals.remove(orbital)
  global.orbitals[orbital.id] = nil
  -- TODO: Update microwave links if harvester
  Gui.update{tab="orbitals", force=orbital.force, object=orbital}
end

Ticks.registerHandler("orbital.arrive_at_destination", function(data)
  Orbitals.orbitalArrivedAtSite(data.orbital)
end)

return Orbitals