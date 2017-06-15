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

  -- TODO: Stage this a bit so we see it blow up before the player teleports in
  -- TODO: And display warning and require confirmationn
  -- Note: Simply setting the health to 0 doesn't seem to ever actually destroy the object.
  --       Could also use die() ... but that wouldn't attribute the kill to anyone!
  if portal.entity.valid then
    portal.entity.damage(portal.entity.health, player.force)
  end
  
  playerData.emergency_home_portal = nil
  playerData.emergency_home_position = nil
  Player.surfaceChanged(player)
end


function Portals.openPortalGui(player, portal)
  Gui.showPortalDetails(player, portal)
end

return Portals
