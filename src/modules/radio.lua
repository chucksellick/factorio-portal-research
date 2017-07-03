local inspect = require("lib.inspect")
local Radio = {}

-- TODO: Implement copy/paste

local radio_update_frequency = 60
-- TODO: Read from prototype
local max_radio_combinator_slots = 10

local wire_colours = {defines.wire_type.red,defines.wire_type.green}

function Radio.initForce(forceData)
  forceData.radio = { channels = {} }
end

local function getChannels(force)
  local data = getForceData(force)
  if not data.radio then
    Radio.initForce(data)
  end
  return data.radio.channels
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
  if data.entity.entity.name == "radio-mast"
    or data.entity.entity.name == "radio-mast-transmitter" then
    if data.entity.is_transmitter then
      Radio.readMastInput(data.entity)
    else
      Radio.setMastOutput(data.entity)
    end
  elseif data.entity.entity.name == "orbital-logistics-combinator" then
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
-- For now I'm completely ignoring power because the more I think about it the more weird corner cases there are.

local function switchEntities(source, new_entity_name)
  local new_entity = source.entity.surface.create_entity{
    name = new_entity_name,
    position = source.entity.position,
    force = source.entity.force
  }

  -- Copy wire connections to the new entity
  for i,wire in pairs(wire_colours) do
    local entities = source.entity.circuit_connected_entities[wire]
    if entities then
      for e,entity in pairs(entities) do
        new_entity.connect_neighbour{wire=wire,target_entity=entity}
      end
    end
  end

  -- Manually update the global registry rather than letting normal cleanup do its work
  global.entities[source.id] = nil
  source.id = new_entity.unit_number
  global.entities[source.id] = source

  -- Destroy the old entity
  source.entity.destroy()
  -- Switcheroo complete
  source.entity = new_entity
end

function Radio.setTransmit(mast, transmit)
  if mast.is_transmitter ~= transmit then
    if transmit then
      Radio.switchToTransmitter(mast)
    else
      Radio.switchToReceiver(mast)
    end
  end
end

function Radio.switchToTransmitter(entityData)
  switchEntities(entityData, "radio-mast-transmitter")
  entityData.is_transmitter = true
  -- Make sure "lamp" is always on, and connected to circuits
  entityData.entity.get_or_create_control_behavior().connect_to_logistic_network = false
  entityData.entity.get_control_behavior().circuit_condition = {
    condition = {
      comparator = ">",
      first_signal = {type = "virtual", name = "signal-everything"},
      constant = 0
    }
  }
end

function Radio.switchToReceiver(entityData)
  switchEntities(entityData, "radio-mast")
  entityData.is_transmitter = false
end

function Radio.changeMastChannel(entityData, channel)
  -- TODO: Clearing channel immediately, should lag a bit?
  if entityData.channel == channel then return end
  local channels = getChannel(entityData.force)
  channels[entityData.channel] = nil
  entityData.channel = channel
end

function Radio.readMastInput(entityData)
  -- Merge red and green network counts together
  local signals = {}
  local parameters = {}
  local signal_index = 1
  -- TODO: This might be a bit slow if we wanted to reduce radio ping. Might be a fast way to do things
  -- avoiding all the object creation and string concatenation. Investigate and maybe borrow some code from somewhere :)
  for i,wire in pairs(wire_colours) do
    local network = entityData.entity.get_circuit_network(wire)
    if network and network.signals then
      for index,signal in pairs(network.signals) do
        local temp_name = signal.signal.type.."."..signal.signal.name
        if signals[temp_name] then
          signals[temp_name].count = signals[temp_name].count + signal.count
        elseif signal_index <= max_radio_combinator_slots then
          signals[temp_name] = {
            signal = signal.signal,
            index = signal_index,
            count = signal.count
          }
          signal_index = signal_index + 1
          table.insert(parameters, signals[temp_name])
        end
      end
    end
  end

  -- TODO: Store a list of the receivers
  local channels = getChannel(entityData.force)
  channels[entityData.channel] = channels[entityData.channel] or {}
  channels[entityData.channel].parameters = {parameters = parameters} -- That's correct.
end

function Radio.setMastOutput(entityData)
  -- TODO: Consume power
  local control_behavior = entityData.entity.get_or_create_control_behavior()
  if not control_behavior.enabled then return end
  local channels = getChannel(entityData.force)
  if channels[entityData.channel] then
    control_behavior.parameters = channels[entityData.channel].parameters
  else
    control_behavior.parameters = nil
  end
end

function Radio.setLogisticsCombinatorOutput(entityData)
  local control_behavior = entityData.entity.get_or_create_control_behavior()
  if not control_behavior.enabled then return end

  -- TODO: On radio mast using a different method of
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

function Radio.openMastGui(playerData, gui, data, window_options)

  local row1 = gui.add{type="flow",direction="horizontal"}

  Gui.createButton(playerData.player, row1, {
      name="radio-mast-receive-" .. data.id,
      caption={"portal-research.radio-mast-receive-button-caption"},
      action={name="radio-mast-set-transmit",mast=data,transmit=false}
  })

  Gui.createButton(playerData.player, row1, {
      name="radio-mast-transmit-" .. data.id,
      caption={"portal-research.radio-mast-transmit-button-caption"},
      action={name="radio-mast-set-transmit",mast=data,transmit=true}
  })

  local row2 = gui.add{type="flow",direction="horizontal"}

  row2.add{
    type="label",
    caption={"portal-research.radio-mast-"..(data.is_transmitter and "transmitting" or "receiving").."-caption"}
  }

  row2.add{
    type="textfield",
    name="radio-mast-channel-number-textfield",
    text=data.channel
  }

  -- TODO: Slider for channel # ... if they ever provide one ... could fudge with scrollbar?
  -- TODO: List receivers or at least receiver counts. Update when channel changed.
end

return Radio