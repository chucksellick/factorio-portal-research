local Power = {}

-- TODO: Player beams are particularly distracting. Better to just have some glowly sprite
-- sticking out of the player's backpack rather than a whole beam.

local function destroyBeamEntity(transmitter)
  if transmitter.beam_entity and transmitter.beam_entity.valid then
    transmitter.beam_entity.destroy()
    transmitter.beam_entity = nil
  end
  if transmitter.beam_entity_source and transmitter.beam_entity_source.valid then
    transmitter.beam_entity_source.destroy()
    transmitter.beam_entity_source = nil
  end
end

local function createBeamEntity(transmitter)
  -- Don't recreate beam when not needed
  if transmitter.beam_entity and transmitter.beam_entity.valid
    and not transmitter.is_orbital and not transmitter.current_target.is_equipment
    then
    return
  end

  destroyBeamEntity(transmitter)

  local beam_name = "microwave-beam"
  local beam_source = transmitter.entity
  local beam_target = transmitter.current_target.is_equipment
    and transmitter.current_target.player.character or transmitter.current_target.entity

  -- TODO: Maybe instead of using beams should manually use a decorative/sticker sprite
  -- that's very long (is any rotation possible at all?) Beams seem to have some issues we can't get around.
  if transmitter.is_orbital then
    beam_name = "orbital-microwave-beam"
    beam_source =
      beam_target.surface.create_entity{
        name="orbital-microwave-beam-source",
        position={x=beam_target.position.x,y=beam_target.position.y-100}
      }
    transmitter.beam_entity_source = beam_source
  end

  transmitter.beam_entity = beam_target.surface.create_entity {
    name=beam_name,
    source=beam_source,
    target=beam_target,
    position={x=beam_target.position.x,y=beam_target.position.y}
  }
end

