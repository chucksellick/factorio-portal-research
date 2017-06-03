--[[

  Portals!

  Some general ideas/todos:

  * Environmental conditions on asteroids.
    - Different day/night cycle
    - No wind but is there anything to affect?
    - No burners allowed in atmosphere. (Unless some crazy atmosphericc bubble constructed)
    - No clouds :(  (seems ok at night tho)
  * Camera system similar to trains / factorissimo
  * Space-based solar power
    - 
--]]

require("mod-gui")
require("silo-script")
require("lib/util")
require("lib/table")
local inspect = require("lib/inspect")

script.on_init(On_Init)

local site_sizes = {
  {
    name = "small",
    min_size = 20,
    max_size = 50
  },
  {
    name = "medium",
    min_size = 45,
    max_size = 125
  },
  {
    name = "large",
    min_size = 120,
    max_size = 250
  }
}

function On_Init()
  --generateEvents()

  if not global.entities then
    global.entities = {}
    global.portals = {}
    global.players = {}
    global.sites = {}
  end

  -- TODO: Most of this is dev migration stuff which can be removed after first release

  if global.forces_portal_data then
    for forceName, forceData in pairs(global.forces_portal_data) do
      for i, site in pairs(forceData.known_offworld_sites) do
        site.is_offworld = true
        global.sites[site.name] = site
      end
      -- TODO: Ensure home site is actually created for new game, might not be needed?
      if forceData.home_site ~= nil then
        forceData.home_site.force = nil
        global.sites[forceData.home_site.name] = forceData.home_site
      end
    end
    global.forces_portal_data = nil
  end

  if global.portals_by_entity then
    for i,portal in pairs(global.portals_by_entity) do
      if portal.entity and portal.entity.valid then
        portal.id = portal.entity.unit_number
        global.entities[portal.id] = portal
        global.portals[portal.id] = portal
        portal.site = getSiteForEntity(portal.entity)
      end
    end
    global.portals_by_entity = nil
  end

  -- XXX: Up to here

  for i,site in pairs(global.sites) do
    verifySiteData(site, i)
  end
  remote.call("silo_script", "add_tracked_item", "portal-lander")
  remote.call("silo_script", "update_gui")
end

script.on_event(defines.events.on_force_created, function(event)
  On_Init()
  newForceData(event.force.name)
end)

script.on_configuration_changed(On_Init)

function getPlayerData(player)
  if not global.players[player.name] then
    global.players[player.name] = {
    }
  end
  return global.players[player.name]
end

function verifySiteData(site)
  if site.portals == nil then
    site.portals = {}
    for i,portal in pairs(global.portals) do
      if portal.site == site then
        site.portals[portal.id] = portal
      end
    end
  end
end

function newSiteDataForSurface(surface, force)
  local site = {
    name = surface.name,
    force = force,
    surface_generated = true,
    surface = surface,
    distance = 0,
    portals = {},
    is_offworld = false
  }
  global.sites[site.name] = site
  return site
end

function getEntityData(entity)
  if global.entities[entity.unit_number] == nil then
    local data = createEntityData(entity)
    if data ~= nil then
      global.entities[data.id] = data

      if entity.name == "medium-portal" then
        global.portals[data.id] = data
      end
    end
  end
  return global.entities[entity.unit_number]
end

function createEntityData(entity)
  if entity.name == "medium-portal" then
    local data = {
      id = entity.unit_number,
      teleport_target = nil,
      entity = entity,
      site = getSiteForEntity(entity)
    }
    if data.site == nil then
      data.site = newSiteDataForSurface(entity.surface)
    end
    data.site.portals[data.id] = data
    return data
  end
  return nil
end

function deleteEntityData(entity)
  local currentData = global.entities[entity.id]
  if currentData == nil then return end
  global.entities[entity.id] = nil

  if global.portals[entity.id] ~= nil then
    global.portals[entity.id] = nil
    -- Clean up any references to the entity from elsewhere
    if currentData.teleport_target ~= nil then
      currentData.teleport_target.teleport_target = nil
      currentData.site.portals[entity.id] = nil
    end
  end
end

-- Maintain database on all creation/destruction events
function onBuiltEntity(event)
  getEntityData(event.created_entity)
end

function onMinedItem(event)
  -- Don't know exactly which item, check all entities are still valid
  -- TODO: Double check it's actually onen of ours
  --if event.item_stack.name == "medium-portal" then
  for i,entity in pairs(global.entities) do
    if not entity.entity.valid then
      deleteEntityData(entity)
    end
  end
end

function onEntityDied(event)
  -- NOTE: Leaving as a separate event, even though it's currently the same there
  -- might be differences later on, e.g. the capsule packer
  onMinedItem(event)
end

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, onBuiltEntity)
script.on_event({defines.events.on_player_mined_item, defines.events.on_robot_mined}, onMinedItem)
script.on_event(defines.events.on_entity_died, onEntityDied)

