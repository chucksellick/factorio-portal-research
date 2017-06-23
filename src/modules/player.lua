local Player = {}

function Player.surfaceChanged(player)
  -- Player may need to use a different transmitter
  for i,equip in pairs(global.equipment) do
    if equip.player == player then
      equip.site = Sites.getSiteForEntity(player)
    end
  end

  -- TODO: Also teleport logistic/construction/follower bots! (Fine when changing surface but not otherwise)

  -- Player may need to use a different transmitter
  -- TODO: Immediately cutoff beam (and update microwaves list)
  updateMicrowaveTargets()

  -- Update home teleport button
  Gui.updateForPlayer(player)
end

return Player