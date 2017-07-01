local Player = {}

function Player.surfaceChanged(player)
  -- Player may need to use a different transmitter
  for i,equip in pairs(global.equipment) do
    if equip.player == player then
      equip.site = Sites.getSiteForEntity(player)
    end
  end

  -- TODO: Also teleport logistic/construction/follower bots! (Only matters on current surface)

  -- Player may need to use a different transmitter
  Power.updateMicrowaveTargets()

  -- Update home teleport button
  Gui.updateForPlayer(player)
end

return Player