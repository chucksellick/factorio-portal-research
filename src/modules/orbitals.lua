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
  return orbital
end

return Orbitals