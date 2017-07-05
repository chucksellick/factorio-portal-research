--[[

  Portals! And Space.

  By Doc

--]]

require("mod-gui")
require("silo-script")
require("lib.util")
require("lib.table")
local inspect = require("lib.inspect")

-- TODO: Intentionally global now to avoid cross-references between modules causing
-- recursion. Could try the package.loaded[...] solution from:
-- https://stackoverflow.com/questions/8248698/recommended-way-to-have-2-modules-recursively-refer-to-each-other-in-lua-5-2
Ticks = require("modules.ticks")
Gui = require("modules.gui")
Player = require("modules.player")
Portals = require("modules.portals")
Sites = require("modules.sites")
Orbitals = require("modules.orbitals")
Scanners = require("modules.scanners")
Power = require("modules.power")
Radio = require("modules.radio")

remote.add_interface("portal_research", {
  add_offworld_resource = Sites.addOffworldResource,
  remove_offworld_resource = Sites.removeOffworldResource,
  clear_offworld_resources = Sites.clearOffworldResources
})

function On_Init()
  if not global.entities then
    global.entities = {}
    global.portals = {}
    global.players = {}
    global.sites = {}
    global.forces = {}
    global.orbitals = {}
    global.next_orbital_id =  1
    global.equipment = {}
    global.next_equipment_id = 1
    global.scanners = {}
    global.transmitters = {}
    global.receivers = {}
    global.harvesters = {}
    global.landers = {}
  end

  for i,entity in pairs(global.entities) do
    if entity.entity.name == "portal-chest" or 
      entity.entity.name == "portal-belt" or
      entity.entity.name == "medium-portal" then
      Portals.updateEnergyProperties(entity)
    end
  end

  Power.updateMicrowaveTargets()

  for i,player in pairs(game.players) do
    Gui.initForPlayer(player)
  end

  -- Let the silo track all our custom orbitals
  remote.call("silo_script", "add_tracked_item", "portal-lander")
  remote.call("silo_script", "add_tracked_item", "solar-harvester")
  remote.call("silo_script", "add_tracked_item", "space-telescope")
  remote.call("silo_script", "update_gui")

  Ticks.init()
  Orbitals.init()
end

script.on_init(On_Init)

script.on_event(defines.events.on_force_created, function(event)
  On_Init()
  getForceData(event.force)
end)

script.on_configuration_changed(On_Init)

function getPlayerData(player)
  -- Might already be a playerData
  if player.index == nil then return player end
  if not global.players[player.name] then
    global.players[player.name] = {
      player = player
    }
  end
  return global.players[player.name]
end

function getForceData(force)
  if not global.forces[force.name] then
    global.forces[force.name] = {
      force = force,
      site_distance_multiplier = 1
    }
    updateForceData(force)
    Radio.initForce(global.forces[force.name])
  end
  return global.forces[force.name]
end

function updateForceData(force)
  local data = getForceData(force)
  -- TODO: Various technology research will increase distance multiplier, as will
  -- the number of telescopes you have
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

entity_types = {
  ['medium-portal'] = {},
  ['portal-chest'] = {},
  ['portal-belt'] = {},
  ['microwave-transmitter'] = {},
  ['microwave-antenna'] = {},
  ['observatory'] = {},
  ['radio-mast'] = {},
  ['radio-mast-transmitter'] = {}, -- Can never be placed, but can be destroyed
  ['orbital-logistics-combinator'] = {}
}

