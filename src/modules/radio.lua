local Radio = {}

local radio_update_frequency = 60

function Radio.init()
  global.radio = global.radio or {
    channels = {},
    radios = {}
  }
end

function Radio.initializeMast(entityData)
  -- Defaults to receiver
  entityData.is_transmitter = false
  entityData.channel = 1
  entityData.next_update_tick = Ticks.after(radio_update_frequency, "radio.update_entity", {entity=entityData})
end

function Radio.initializeLogisticsCombinator(entityData)
  entityData.next_update_tick = Ticks.after(radio_update_frequency, "radio.update_entity", {entity=entityData})
end

function Radio.updateEntity(data)
  if data.entity.entity.name == "orbital-logistics-combinator" then
    Radio.setLogisticsCombinatorOutput(data.entity)
  end
  data.entity.next_update_tick = Ticks.after(radio_update_frequency, "radio.update_entity", {entity=data.entity})
end

Ticks.registerHandler("radio.update_entity", Radio.updateEntity)

-- Note: Power consumption is a bit hard here. Clearly the transmitter masts should consume
-- power and this can be reasonably simulated by increasing the time to next transmit if not
-- enough power was available. But it's slightly less clear what to do for receivers; don't want
-- every single radio receiver to receive at slightly different times (for UPS reasons) although
-- doing this would allow a more accurate simulation of distances between the receivers at asteroids.

function Radio.readMastInput(entityData)
  -- Inputs already have power consumption
end

function Radio.setMastOutput(entityData)
  -- TODO: Consume power
end

function Radio.setLogisticsCombinatorOutput(entityData)
  local control_behavior = entityData.entity.get_or_create_control_behavior()
  if not control_behavior.enabled then return end

  -- TODO: Factorissimo2 uses a different method by preparing an array and
  -- setting control_behavior.parameters in one go. Need to test and verify which method is
  -- faster. Since only setting a couple here it doesn't matter but could make
  -- more difference for radio.

  -- Clear existing params
  control_behavior.parameters = nil

  local counts = Orbitals.getCounts()

  local index = 1
  for name,count in pairs(counts) do
    control_behavior.set_signal(index, {signal = {type = "item", name = name}, count = count})
    index = index + 1
  end
           
  -- TODO: Consume power (?), reduce update frequency

end

return Radio