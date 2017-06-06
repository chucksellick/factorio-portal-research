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
    - Degradation over time due to micrometeors, solar flares, general weathering
    - Send up repair drones

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

  -- Fix site data
  for i,site in pairs(global.sites) do
    verifySiteData(site, i)
    if not site.surface_name then
      if site.surface.name ~= site.name then
        site.is_offworld = true
        site.surface_name = site.surface.name
        global.sites[site.surface_name] = site
        global.sites[site.name] = nil
        game.print(site.name .. " " .. site.surface_name)
      elseif site.name == "nauvis" or site.name == "Nauvis" then
        site.surface_name = site.name
        game.print(site.name)
      else
        game.print(site.name)
        global.sites[i] = nil
      end
    end
  end

  for i,entity in pairs(global.entities) do
    if entity.fake_power_consumer then
      entity.fake_energy = entity.fake_power_consumer
    end
    updatePortalEnergyProperties(entity)
    entity.site = global.sites[entity.entity.surface.name]
  end

  -- XXX: Up to here

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
    surface_name = surface.name,
    force = force,
    surface_generated = true,
    surface = surface,
    distance = 0,
    portals = {},
    is_offworld = false
  }
  global.sites[surface.name] = site
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

      if entity.name == "portal-chest" then
        global.portals[data.id] = data
        -- TODO: create virtual power consumer, register tick to transfer items
      end

      if entity.name == "portal-belt" then
        -- TODO: Register a tick to utlise power, generate effects, transfer items
      end
    end
  end
  return global.entities[entity.unit_number]
end

-- TODO: This is more of a entire "initializeEntity" now it also ends up creating power entities
function createEntityData(entity)
  if entity.name == "medium-portal" or entity.name == "portal-chest" then
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
    ensureEnergyInterface(data)
    updatePortalEnergyProperties(data)
    return data
  end
  return nil
end

function ensureEnergyInterface(entityData)
  if entityData.fake_energy ~= nil then
    return entityData.fake_energy
  end

  if entityData.entity.name == "portal-belt" or
    entityData.entity.name == "portal-chest" then

    local consumer = entityData.entity.surface.create_entity {
      name=entityData.entity.name .. "-power",
      position={entityData.entity.position.x-0.5, entityData.entity.position.y-0.5},
      force=entityData.entity.force
    }
    entityData.fake_energy = consumer
  end
  return entityData.fake_energy or entityData.entity
end