--script.on_event(defines.events.on_preplayer_mined_item, onMinedItem)
-- TODO: Check for the following to avoid teleporting witha deconstructed portal? Also remember to handle orbital payload contents
--script.on_event(defines.events.on_marked_for_deconstruction, function(event)
--script.on_event(defines.events.on_canceled_deconstruction, function(event)

function findPortalInArea(surface, area)
  local candidates = surface.find_entities_filtered{area=area, name="medium-portal"}
  for _,entity in pairs(candidates) do
    return getEntityData(entity)
  end
  return nil
end

function getSiteForEntity(entity)
  local site = global.sites[entity.surface.name]
  return site
end

function randomOffworldSite(force)
  local site = {
    size = math.random(3),
    name = "",
    resource_estimate = {},
    force = force.name,
    surface_generated = false,
    -- TODO: Logarithmic scale, increases with research, more resources found farther afield
    distance = 1 + math.random(),
    portals = {},
    is_offworld = true
  }

  -- Simple random asteroid name generator "ABC-1234"
  -- TODO: Check no duplicate names
  for i = 1, 3 do
    site.name = site.name .. Util.charset[26 + math.random(24)]
  end
  site.name = site.name .. "-"
  for i = 1, 4 do
    site.name = site.name .. Util.charset[52 + math.random(10)]
  end

  -- Store in global table
  global.sites[site.name] = site
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
  --TODO: Check player actually has any data to display.
  --if #global.forces_portal_data[player.force.name].known_offworld_sites == 0 then return end

  local button_flow = mod_gui.get_button_flow(player)
  if button_flow["portal-research-gui-button"] then
    button_flow["portal-research-gui-button"].destroy()
  end
  local button = button_flow.add {
    --type = "sprite-button",
    type="button",
    name = "portal-research-gui-button",
    --sprite = "item/rocket-silo",
    style = mod_gui.button_style,
    caption = {"gui-portal-research.portals-button-caption"},
    tooltip = {"gui-portal-research.portals-button-tooltip"}
  }
  createEmergencyHomeButton(player)
end

function createEmergencyHomeButton(player)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow["portal-research-emergency-home-button"] then
    button_flow["portal-research-emergency-home-button"].destroy()
  end
  local button = button_flow.add {
    --type = "sprite-button",
    type="button",
    name = "portal-research-emergency-home-button",
    --sprite = "item/rocket-silo",
    style = mod_gui.button_style,
    caption = {"gui-portal-research.emergency-home-button-caption"},
    tooltip = {"gui-portal-research.emergency-home-button-tooltip"}
  }
  button.style.visible = false
end

function showEmergencyHomeButton(player)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow["portal-research-emergency-home-button"] == nil then
    createEmergencyHomeButton(player)
  end
  button_flow["portal-research-emergency-home-button"].style.visible = true
end

function hideEmergencyHomeButton(player)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow["portal-research-emergency-home-button"] then
    button_flow["portal-research-emergency-home-button"].style.visible = false
  end
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

function openPortalTargetSelectGUI(player, portal)
  if player.gui.center["portal-target-select"] then
    return
  end

  local playerData = getPlayerData(player)

  playerData.guiPortalTargetButtons = {}
  playerData.guiPortalCurrent = portal

  local dialogFrame = player.gui.center.add{
    type="frame",
    name="portal-target-select",
    caption={"gui-portal-research.portal-target-select-caption"}
  }
  local targetsFlow = dialogFrame.add{type="flow", direction="vertical"}
  -- List sites that don't yet have a portal
  for i,site in pairs(global.sites) do
    if not site.surface_generated and site.force == player.force.name then
      local newButton = targetsFlow.add{
        type="button",
        name="portal-target-select-" .. site.name,
        caption=site.name
      }
      playerData.guiPortalTargetButtons[newButton.name] = {site=site}
    end
  end
  -- List portals that don't have a target
  for i,target in pairs(global.portals) do
    if target.entity.force == player.force and portal ~= target and target.teleport_target == nil then
      local buttonId = "portal-target-select-" .. target.entity.unit_number
      local newButton = targetsFlow.add{
        type="button",
        name=buttonId,
        caption=target.site.name
      }
      playerData.guiPortalTargetButtons[newButton.name] = {portal=target}
    end
  end
  targetsFlow.add{type="button", name="cancel-portal-target-select", caption={"cancel-dialog-caption"}}
end

function closePortalTargetSelectGUI(player)
  local playerData = getPlayerData(player)

  playerData.guiPortalTargetButtons = nil
  playerData.guiPortalCurrent = nil
  if player.gui.center["portal-target-select"] then
    player.gui.center["portal-target-select"].destroy()
  end
end

function onGuiClick(event)
  local player = game.players[event.element.player_index]
  local playerData = getPlayerData(player)
  local name = event.element.name
  if name == "portal-research-gui-button" then
    -- TODO: Show us your GUI
  end
  if name == "portal-research-emergency-home-button" then
    -- TODO: Implement!!
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
    -- TODO: If another player had GUI open for the same portal, should probably close it.
    local chosen = playerData.guiPortalTargetButtons[name]
    if chosen.site ~= nil then
      -- Generate the site now to establish a link to the portal entity
      chosen.portal = generateSiteSurface(chosen.site)
    end

    playerData.guiPortalCurrent.teleport_target = chosen.portal
    chosen.portal.teleport_target = playerData.guiPortalCurrent
    closePortalTargetSelectGUI(player)
    return
  end
end
script.on_event(defines.events.on_gui_click, onGuiClick)

-- Creates the actual game surface
function generateSiteSurface(site)

  local sizeSpec = site_sizes[site.size]
  site.width = math.random(sizeSpec.max_size - sizeSpec.min_size) + sizeSpec.min_size
  site.height = math.random(sizeSpec.max_size - sizeSpec.min_size) + sizeSpec.min_size

  -- TODO: Use a similar thing from Factorissimo where surfaces are reused with asteroids very far apart.
  -- However this would preclude the possibility of space platform building :(

  local surface = game.create_surface("Asteroid " .. site.name, {width=2,height=2})--mapgen)
  surface.daytime = 0.4 -- Make things dark even tho really not sure how realistic that is ;)
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
  local gate = surface.create_entity{name="medium-portal", position={x=0,y=0}, force = game.forces[site.force]}
  -- Ensure the entity has data, onCreated event (probably) doesn't fire when placing entities like this
  -- TODO: Check the above!
  local newPortal = getEntityData(gate)

  -- TODO: Create some crater marks and a little fire on the ground

  site.arrival_position = {x = 0, y = 0} -- TODO: Position relative to Gate

  -- Set up some power
  -- TODO: If this is desired, set up specialist entities. Lander could also come be created pre-charged.

  --local panel = surface.create_entity{name="solar-panel", position={x=-3,y=0},force = game.forces[site.force]}
  --local pole = surface.create_entity{name="medium-electric-pole", position={x=0,y=-2},force = game.forces[site.force]}
  --pole.connect_neighbour(gate)
  --pole.connect_neighbour(panel)

  -- TODO: Make it all indestructible, unmineable etc?

  -- TODO: Update site data with real resource count

  site.surface = surface
  site.surface_generated = true
  -- To make void chunks show up on the map, you need to tell them they've finished generating.
  for cx = -2,1 do
    for cy = -2,1 do
      surface.set_chunk_generated_status({cx, cy}, defines.chunk_generated_status.entities)
    end
  end

  -- Updates the sites_by_surface table
  -- TODO: Not really happy with this, if these kind of calls are getting silly then need some
  -- system for central entity/force/player/data management.
  verifySiteData(site)

  return newPortal
end

script.on_event(defines.events.on_tick, function(event) 
  playersEnterPortals()
end)

function playersEnterPortals()
  local tick = game.tick
  for player_index, player in pairs(game.players) do
    -- TODO: Allow driving into BIG portals? Or medium ones anyway (big only for )
    if player.connected and not player.driving then -- and tick - (global.last_player_teleport[player_index] or 0) >= 45 then
      local walking_state = player.walking_state
      if walking_state.walking
        and walking_state.direction ~= defines.direction.east
        and walking_state.direction ~= defines.direction.west then

          -- Look for a portal nearby
          local portal = findPortalInArea(player.surface, {
            {player.position.x-0.3, player.position.y-0.3},
            {player.position.x+0.3, player.position.y+0.3}
          })

          -- Check we are in the center bit of the portal and walking in the appropriate direction
          -- TODO: Allow portal rotation and support east/west portal entry
          if portal ~= nil then
            local direction = defines.direction.north
            if walking_state.direction == defines.direction.southwest
            or walking_state.direction == defines.direction.south
            or walking_state.direction == defines.direction.southeast then
              direction = defines.direction.south
            end

            if (direction == defines.direction.north
              and player.position.y > portal.entity.position.y
              and player.position.y < portal.entity.position.y + 0.5)
              or (walking_state.direction == defines.direction.south
              and player.position.y < portal.entity.position.y
              and player.position.y > portal.entity.position.y - 0.5) then
              -- Teleport
              enterPortal(player, portal, direction)
            end
          end
      end
    end
  end
end

function enterPortal(player, portal, direction)
  if portal.teleport_target == nil then
    openPortalTargetSelectGUI(player, portal)
    return
  end
  -- TODO: Adjust energy buffer based on required energy for distance
  local energyRequired = requiredEnergyForTeleport(player, portal)
  local energyAvailable = portal.entity.energy + portal.teleport_target.entity.energy

  if energyAvailable < energyRequired then
    player.print("Not enough energy, required " .. energyRequired / 1000000 .. "MJ, had " .. energyAvailable / 1000000 .. "MJ")
    -- TODO: Display a big charging bar (and animate the portal attempting to open / charging?)
    return
  end
  player.print("Teleporting using " .. energyRequired / 1000000 .. "MJ")

  -- When travelling offworld, setup the emergency teleport back to where we left
  local currentSite = getSiteForEntity(player)
  if currentSite == nil or not currentSite.is_offworld then
    local playerData = getPlayerData(player)
    playerData.emergency_home_portal = portal
    playerData.emergency_home_position = portal.entity.position
    showEmergencyHomeButton(player)
  else
    hideEmergencyHomeButton(player)
  end

  -- TODO: Freeze player and show teleport anim/sound for a second
  local targetPos = {
    -- x is the same relative to both portals
    x = portal.teleport_target.entity.position.x + player.position.x - portal.entity.position.x,
    y = portal.teleport_target.entity.position.y
  }
  if direction == defines.direction.north then
    targetPos.y = targetPos.y - 0.5
  else
    targetPos.y = targetPos.y + 0.5
  end
  player.teleport(targetPos, portal.teleport_target.site.surface)

  -- TODO: emergency teleport, entity could be invalid, will be a completely different path
  -- tho as no energy check, destroy entities, etc.

  -- Sap energy from both ends of the portal, local end first
  local missingEnergy = math.max(0, energyRequired - portal.entity.energy)
  portal.entity.energy = portal.entity.energy - energyRequired
  portal.teleport_target.entity.energy = portal.teleport_target.entity.energy - missingEnergy
end

function requiredEnergyForTeleport(player, portal)

  -- Algorithm as follows:
  --   Base cost to initate a teleport
  --   Plus cost for player (adjust depending on inventory size? Items carried? In vehicle?)
  --   Multiplied by distance cost

  local BASE_COST = 1000000 -- 1MJ
  local PLAYER_COST = 50000 -- 2MJ
  local DISTANCE_MODIFIER = 100

  return BASE_COST + PLAYER_COST * DISTANCE_MODIFIER
    * math.abs(portal.teleport_target.site.distance - portal.site.distance)

end

-- Handle objects launched in rockets
function onRocketLaunched(event)
  if event.rocket.get_item_count("portal-lander") == 0 then return end
  local force = event.rocket.force
  -- TODO: Optionally generate more than one
  local newSite = randomOffworldSite(force)
  force.print({"site-discovered", newSite.name})

  -- TODO: Move this dialog to the sidebar, open on button click (optionally?)
  for i, player in pairs(force.connected_players) do
    initGUI(player)
    showSiteDetailsGUI(player, newSite)
  end

  -- TODO: Populate some silo output science packs
end

script.on_event(defines.events.on_rocket_launched, onRocketLaunched)
