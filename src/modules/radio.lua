local Radio = {}

local radio_update_frequency = 60

function Radio.init()
  global.radio = {
    channels = {},
    radios = {}
  }
end

function Radio.initializeMast(entityData)
  -- Defaults to receiver
  entityData.is_transmitter = false
  entityData.channel = 1
  Ticks.after(radio_update_frequency, "")
end

function Radio.initializeLogisticsCombinator(entityData)

end

function Radio.readMastInput(entityData)
  -- Inputs already have power consumption
end

function Radio.setMastOutput(entityData)
  -- TODO: Consume power
end

function Radio.setLogisticsCombinatorOutput(entityData)
  -- TODO: Consume power (?)
  local counts = Orbitals.getCounts()
  for name,count in pairs(counts) do

  end
end

return Radio