function deleteEntityData(entityData)
  global.entities[entityData.id] = nil
    -- Clean up power
  if entityData.fake_energy then
    entityData.fake_energy.destroy()
    entityData.fake_energy = nil
  end
  if global.portals[entityData.id] ~= nil then
    global.portals[entityData.id] = nil
    entityData.site.portals[entityData.id] = nil
    -- Clean up any references to the entity from elsewhere
    if entityData.teleport_target ~= nil then
      entityData.teleport_target.teleport_target = nil
      -- Buffer will empty on the other side
      -- TODO: Is it really necessary? Could hold the power until another target is selected
      updatePortalEnergyProperties(entityData.teleport_target)
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
  local data = getEntityData(event.entity)
  if data ~= nil then
    deleteEntityData(data)
  end
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
    -- TODO: This directly translates to a light level but the exact curve is not clear. 0 is full daylight, 0.5 is midnight ... in between there is a curve.
    -- Solar panels still give 100% at 0.25 but start losing power at 0.3 and have lost most at 0.4.
    daytime = math.random(),
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

  local guiContainer = (portal.entity.name == "portal-chest" and mod_gui.get_frame_flow(player) or player.gui.center)

  -- TODO: Prevent this being called when already open. Close GUI when running away from portal.
  -- Open GUI for a different portal.
  -- Note: intentionally not the other guiContainer, until portal UIs are fixed
  if player.gui.center["portal-target-select"] then
    return
  end

  local playerData = getPlayerData(player)

  -- Player opened a different chest quickly
  if playerData.guiPortalCurrent then
    closePortalTargetSelectGUI(player)
  end

  playerData.guiPortalTargetButtons = {}
  playerData.guiPortalCurrent = portal

  local dialogFrame = guiContainer.add{
    type="frame",
    name="portal-target-select",
    caption={"gui-portal-research.portal-target-select-caption." .. portal.entity.name}
  }
  local targetsFlow = dialogFrame.add{type="flow", direction="vertical"}
  -- TODO: List resources on both types of button
  -- List sites that don't yet have a portal
  local allowLongRange = player.force.technologies["interplanetary-teleportation"]
    and player.force.technologies["interplanetary-teleportation"].researched

  -- TODO: It shouldn't be possible to have sites before long-range research ... maybe
  -- don't need this conditional ;)
  -- TODO: However, for box portals do check they're close enough on the surface until interplanetary is unlocked
  -- TODO: Maybe shorter distances initially, go to 50 on long-range, go to infinite on interplanetary
  if portal.entity.name == "medium-portal" and allowLongRange then  
    for i,site in pairs(global.sites) do
      if not site.surface_generated and site.force == player.force.name then
        local newButton = targetsFlow.add{
          type="button",
          name="portal-target-select-" .. site.name,
          caption={"site-name", site.name}
        }
        playerData.guiPortalTargetButtons[newButton.name] = {site=site}
      end
    end
  end
  -- List portals (of the same type) that don't have a target
  for i,target in pairs(global.portals) do
    if portal.entity.name == target.entity.name and target.entity.force == player.force and portal ~= target and target.teleport_target == nil
      -- Note: It seems like long range shouldn't happen before lander is created,
      -- however we're also checking for different surfaces e.g. those created by Factorissimo
      and (allowLongRange or target.entity.surface == portal.entity.surface) then
      local buttonId = "portal-target-select-" .. target.entity.unit_number
      local newButton = targetsFlow.add{
        type="button",
        name=buttonId,
        caption=target.site.name -- And an additional identifier :(
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

  local frameFlow = mod_gui.get_frame_flow(player)
  if frameFlow["portal-target-select"] then
    frameFlow["portal-target-select"].destroy()
  end
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
    local portal = playerData.emergency_home_portal
    player.teleport(playerData.emergency_home_position, portal.entity.surface)
    -- Note: Simply setting the health to 0 doesn't seem to ever actually destroy the object.
    --       Could also use die() ... but that wouldn't attribute the kill to anyone!
    portal.entity.damage(portal.entity.health, player.force)
    -- TODO: Stage this a bit so we see it blow up before the player teleports in
    -- TODO: And display warning and require confirmationn
    playerData.emergency_home_portal = nil
    playerData.emergency_home_position = nil
    hideEmergencyHomeButton(player)
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

    -- TODO: Allow this to be toggled in GUI (and even using circuits?) and leave GUI open...
    -- TODO: Allow naming things (soon). Open portal GUI on mouse hover.
    -- TODO: (Much later) GUI can show connections diagrammatically
    if chosen.portal.entity.name == "portal-chest" then
      chosen.portal.is_sender = false
      chosen.portal.teleport_target.is_sender = true      
    end

    -- Buffer size will need to change
    updatePortalEnergyProperties(chosen.portal)
    updatePortalEnergyProperties(chosen.portal.teleport_target)

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

  local surface = game.create_surface(site.surface_name, {width=2,height=2})--mapgen)
  surface.daytime = site.daytime or 0
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

script.on_event(defines.events.on_tick, function(event) 
  playersEnterPortals()
  chestsMoveStacks(event)
end)

function playersEnterPortals()
  local tick = game.tick
  for player_index, player in pairs(game.players) do
    -- TODO: Allow driving into BIG portals? Or medium ones anyway (big only for trains...)
    -- TODO: Balance ticks...
    -- Open chest GUI when player has chest open
    local playerData = getPlayerData(player)
    -- TODO: Chest stuff really in the right function here...
    if not player.opened and playerData.guiPortalCurrent and playerData.guiPortalCurrent.entity.name == "portal-chest" then
      closePortalTargetSelectGUI(player, chestData)
    end
    if player.opened and player.opened.name == "portal-chest" then
      local chestData = getEntityData(player.opened)
      if chestData.teleport_target == nil and playerData.guiPortalCurrent ~= chestData then
        -- TODO: However, periodically refresh the list in case chests are being built elsewherre
        openPortalTargetSelectGUI(player, chestData)
      end
    end
    if player.connected and not player.driving then
    -- and tick - (global.last_player_teleport[player_index] or 0) >= 45 then
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
              and player.position.y < portal.entity.position.y + 1)
              or (walking_state.direction == defines.direction.south
              and player.position.y < portal.entity.position.y
              and player.position.y > portal.entity.position.y - 1) then
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
  -- Check enough energy is available
  local energyRequired = energyRequiredForPlayerTeleport(portal)
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
    -- x is the same relative to both portals, y is inverted
    x = portal.teleport_target.entity.position.x + player.position.x - portal.entity.position.x,
    y = portal.teleport_target.entity.position.y - player.position.y + portal.entity.position.y
  }
  player.teleport(targetPos, portal.teleport_target.site.surface)

  -- TODO: emergency teleport, entity could be invalid, will be a completely different path
  -- tho as no energy check, destroy entities, etc.

  -- Sap energy from both ends of the portal, local end first
  local missingEnergy = math.max(0, energyRequired - portal.entity.energy)
  portal.entity.energy = portal.entity.energy - energyRequired
  portal.teleport_target.entity.energy = portal.teleport_target.entity.energy - missingEnergy
