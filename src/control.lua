--[[

  Portals!

  Some general ideas/todos:

  * Environmental conditions on asteroids.
    - Different day/night cycle
    - No wind but is there anything to affect?
    - No burners allowed in atmosphere. (Unless some crazy atmosphericc bubble constructed)
    - No clouds :(
  * Camera system similar to trains / factorissimo
--]]

require("mod-gui")
require("silo-script")

script.on_init(On_Init)

local site_sizes = {
  {
    name = "small",
    min_size = 20,
    max_size = 50,
    terrain_segmentation = "small"
  },
  {
    name = "medium",
    min_size = 45,
    max_size = 125,
    terrain_segmentation = "medium"
  },
  {
    name = "large",
    min_size = 120,
    max_size = 250,
    terrain_segmentation = "big"
  }
}

local autoplace_sizes = { "very-low",
                          "low",
                          "normal",
                          "high",
                          "very-high" }

-- Adapted from https://gist.github.com/haggen/2fd643ea9a261fea2094
local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 97, 122 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 48,  57 do table.insert(charset, string.char(i)) end

function newPortalData(force)
  return {
    known_offworld_sites = {},
    home_site = newHomeSiteData(force)
  }
end

function verifySiteData(site, force)
end

function verifyPortalData(data, force)
  if data.home_site == nil then
    data.home_site = newHomeSiteData()
  end
  verifySiteData(data.home_site, force)
  for i, site in pairs(data.known_offworld_sites) do
    verifySiteData(data, force)
  end
end

function newHomeSiteData(force)
  return {
    name = "Nauvis",
    force = force,
    surface_generated = true,
    surface = game.surfaces["nauvis"],
    -- TODO: Logarythmic scale, increases with research, more resources found farther afield
    distance = 0
  }
end

function On_Init()
  --generateEvents()

  if not global.portals_by_entity then
    global.portals_by_entity = {}
  end

  if not global.forces_portal_data then
    global.forces_portal_data = {}
    global.forces_portal_data["player"] = newPortalData("player")
  end
  for i,data in pairs(global.forces_portal_data) do
    verifyPortalData(data, i)
  end
  remote.call("silo_script", "add_tracked_item", "portal-lander")
  remote.call("silo_script", "update_gui")
end

script.on_event(defines.events.on_force_created, function(event)
  On_Init()
  global.forces_portal_data[event.force.name] = {}
end)

script.on_configuration_changed(On_Init)

script.on_event(defines.events.on_rocket_launched, function(event)
  if event.rocket.get_item_count("portal-lander") == 0 then return end
  local force = event.rocket.force
  local forceData = global.forces_portal_data[force.name]
  local newSite = randomOffworldSite(force)

  table.insert(forceData.known_offworld_sites, newSite)

  --table.insert(global.forces_portal_data[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
  --global.IonCannonLaunched = true
  --script.on_event(defines.events.on_tick, process_tick)

  force.print({"site-discovered", newSite.name})

  for i, player in pairs(force.connected_players) do
    initGUI(player)
    showSiteDetailsGUI(player, newSite)
  end

  --[[
  for i, player in pairs(force.connected_players) do
    init_GUI(player)
    if settings.get_player_settings(player)["ion-cannon-play-voices"].value then
      playSoundForPlayer("ion-cannon-charging", player)
    end
  end
  if #global.forces_ion_cannon_table[force.name] == 1 then
    force.print({"congratulations-first"})
    force.print({"first-help"})
    force.print({"second-help"})
    force.print({"third-help"})
  else
    force.print({"congratulations-additional"})
    force.print({"ion-cannons-in-orbit" , #global.forces_ion_cannon_table[force.name]})
    -- force.print({"time-to-ready" , #global.forces_ion_cannon_table[force.name] , settings.global["ion-cannon-cooldown-seconds"].value})
  end
  ]]--
end)

function shuffleTable( t )
    local rand = math.random
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function implode(list, delimiter)
  local len = #list
  if len == 0 then
    return ""
  end
  local string = list[1]
  for i = 2, len do
    string = string .. delimiter .. list[i]
  end
  return string
end

function getPortalByEntity(entity)
  local portal = global.portals_by_entity[entity.unit_number]
  if portal == nil then
    portal = {
      teleport_target = nil,
      entity = entity
    }
    global.portals_by_entity[entity.unit_number] = portal
  end
  return portal
end

function findPortalInArea(surface, area)
  local candidates = surface.find_entities_filtered{area=area, name="medium-portal"}
  for _,entity in pairs(candidates) do
    return getPortalByEntity(entity)
  end
  return nil
end

function randomOffworldSite(force)
  local site = {
    size = math.random(3),
    name = "",
    resource_estimate = {},
    force = force.name,
    surface_generated = false,
    -- TODO: Logarythmic scale, increases with research, more resources found farther afield
    distance = 1 + math.random()
  }
  -- Simple random asteroid name generator "ABC-1234"
  -- TODO: Check no duplicate names
  for i = 1, 3 do
    site.name = site.name .. charset[26 + math.random(24)]
  end
  site.name = site.name .. "-"
  for i = 1, 4 do
    site.name = site.name .. charset[52 + math.random(10)]
  end

  -- Resource estimation
  -- First, copy and shuffle the raw resource table
  local resources = {}
  -- TODO: Slow, precache this list at startup, shuffle the same table each time
  for _, entity in pairs(game.entity_prototypes) do
    if entity.type == "resource" then
      table.insert(resources, entity)
    end
  end
  shuffleTable(resources)

  -- Give each resource in turn a chance to be spawned
  local chance = 0.95 -- 1/20 chance of barren asteroid, 42.5% chance of secondary resource
  for _, resource in pairs(resources) do

    if (math.random() > chance) then break end

    table.insert(site.resource_estimate, {
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

function initGUI(player)
  if #global.forces_portal_data[player.force.name].known_offworld_sites == 0 then return end

  local button_flow = mod_gui.get_button_flow(player)
  if button_flow.portal_research_gui_button then
    button_flow.portal_research_gui_button.destroy()
  end
  local button = button_flow.add {
    --type = "sprite-button",
    type="button",
    name = "portal_research_gui_button",
    --sprite = "item/rocket-silo",
    style = mod_gui.button_style,
    caption = {"gui-portal-research.portals-button-caption"},
    tooltip = {"gui-portal-research.portals-button-tooltip"}
  }
end

function showSiteDetailsGUI(player, site)

  local detailsFrame = player.gui.center.add{type="frame", name="portal-site-details", caption={"site-details-caption", site.name}}
  local detailsFlow = detailsFrame.add{type="flow", direction="vertical"}
  local detailsTable = detailsFlow.add{type="table", colspan="2"}
  local function addDetailRow(label, value)
    --local detailRow = detailsTable.add{type="flow", direction="horizontal"}
    detailsTable.add{type="label", caption={"site-details-label-"..label}}
    detailsTable.add{type="label", caption=value}
  end

  addDetailRow("name", site.name)
  addDetailRow("size", {"site-size-" .. site_sizes[site.size].name})
  addDetailRow("distance", site.distance)

  detailsFlow.add{type="label", caption={"estimated-resources-label"}}

  if #site.resource_estimate == 0 then
    detailsFlow.add{type="label", caption={"estimated-resources-none"}}
  else
    local resourceTable = detailsFlow.add{type="table", colspan="2"}

    for i,estimate in pairs(site.resource_estimate) do
      resourceTable.add{type="label", caption={"entity-name."..estimate.resource.name}}
      resourceTable.add{type="label", caption=estimate.amount}
    end
  end

  detailsFlow.add{type="button", name="close-site-details-button", caption={"close-dialog-caption"}}
end

local guiPortalTargetButtons = {}
local guiPortalCurrent = nil

function openPortalTargetSelectGUI(player, portal)

  if player.gui.center["portal-target-select"] then
    return
  end

  guiPortalTargetButtons = {}
  guiPortalCurrent = portal

  local dialogFrame = player.gui.center.add{
    type="frame",
    name="portal-target-select",
    caption={"gui-portal-research.portal-target-select-caption"}
  }
  local targetsFlow = dialogFrame.add{type="flow", direction="vertical"}
  local forceData = global.forces_portal_data[player.force.name]
  for i,site in pairs(forceData.known_offworld_sites) do
    local newButton = targetsFlow.add{type="button", name="portal-target-select-" .. site.name, caption=site.name}
    guiPortalTargetButtons[newButton.name] = site
  end

  targetsFlow.add{type="button", name="cancel-portal-target-select", caption={"cancel-dialog-caption"}}

end

function closePortalTargetSelectGUI(player)

  guiPortalTargetButtons = nil
  guiPortalCurrent = nil
  if player.gui.center["portal-target-select"] then
    player.gui.center["portal-target-select"].destroy()
  end

end

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.element.player_index]
  local name = event.element.name
  if name == "portals-button" then
  end
  if name == "close-site-details-button" then
    player.gui.center["portal-site-details"].destroy()
    return
  end
  if name == "cancel-portal-target-select" then
    closePortalTargetSelectGUI(player)
    return
  end

  if string.find(name, "portal-target-select-", 1, true) then
    guiPortalCurrent.teleport_target = guiPortalTargetButtons[name]
    closePortalTargetSelectGUI(player)
    return
  end
end)

-- Creates the actual game surface
function generateSiteSurface(site)

  local sizeSpec = site_sizes[site.size]
  site.width = math.random(sizeSpec.max_size - sizeSpec.min_size) + sizeSpec.min_size
  site.height = math.random(sizeSpec.max_size - sizeSpec.min_size) + sizeSpec.min_size

  --[[
  local mapgen = {
    terrain_segmentation = "normal",-- sizeSpec.terrain_segmentation,
    water = "none",
    autoplace_controls={},
    width = site.width, -- TODO: For space platform expansion, these should be 0 (infinite)
    height = site.height,
    -- seed = 123456, -- TODO: Decided seed at launch to prevent re-roll?
    starting_area = "normal",
    peaceful_mode = true -- TODO: For now ;) But some asteroids should probably have threats
  }

  for i, estimate in pairs(site.resource_estimate) do
    local sizeName = autoplace_sizes[math.floor(estimate.amount * 5 + 1)]
    mapgen.autoplace_controls[estimate.resource.name] = {
      frequency = sizeName,
      size = sizeName,
      richness = sizeName
    }
  end
  ]]--

  -- TODO: Use a similar thing from Factorissimo where surfaces are reused with asteroids very far apart.
  -- However this would preclude the possibility of space platform building :(

  local surface = game.create_surface("Asteroid " .. site.name, {width=2,height=2})--mapgen)
  surface.daytime = 0.5 -- Make things dark even tho really not sure how realistic that is ;)
  surface.freeze_daytime = true -- TODO: For now, implement variable day/night later
  --surface.request_to_generate_chunks({0, 0}, 3) -- More?

  local tiles = {}
  local halfWidth = math.ceil(site.width / 2)
  local halfHeight = math.ceil(site.height / 2)
  local estimate = site.resource_estimate[1]
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
  surface.set_tiles(tiles)

  -- TODO: Randomise landing position
  local gate = surface.create_entity{name="medium-portal", position={x=0,y=0,force = game.forces[site.force]}}
  site.portal_entity = gate
  -- TODO: Create some crater marks on the ground

  site.arrival_position = {x = 0, y = 0} -- TODO: Position relative to Gate
  -- TODO: Make indestructible, unmineable etc?

  -- TODO: Update site data with real resource count

  site.surface = surface

  -- To make void chunks show up on the map, you need to tell them they've finished generating.
  local cx = 0
  local cy = 0
  surface.set_chunk_generated_status({cx-2, cy-2}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-1, cy-2}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+0, cy-2}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+1, cy-2}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-2, cy-1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-1, cy-1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+0, cy-1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+1, cy-1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-2, cy+0}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-1, cy+0}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+0, cy+0}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+1, cy+0}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-2, cy+1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx-1, cy+1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+0, cy+1}, defines.chunk_generated_status.entities)
  surface.set_chunk_generated_status({cx+1, cy+1}, defines.chunk_generated_status.entities)

