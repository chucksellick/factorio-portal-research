Ticks = {}

local handlers = {}

local function newTick(tick)
  return {
    tick = tick,
    actions = {},
    next = nil
  }
end

function Ticks.init()
  -- TODO: Can only hope that the serializer supports a lot of recursion...
  global.next_tick = global.next_tick or nil
end

function Ticks.on(tick, action, data)
  tick = math.ceil(tick)
  local data = {action=action,data=data}
  local target_tick = nil
  local next_tick = global.next_tick
  -- TODO: This could be simplified; the code after 'else' can almost handle this case with some extra guards
  if next_tick == nil or next_tick.tick > tick then
    target_tick = newTick(tick)
    target_tick.next = next_tick
    global.next_tick = target_tick
  else
    local this_tick = next_tick
    local last_tick = nil
    while true do
      if this_tick == nil then
        target_tick = newTick(tick)
        last_tick.next = target_tick
        break
      elseif this_tick.tick == tick then
        target_tick = next_tick
        break
      elseif this_tick.tick > tick and last_tick.tick < tick then
        -- Splice
        target_tick = newTick(tick)
        last_tick.next = target_tick
        target_tick.next = this_tick
        break
      end
      last_tick = this_tick
      this_tick = this_tick.next
    end
  end
  table.insert(target_tick.actions, data)
  return { tick = tick, data = data }
end

function Ticks.after(ticks, action, data)
  return Ticks.on(ticks + game.tick, action, data)
end

function getTick(tick)
  local this_tick = global.next_tick
  while true do
    if this_tick == nil then return nil end
    if this_tick.tick == tick then
      return this_tick
    end
    this_tick = this_tick.next
  end
end

function Ticks.cancel(tick_data)
  local tick = getTick(tick_data.tick)
  if tick ~= nil then
    -- Safe remove by iterating backwards
    for i=#tick.actions,1,-1 do
      if tick.actions[i].data == tick_data.data then
        table.remove(tick.actions, i)
      end
    end
  end
end

function Ticks.registerHandler(action, handler)
  handlers[action] = handler
end

function Ticks.tick(tick)
  local next_tick = global.next_tick
  if next_tick and next_tick.tick == tick then
    for i,action in pairs(next_tick.actions) do
      handlers[action.action](action.data)
    end
    global.next_tick = next_tick.next
  end
end

return Ticks