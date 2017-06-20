local Portals = {}

function Portals.emergencyHomeTeleport(player)
  -- Laws-of-physics-defying emergency teleport ... it will at least destroy a portal (if still valid)
  -- as a punishment!
  -- TODO: Consequences could be more drastic. Cause a nuke-like explosion at the arrival point. Drain all machines energy. Destroy the asteroid as you leave. etc. etc.
  -- Also, if the original portal is invalid, look for a different one on the same surface.
  local playerData = getPlayerData(player)
  local surface = game.surfaces["nauvis"]
  local portal = playerData.emergency_home_portal
  if portal.entity.valid then
    surface = portal.entity.surface
  end

  player.teleport(playerData.emergency_home_position, surface)
  
  playerData.emergency_home_portal = nil
  playerData.emergency_home_position = nil

  -- TODO: Stage this a bit so we see it blow up before the player teleports in
  -- TODO: And display warning and require confirmationn
  -- Note: Simply setting the health to 0 doesn't seem to ever actually destroy the object.
  --       Could also use die() ... but that wouldn't attribute the kill to anyone!
  if portal.entity.valid then
    portal.entity.damage(portal.entity.health, player.force)
  end
end

function Portals.openPortalGui(player, portal)
  Gui.showPortalDetails(player, portal)
end

-- TODO: Duplicated in control.lua, consolidate and sort all this out somehow
-- TODO: Bring cost down on research levels for force
local BASE_COST = 1000000 -- 1MJ
local PLAYER_COST = 25000000 / 2
local GROUND_DISTANCE_MODIFIER = 0.1
local DISTANCE_MODIFIER = 100

-- TODO: Thinking realistically about how portals should work(!), need to change everything a bit.
-- Opening a portal should incur the big base cost, keeping it open has an ongoing cost, moving matter
-- has an additional cost. So as long as a portal stays open things will be cheaper, but portals
-- should automatically close while idle?

local function maxEnergyRequiredForPlayerTeleport(portal)

  -- Algorithm as follows:
  --   Base cost to initate a teleport
  --   Plus cost for player (adjust depending on inventory size? Items carried? In vehicle?)
  --   Multiplied by distance cost

  if not portal.teleport_target then
    return 0
  end
  return BASE_COST + PLAYER_COST * (
    DISTANCE_MODIFIER * Portals.spaceDistanceOfTeleport(portal)
    + GROUND_DISTANCE_MODIFIER * Portals.groundDistanceOfTeleport(portal))

end

local function energyRequiredForPlayerTeleport(portal, player)
  -- TODO: Adjust on player inventory size
  return maxEnergyRequiredForPlayerTeleport(portal)
end

local function enterPortal(player, portal, direction)
  if portal.teleport_target == nil then
    Portals.openPortalGui(player, portal)
    return
  end
  -- Check enough energy is available
  local energyRequired = energyRequiredForPlayerTeleport(portal)
  local energyAvailable = portal.entity.energy + portal.teleport_target.entity.energy

  -- TODO: Use the portal visual to show that energy isn't available
  if energyAvailable < energyRequired then
    player.print("Not enough energy, required " .. energyRequired / 1000000 .. "MJ, had " .. energyAvailable / 1000000 .. "MJ")
    return
  end
  player.print("Teleporting using " .. energyRequired / 1000000 .. "MJ")

  -- When travelling offworld, set the emergency teleport back to where we left
  -- Note: "home" is always nauvis for now.
  local currentSite = getSiteForEntity(player)
  if currentSite ~= portal.site and (currentSite == nil or currentSite.surface.name == "nauvis") then
    local playerData = getPlayerData(player)
    playerData.emergency_home_portal = portal
    playerData.emergency_home_position = portal.entity.position
  end

  -- TODO: Freeze player and show teleport anim/sound for a second
  local targetPos = {
    -- x is the same relative to both portals, y is inverted
    x = portal.teleport_target.entity.position.x + player.position.x - portal.entity.position.x,
    y = portal.teleport_target.entity.position.y - player.position.y + portal.entity.position.y
  }

  -- Sap energy from both ends of the portal, local end first
  local missingEnergy = math.max(0, energyRequired - portal.entity.energy)
  portal.entity.energy = portal.entity.energy - energyRequired
  portal.teleport_target.entity.energy = portal.teleport_target.entity.energy - missingEnergy

  player.teleport(targetPos, portal.teleport_target.site.surface)
end

function findPortalInArea(surface, area)
  local candidates = surface.find_entities_filtered{area=area, name="medium-portal"}
  for _,entity in pairs(candidates) do
    return getEntityData(entity)
  end
  return nil
end

function Portals.checkPlayersForTeleports()
  local tick = game.tick
  for player_index, player in pairs(game.players) do
    -- TODO: Allow driving into BIG portals?
    -- TODO: Balance ticks...
    local playerData = getPlayerData(player)
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

function Portals.groundDistanceOfTeleport(portal)
  if portal.site ~= portal.teleport_target.site then
    return 0
  else
    return distanceBetween(portal.teleport_target.entity, portal.entity)
  end
end

function Portals.spaceDistanceOfTeleport(portal)
  if portal.site == portal.teleport_target.site then
    return 0
  else
    return math.abs(portal.teleport_target.site.distance - portal.site.distance)
  end
end

function Portals.updateEnergyProperties(portal)

  -- TODO: Seems like a) portals should charge quicker, and b) chests and/or portals should
  -- have a larger buffer e.g. 4 teleports; seeing loads of mwave energy being wasted then portals
  -- failing to operate

  local entity = portal.entity
  local requiredEnergy = 0
  if entity.name == "medium-portal" and portal.teleport_target then
    requiredEnergy = maxEnergyRequiredForPlayerTeleport(portal)
  end
  if entity.name == "portal-chest" and portal.teleport_target then
    requiredEnergy = maxEnergyRequiredForStackTeleport(portal)
  end
  if entity.name == "portal-belt" and portal.entity.neighbours then
    requiredEnergy = maxEnergyRequiredForBeltTeleport(portal) * 4 / 100
  end
  requiredEnergy = math.ceil(requiredEnergy)

  -- Buffer stores enough for 2 teleports
  local BUFFER_NUM = 2
  local SECONDS_TO_CHARGE = 2
  local interface = ensureEnergyInterface(portal)
  interface.electric_buffer_size = BUFFER_NUM * requiredEnergy
  -- Buffer fill rate scales with 
  -- TODO: Should scale a bit but not as much as this
  interface.electric_input_flow_limit = requiredEnergy / SECONDS_TO_CHARGE
  interface.electric_output_flow_limit = interface.prototype.electric_energy_source_prototype.output_flow_limit
  interface.electric_drain = interface.prototype.electric_energy_source_prototype.drain

  -- Landed portals come pre-charged, but we didn't know *how* much they needed until now.
  if portal.is_fully_charged then
    portal.is_fully_charged = false
    interface.energy = interface.electric_buffer_size
   end
  --TODO: This caused a super strange error but I don't know if drain is the same energy_usage value from the actual prototype...
  --interface.power_usage = interface.prototype.energy_usage
end

return Portals