end

script.on_event(defines.events.on_tick, function(event) 
  playersEnterPortals()
end)

function playersEnterPortals()
  local tick = game.tick
  for player_index, player in pairs(game.players) do
    if player.connected and not player.driving then -- and tick - (global.last_player_teleport[player_index] or 0) >= 45 then
      local walking_state = player.walking_state
      if walking_state.walking then
        if walking_state.direction == defines.direction.north
        or walking_state.direction == defines.direction.northeast
        or walking_state.direction == defines.direction.northwest then
          -- Enter portal
          local portal = findPortalInArea(player.surface, {{player.position.x-0.2, player.position.y-0.3},{player.position.x+0.2, player.position.y}})
          if portal ~= nil then
            enterPortal(player, portal)
          end
        end
      end
    end
  end
end

function enterPortal(player, portal)
  game.print("Entering portal...")
  if portal.teleport_target == nil then
    openPortalTargetSelectGUI(player, portal)
    return
  end
  -- TODO: Adjust energy buffer based on required energy for distance
  local energyRequired = requiredEnergyForTeleport(player, portal)
  if portal.entity.energy < energyRequired then
    game.print("Not enough energy, required " .. energyRequired / 1000000 .. "MJ, had " .. portal.entity.energy / 1000000 .. "MJ")
    -- TODO: Display a big charging progress bar (and animation?)
    return
  end
  game.print("Using " .. energyRequired / 1000000 .. "MJ")

  local site = portal.teleport_target
  if not site.surface_generated then
    generateSiteSurface(site)
  end

  player.teleport({site.arrival_position.x, site.arrival_position.y},site.surface)
  portal.entity.energy = portal.entity.energy - energyRequired