end

function energyRequiredForPlayerTeleport(portal, player)
  -- TODO: Adjust on player inventory size
  return maxEnergyRequiredForPlayerTeleport(portal)
end

function groundDistanceOfTeleport(portal)
  if portal.site ~= portal.teleport_target.site then
    return 0
  else
    return math.sqrt((portal.teleport_target.entity.position.x - portal.entity.position.x) ^ 2
      + (portal.teleport_target.entity.position.y - portal.entity.position.y)^2)
  end
end
function spaceDistanceOfTeleport(portal)
  if portal.site == portal.teleport_target.site then
    return 0
  else
    return math.abs(portal.teleport_target.site.distance - portal.site.distance)
  end
end
-- TODO: Bring cost down on research levels for force
local BASE_COST = 1000000 -- 1MJ
local PLAYER_COST = 25000000
local GROUND_DISTANCE_MODIFIER = 0.1
local DISTANCE_MODIFIER = 100
local STACK_COST = 50000

function maxEnergyRequiredForPlayerTeleport(portal)

  -- Algorithm as follows:
  --   Base cost to initate a teleport
  --   Plus cost for player (adjust depending on inventory size? Items carried? In vehicle?)
  --   Multiplied by distance cost

  if not portal.teleport_target then
    return 0
  end
  return BASE_COST + PLAYER_COST * (
    DISTANCE_MODIFIER * spaceDistanceOfTeleport(portal)
    + GROUND_DISTANCE_MODIFIER * groundDistanceOfTeleport(portal))

end

function energyRequiredForStackTeleport(portal, stack)
   -- TODO: Adjust on stack size
   return maxEnergyRequiredForStackTeleport(portal)
end

function maxEnergyRequiredForStackTeleport(portal)

  -- Algorithm as follows:
  --   Base cost to initate a teleport
  --   Plus cost for player (adjust depending on inventory size? Items carried? In vehicle?)
  --   Multiplied by distance cost

  -- TODO: Bring cost down on research levels for force
  -- TODO: Reduce cost for partial stacks

  if not portal.teleport_target then
    return 0
  end
  return BASE_COST + STACK_COST * (DISTANCE_MODIFIER * spaceDistanceOfTeleport(portal)
                                  + GROUND_DISTANCE_MODIFIER * groundDistanceOfTeleport(portal))
end