-- TODO: This is more of a entire "initializeEntity" now it also ends up creating power entities
function createEntityData(entity)
  if not entity_types[entity.name] then return end

  local data = {
    id = entity.unit_number,
    entity = entity,
    force = entity.force,
    site = Sites.getSiteForEntity(entity),
    created_at = game.tick
  }
  if entity.name == "medium-portal"
    or entity.name == "portal-chest"
    or entity.name == "portal-belt" then

    data.teleport_target = nil
    data.site.portals[data.id] = data
    ensureEnergyInterface(data)
    Portals.updateEnergyProperties(data)
    -- Update other end of connected underground belt
    -- TODO: When insert a new belt between two other belts, this is fine for the new neighbour,
    -- however the other now-orphaned end will still be buffering power...
    if entity.name == "portal-belt" and entity.neighbours ~= nil then    
      Portals.updateEnergyProperties(getEntityData(entity.neighbours))
    end
  end
  if entity.name == "observatory" then
    local data = {
      id = entity.unit_number,
      entity = entity,
      site = Sites.getSiteForEntity(entity),
      scan_strength = 1
    }
    global.scanners[data.id] = data
  end
  if entity.name == "microwave-transmitter" then
    data.target_antennas = {}
    global.transmitters[data.id] = data
    Power.updateMicrowaveTargets()
  end
  if entity.name == "microwave-antenna" then
    -- Deactivate to stop generating power until it finds a transmitter
    entity.active = false
    data.source_transmitters = {}
    global.receivers[data.id] = data
    Power.updateMicrowaveTargets()
  end
  if entity.name == "radio-mast" then
    Radio.initializeMast(data)
    ensureEnergyInterface(data)
  end
  if entity.name == "orbital-logistics-combinator" then
    Radio.initializeLogisticsCombinator(data)
    ensureEnergyInterface(data)
  end
  return data
end

function ensureEnergyInterface(entityData)
  if entityData.fake_energy ~= nil then
    return entityData.fake_energy
  end

  if entityData.entity.name == "portal-belt" or
    entityData.entity.name == "portal-chest" then --or
    --entityData.entity.name == "radio-mast" or
    --entityData.entity.name == "orbital-logistics-combinator" then

    local consumer = entityData.entity.surface.create_entity {
      name=entityData.entity.name .. "-power",
      position={entityData.entity.position.x,entityData.entity.position.y-0.2},
      force=entityData.entity.force
    }
    entityData.fake_energy = consumer
  end
  return entityData.fake_energy or entityData.entity
end

function deleteEntityData(entityData)
  entityData.deleted = true
  global.entities[entityData.id] = nil
  -- Clean up power
  if entityData.fake_energy then
    entityData.fake_energy.destroy()
    entityData.fake_energy = nil
  end
  -- Clean up registered ticks
  if entityData.next_update_tick then
    Ticks.cancel(entityData.next_update_tick)
  end
  if global.portals[entityData.id] ~= nil then
    global.portals[entityData.id] = nil
    entityData.site.portals[entityData.id] = nil
    -- Clean up any references to the entity from elsewhere
    if entityData.teleport_target ~= nil then
      entityData.teleport_target.teleport_target = nil
      -- Buffer will empty on the other side
      -- TODO: Is that really necessary? Could store the power until another target is selected
      Portals.updateEnergyProperties(entityData.teleport_target)
    end
  end
  if global.scanners[entityData.id] ~= nil then
    global.scanners[entityData.id] = nil
  end
  if global.transmitters[entityData.id] ~= nil then
    -- Note: Update targets *before* moving the transmitter, otherwise it's not there
    -- to detect it's been deleted!
    Power.updateMicrowaveTargets()
    global.transmitters[entityData.id] = nil
  end
   if global.receivers[entityData.id] ~= nil then
    global.receivers[entityData.id] = nil
    -- Receivers update *after* removing so they don't get populated into target_antennas
    Power.updateMicrowaveTargets()

    -- TODO: As commented in Power.updateMicrowaveTargets, this is all screwy and quite fragile, needs some improvement
  end
end

-- Maintain database on all creation/destruction events
function onBuiltEntity(event)
  getEntityData(event.created_entity)
end

function onDestroyEntity(event)
  if entity_types[event.entity.name] then
    local data = getEntityData(event.entity)
    if data ~= nil then
      deleteEntityData(data)
    end
  end
