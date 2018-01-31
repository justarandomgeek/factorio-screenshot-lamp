local function ReadPosition(signet,secondary,offset)
  if not offset then offset=0.5 end
  if not secondary then
    return {
      x = signet.get_signal({name="signal-X",type="virtual"})+offset,
      y = signet.get_signal({name="signal-Y",type="virtual"})+offset
    }
  else
    return {
      x = signet.get_signal({name="signal-U",type="virtual"})+offset,
      y = signet.get_signal({name="signal-V",type="virtual"})+offset
    }
  end
end

local function ReadBoundingBox(signet)
  -- adjust offests to make *inclusive* selection
  return {ReadPosition(signet,false,0),ReadPosition(signet,true,1)}
end

local function ReadSignal(rednet,greennet,signal)
  return
    (rednet and rednet.get_signal(signal) or 0) +
    (greennet and greennet.get_signal(signal) or 0)
end

local function onTick()
  -- for any that are satisfied, take screenshot!
  if global.screeners then
    for id,entity in pairs(global.screeners) do
      if not entity.valid then
        global.screeners[id] = nil
      else
        if entity.get_or_create_control_behavior().circuit_condition.fulfilled then
          local red = entity.get_circuit_network(defines.wire_type.red)
          local green = entity.get_circuit_network(defines.wire_type.green)

          local pos = {
            x = ReadSignal(red,green,{name="signal-X",type="virtual"}),
            y = ReadSignal(red,green,{name="signal-Y",type="virtual"})
          }

          local res = {
            x = ReadSignal(red,green,{name="signal-W",type="virtual"}),
            y = ReadSignal(red,green,{name="signal-H",type="virtual"})
          }

          local shot = {
            surface = entity.surface,
            position = entity.position,
            show_entity_info = ReadSignal(red,green,{name="signal-I",type="virtual"}) ~= 0,
            path = "screenshot-lamp/" .. entity.unit_number .. "/" .. game.tick .. ".png"

          }
          if pos.x ~= 0 and pos.y ~= 0 then
            shot.position = pos
          end
          if res.x ~= 0 and res.y ~= 0 then
            shot.resolution = res
          end

          game.take_screenshot(shot)
          
        end
      end
    end
  end
end

local function onBuilt(event)
  local entity = event.created_entity
  if entity.name == "screenshot-lamp" then
    if not global.screeners then global.screeners = {} end
    global.screeners[entity.unit_number] = entity
  end
end


script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)