function updatePortalEnergyProperties(portal)

  local entity = portal.entity
  local requiredEnergy = 0
  if entity.name == "medium-portal" and portal.teleport_target then
    requiredEnergy = maxEnergyRequiredForPlayerTeleport(portal)
  end
  if entity.name == "portal-chest" and portal.teleport_target then
    requiredEnergy = maxEnergyRequiredForStackTeleport(portal)
  end

  -- Buffer can store enough for 2 teleports only!
  local interface = ensureEnergyInterface(portal)
  interface.electric_buffer_size = 2 * requiredEnergy
  interface.electric_input_flow_limit = interface.prototype.electric_energy_source_prototype.input_flow_limit
  interface.electric_output_flow_limit = interface.prototype.electric_energy_source_prototype.output_flow_limit
  interface.electric_drain = interface.prototype.electric_energy_source_prototype.drain
  --TODO: This caused a super strange error but I don't know if drain is the same energy_usage value from the actual prototype...
  --interface.power_usage = interface.prototype.energy_usage

end

function chestsMoveStacks(event)
  -- Chests teleport every second (for now)
  -- TODO: Tweak this value and maybe add some research to make it quicker.
  local checkFrequency = 60
  -- TODO: Optimisation. Move into a list we can traverse quickly.
  local tick = event.tick % checkFrequency
  local n = 0
  for i,portal in pairs(global.portals) do
    if portal.entity.name == "portal-chest" then
      n = n + 1
      if portal.is_sender and portal.teleport_target and n % checkFrequency == tick then
        teleportChestStacks(portal, 1)
      end
    end
  end
end

function teleportChestStacks(source, num)

  -- TODO: Check if energy is available (and use it)
  local target = source.teleport_target
  
  ensureEnergyInterface(source)
  ensureEnergyInterface(target)

  -- Move from stack to stack teleporting, but do skip empty stacks
  local nextStack = source.next_stack or 1
  local startStack = nextStack
  local abort = false
  local teleported = 0
  local inventory = source.entity.get_inventory(defines.inventory.chest)
  
  -- Null operation
  if inventory.is_empty() then return end
  
  local targetInventory = source.teleport_target.entity.get_inventory(defines.inventory.chest)

  -- TODO: Could check hasbar() to avoid looping stacks that are always empty / should not be teleported?

  while teleported < num and not abort do
    local stack = inventory[nextStack]
    if stack.valid_for_read then
      if stack.count > 0 then
        -- Check if the stack can be moved
        if targetInventory.can_insert(stack) then
          -- First check we have enough energy
          -- TODO: For chests/belts, use energy on *both* sides of the portal.
          -- In fact do this for players too normally but allow power to balance from the other side.
          -- Purely for gameplay convenience, not realism!
          local energyRequired = energyRequiredForStackTeleport(source, stack)
          local interface = ensureEnergyInterface(source)
          if (interface and interface.energy >= energyRequired) then
            interface.energy = interface.energy - energyRequired
            local moved = targetInventory.insert(stack)
            if moved == stack.count then
              stack.clear()
            else
              stack.count = stack.count - moved
            end
            -- One has been moved!
            teleported = teleported + 1
          else
            -- TODO: Locale
            -- game.print(inspect(source.site))
            --source.entity.force.print("Not enough power in chest on " .. source.site.surface_name)
            --source.entity.force.print("Required " .. energyRequired .. " available " .. source.fake_energy.energy)
            abort = true
          end
          -- TODO: Trigger not enough power warning on map?
        end
      end
    end

    nextStack = nextStack + 1
    nextStack = (nextStack-1) % #inventory + 1
    -- Abort if gone full circle
    if nextStack == startStack then
      abort=true
    end
  end

  -- Remember stack for next tick
  source.next_stack = nextStack

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

  -- TODO: Populate some silo output science packs?
end

script.on_event(defines.events.on_rocket_launched, onRocketLaunched)

-- Handle technology upgrades
function onResearchFinished(event)
  -- TODO: On long-range teleportation, could upgrade portal belts to a different type?
  -- Could have a series of research upgrades leading to interplanetary. Or nah ... just get straight there ;)
  -- TODO: On large-mass teleportation, start teleporting all stacks not just 1 at a time.  
end

script.on_event(defines.events.on_research_finished, onResearchFinished)