end

function requiredEnergyForTeleport(player, portal)

  -- Algorithm as follows:
  --   Base cost to initate a teleport
  --   Plus cost for player (adjust depending on inventory size? Items carried? In vehicle?)
  --   Multiplied by distance cost

  local BASE_COST = 1000000 -- 1MJ
  local PLAYER_COST = 50000 -- 2MJ
  local DISTANCE_MODIFIER = 100

  return BASE_COST + PLAYER_COST * DISTANCE_MODIFIER * portal.teleport_target.distance

end

-- Handle all item creation/destruction events
function onBuiltEntity(event)
end
function onMinedItem(event)
end
function onEntityDied(event)
end

script.on_event(defines.events.on_built_entity, onBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, onBuiltEntity)
script.on_event(defines.events.on_player_mined_item, onMinedItem)
--script.on_event(defines.events.on_preplayer_mined_item, onMinedItem)
script.on_event(defines.events.on_robot_mined, onMinedItem)
script.on_event(defines.events.on_entity_died, onEntityDied)
-- TODO: Check for the following to avoid teleporting witha deconstructed portal? Also remember to handle orbital payload contents
--script.on_event(defines.events.on_marked_for_deconstruction, function(event)
--script.on_event(defines.events.on_canceled_deconstruction, function(event)