end

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, onBuiltEntity)
script.on_event({defines.events.on_entity_died, defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, onDestroyEntity)

-- TODO: For any tile entities will need to register different events

--script.on_event(defines.events.on_preplayer_mined_item, onMinedItem)
-- TODO: Check for the following, stop portals/chests/etc working while marked
-- Also remember to handle orbital payload contents
--script.on_event(defines.events.on_marked_for_deconstruction, function(event)
--script.on_event(defines.events.on_canceled_deconstruction, function(event)

function onPlacedEquipment(event)
  if event.equipment.name == "personal-microwave-antenna-equipment" then
    local data = {
      id = "personal-microwave-antenna-equipment-" .. global.next_equipment_id,
      is_equipment = true,
      equipment = event.equipment,
      player = game.players[event.player_index]
    }
    data.force = data.player.force
    data.site = Sites.getSiteForEntity(data.player)
    global.equipment[data.id] = data
    global.receivers[data.id] = data
    global.next_equipment_id = global.next_equipment_id + 1
  end
end

function onRemovedEquipment(event)
  if event.equipment == "personal-microwave-antenna-equipment" then
    for i,equip in pairs(global.equipment) do
      if not equip.equipment.valid then
        global.equipment[i] = nil
        global.receivers[i] = nil
      end
    end
    Power.updateMicrowaveTargets()
  end
end

script.on_event({defines.events.on_player_placed_equipment}, onPlacedEquipment)
script.on_event({defines.events.on_player_removed_equipment}, onRemovedEquipment)

script.on_event(defines.events.on_tick, function(event)
  -- TODO: Eventually handle all of these by registering ticks
  Portals.checkPlayersForTeleports()
  chestsMoveStacks(event)
  beltsMoveItems(event)
  Scanners.scan(event)
  Power.distributeMicrowavePower(event)
  Ticks.tick(event.tick)
  Gui.tick(event)
end)

local BASE_COST = 1000000 -- 1MJ
local GROUND_DISTANCE_MODIFIER = 0.1
local DISTANCE_MODIFIER = 100

-- TODO: Artifically bumped up since it's only a single item from a stack and
-- gets divided by 100 later. Need to revisit the formula, have a smaller overall
-- base_cost for belts and account for stack proportions.
local STACK_COST = 50000 / 2
local BELT_STACK_COST = 50000 * 10

-- TODO: Moves into entity utils library
function distanceBetween(a, b)
    return math.sqrt((a.position.x - b.position.x) ^ 2
      + (a.position.y - b.position.y)^2)
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
  return BASE_COST + STACK_COST * (DISTANCE_MODIFIER * Portals.spaceDistanceOfTeleport(portal)
                                  + GROUND_DISTANCE_MODIFIER * Portals.groundDistanceOfTeleport(portal))
end

function maxEnergyRequiredForBeltTeleport(belt)

  return BASE_COST
    + BELT_STACK_COST * (GROUND_DISTANCE_MODIFIER * distanceBetween(belt.entity, belt.entity.neighbours))

end

function energyRequiredForBeltTeleport(belt, count)
  -- TODO: Would be fairer to check against stack sizes and charge 1/stack_max per item
  return maxEnergyRequiredForBeltTeleport(belt) * count / 200
end

function chestsMoveStacks(event)
  -- Chests teleport every 2s (for now)
  -- TODO: Probably allow this to be set in GUI
  local checkFrequency = 120
  -- TODO: Optimisation. Move into a linked list we can traverse quickly.
  local tick = event.tick % checkFrequency
  local n = 0
  for i,portal in pairs(global.portals) do
    if portal.entity.name == "portal-chest" then
      n = n + 1
      if portal.teleport_target and portal.is_sender and n % checkFrequency == tick then
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
  local inventory = source.entity.get_inventory(defines.inventory.chest)
  local nextStack = source.next_stack or 1
  nextStack = (nextStack-1) % #inventory + 1
  local startStack = nextStack
  local abort = false
  local teleported = 0
  
  -- Null operation
  if inventory.is_empty() then return end
  
  local targetInventory = source.teleport_target.entity.get_inventory(defines.inventory.chest)

  -- TODO: Could check hasbar() to avoid looping stacks that are always empty / should not be teleported?
  -- TODO: Most of this looping is pointless now chests have only 1 stack, but might leave in case ever up them again

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
            --source.entity.force.print("Not enough power in chest on " .. source.site.surface_name)
            --source.entity.force.print("Required " .. energyRequired .. " available " .. source.fake_energy.energy)
            abort = true
          end
          -- TODO: Trigger not enough power warning on map?
        end
      end
    end

    nextStack = nextStack % #inventory + 1
    -- Abort if gone full circle
    if nextStack == startStack then
      abort=true
    end
  end

  -- Remember stack for next tick
  source.next_stack = nextStack
end

function beltsMoveItems(event)
  -- TODO: If items move at MAX_BELT_SPEED units/tick then moving an entire unit takes 1/MAX_BELT_SPEED (?) ticks = 10.6r
  -- Since we can't check at fractional ticks we err on the side of caution, check every 10 ticks, we'll slightly
  -- over-charge for some items sometimes but this is fine in terms of balance. However we *could* be undercharging
  -- since things can move so fast onto other end of belt
  -- TODO: Optimisation. Move into a list we can traverse quickly.
  local MAX_BELT_SPEED = 0.09375
  local checkFrequency = math.floor(1/MAX_BELT_SPEED)
  local tick = event.tick % checkFrequency
  local n = 0
  for i,portal in pairs(global.entities) do
    if portal.entity.name == "portal-belt" then
      n = n + 1
      -- Only proc if actually connnected and only if it's the input side (since power consumption will
      -- be same on both sides)
      if n % checkFrequency == tick and portal.entity.belt_to_ground_type == "input"
        and portal.entity.neighbours ~= nil then
        consumeBeltPower(portal)
      end
    end
  end
end

function consumeBeltPower(inputBelt)
  -- TODO: Quick hack following, charging power for any items currently on the line. This is probably
  -- drastically overcharging (need some tests to actually find out) but right now there's no way to know
  -- whether items are actually moving.

  -- TODO: Use proper indicies to get the correct line we're after
  --[[
  defines.transport_line.left_line 
  defines.transport_line.right_line 
  defines.transport_line.left_underground_line  
  defines.transport_line.right_underground_line 
  defines.transport_line.secondary_left_line  
  defines.transport_line.secondary_right_line 
  defines.transport_line.left_split_line  
  defines.transport_line.right_split_line 
  defines.transport_line.secondary_left_split_line  
  defines.transport_line.secondary_right_split_line
  --]]
  local line1 = inputBelt.entity.get_transport_line(1)
  local line2 = inputBelt.entity.get_transport_line(2)
  local line1out = inputBelt.entity.neighbours.get_transport_line(1)
  local line2out = inputBelt.entity.neighbours.get_transport_line(2)

  local totalItems = #line1 + #line2 + #line1out + #line2out
  local requiredEnergy = energyRequiredForBeltTeleport(inputBelt, totalItems)

  local neighbourFakeEnergy = getEntityData(inputBelt.entity.neighbours).fake_energy
  if (inputBelt.fake_energy.energy < requiredEnergy
    or neighbourFakeEnergy.energy < requiredEnergy) then
    inputBelt.entity.active = false
    inputBelt.entity.neighbours.active = false
  else
    inputBelt.entity.active = true
    inputBelt.entity.neighbours.active = true
    inputBelt.fake_energy.energy = inputBelt.fake_energy.energy - requiredEnergy
    neighbourFakeEnergy.energy = neighbourFakeEnergy.energy - requiredEnergy
  end
end

-- Handle objects launched in rockets
-- TODO: Handle this in Orbitals
function onRocketLaunched(event)
  local force = event.rocket.force
  local launchSite = Sites.getSiteForEntity(event.rocket_silo)
  if event.rocket.get_item_count("portal-lander") > 0 then
    local lander = Orbitals.newUnit("portal-lander", force, launchSite, {})
  end

  if event.rocket.get_item_count("solar-harvester") > 0 then
    local harvester = Orbitals.newUnit("solar-harvester", force, launchSite, {})
  end

  if event.rocket.get_item_count("space-telescope") > 0 then
    local telescope = Orbitals.newUnit("space-telescope", force, launchSite, {})
  end
end

script.on_event(defines.events.on_rocket_launched, onRocketLaunched)

-- Handle technology upgrades
function onResearchFinished(event)
  -- TODO: On long-range teleportation, could upgrade portal belts to a different type?
  -- Could have a series of research upgrades leading to interplanetary. Or nah ... just get straight there ;)
  -- TODO: On large-mass teleportation, start teleporting all stacks not just 1 at a time.  
end

script.on_event(defines.events.on_research_finished, onResearchFinished)

function onPlayerChangedSurface(event)
  Player.surfaceChanged(game.players[event.player_index])
end

script.on_event(defines.events.on_player_changed_surface, onPlayerChangedSurface)
function onPlayerRequiresInit(event)
  Gui.initForPlayer(game.players[event.player_index])
end
script.on_event(defines.events.on_player_changed_force, onPlayerRequiresInit)
script.on_event(defines.events.on_player_created, onPlayerRequiresInit)
-- TODO: Need to also delete GUI when player leaves game?