function Power.distributeMicrowavePower(event)
  -- TODO: Important quote here from Wiki. Aim is to accurately reflect this.
  -- "A modest Gigawatt-range microwave system, comparable to a large commercial power plant, would require launching
  -- some 80,000 tons of material to orbit, making the cost of energy from such a system vastly more expensive than even
  -- present day nuclear plants. Some technologists speculate that this may change in the distant future if an off-world
  -- industrial base were to be developed that could manufacture solar power satellites out of asteroids or lunar material,
  -- or if radical new space launch technologies other than rocketry should become available in the future.

  -- TODO: (Based on above). What this means is we should implement some kind of Offworld Rocket Silo. Allowing things to be
  -- launched far cheaper. An obvious middle-stage is reusable rockets. A space platform launcher can be effectively
  -- zero-gee and is nearly as cheap as cargo catapult.

  local interval = 120

  if event.tick % interval ~= 0 then return end

  local transmit_duration = 600 -- TODO: Allow configuration per sender via some GUI

  for i,transmitter in pairs(global.transmitters) do
    if transmitter.current_target == nil
      or (transmitter.transmit_started_at + transmit_duration) < event.tick then
      -- Deactivate old target so it no longer receives
      if transmitter.current_target then
        if transmitter.current_target.entity then
          transmitter.current_target.entity.active = false
        end
        transmitter.current_target.current_source = nil
        transmitter.current_target = nil
      end

      -- Beam can become invalid when the source or target are removed
      destroyBeamEntity(transmitter)

      -- Pick a new target.
      if transmitter.current_target_index == nil then transmitter.current_target_index = #transmitter.target_antennas end

      if #transmitter.target_antennas > 0 then
        abort = false
        local index = transmitter.current_target_index
        index = (index % #transmitter.target_antennas) + 1
        local start_index = index
        while transmitter.current_target == nil and not abort do
          if not transmitter.target_antennas[index].current_source then
            transmitter.current_target = transmitter.target_antennas[index]
            transmitter.current_target.current_source = transmitter
            transmitter.transmit_started_at = event.tick + interval -- Adding on interval since nothing is transmitted for 120 ticks
            -- Don't buffer while not sending
            -- TODO: The logic here is all kind of screwy, fix this when fixing the delays between targets.
            if not transmitter.is_orbital then
              transmitter.entity.electric_input_flow_limit = 0
            end
          end
          index = (index % #transmitter.target_antennas) + 1
          if index == start_index then
            abort = true
          end
        end
      end

    else
      if transmitter.current_target ~= nil then
        -- TODO: The above is a cheap way to have a 2s delay between targets. Should implement this in a better way.

        createBeamEntity(transmitter)

        if transmitter.is_orbital then
          if transmitter.current_target.is_equipment then
            -- Top equipment battery up to full
            transmitter.current_target.equipment.energy = transmitter.current_target.equipment.max_energy
          else
            -- It's a solar harvester, always sends full amount; reset to original prototype value. Was trying to
            -- use power_production but it doesn't seem to be available on the prototype so used output_flow_limit
            -- instead. Since it doesn't get manipulated ever it's fine. TODO: What happens if we leave power_productionn
            -- constant and manipulate output_flow_limit instead?
            transmitter.current_target.entity.active = true
            transmitter.current_target.entity.power_production = 
              transmitter.current_target.entity.prototype.electric_energy_source_prototype.output_flow_limit
          end
        else
          -- Must be microwave transmitter. See how much energy has been raised in the last n ticks,
          -- then we can produce that much power at the other end over next n ticks
          local energyToSend = transmitter.entity.energy
          transmitter.entity.energy = 0

          -- Fix input flow which may have been deactivated when a new target was picked
          transmitter.entity.electric_input_flow_limit = transmitter.entity.prototype.electric_energy_source_prototype.input_flow_limit
          -- TODO: Also it could be interesting to implement the delay in receiving power due to microwaves moving at lightspeed.
          -- BUT this would be inconsistent since for the most part I'm assuming that relativity doesn't exist and lightspeed is infinite ;)

          if transmitter.current_target.is_equipment then
            -- For the equipment grid, do a straight energy transfer
            -- TODO: Not quite sure whether this is fair, there is literally no internal battery. Definitely need to
            -- change the recipe to reflect this...
            transmitter.current_target.equipment.energy = energyToSend -- + transmitter.current_target.equipment.energy
          else
            local maxSendRate = transmitter.entity.prototype.electric_energy_source_prototype.input_flow_limit
            local desiredSendRate = energyToSend / interval

            -- TODO: Sometimes still ending up with an invalid target, for no obvious reason. Need to check sources when an entity is deleted/destroyed
            -- and do something straight away instead of waiting for next tick
            transmitter.current_target.entity.active = true
            transmitter.current_target.entity.power_production = math.min(maxSendRate, desiredSendRate)
          end
        end
      end
    end
  end
  -- TODO: Nice if radars pointed in the right directions
end

function Power.updateMicrowaveTargets()
  -- TODO: This could become horrible with a lot of units. It doesn't happen very often but still this
  -- data could be maintained more efficiently on create/destroy
  for i, data in pairs(global.transmitters) do
    data.target_antennas = {}
    if data.current_target then
      -- Has transmitter been deleted?
      if data.deleted then
        destroyBeamEntity(data)
        -- TODO: Should have an is_entity probably...
        if not data.current_target.is_equipment then
          data.current_target.entity.active = false
        end
        data.current_target.current_source = nil
      end
      -- Has receiver been deleted?
      if (data.current_target.entity and not data.current_target.entity.valid)
        or (data.current_target.is_equipment and 
          (not data.current_target.equipment.valid
            or data.current_target.player.surface ~= data.site.surface))
        then
        data.current_target.current_source = nil
        data.current_target = nil
        -- Check same index again next time rather than end up skipping a target
        data.current_target_index = data.current_target_index - 1
        destroyBeamEntity(data)
      end
    end
    for i, antenna in pairs(global.receivers) do
      -- Transmission only within current surface or from orbital to nearest site
      if antenna.force == data.force
        and ((antenna.is_equipment and antenna.player.surface == data.site.surface)
          or antenna.site == data.site)
        then
        table.insert(data.target_antennas, antenna)
      end
    end
  end
  -- TODO: Could fix energy source settings from prototype whilst we're at it in case anything changed (but should only be done oninit really)
end

return Power