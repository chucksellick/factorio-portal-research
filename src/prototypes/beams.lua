local beam_blend_mode = "additive-soft"

function makeBeam(name, sound, width)
  local result = 
  {
    type = "beam",
    flags = {"not-on-map"},
    width = width,
    damage_interval = 20,
    -- TODO: Any to completely remove the action?
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            -- https://wiki.factorio.com/Types/AttackReaction#TriggerEffect_Definition
            type = "create-smoke",
            entity_name = "nuclear-smoke",
          }
        }
      }
    },
    head =
    {
      filename = "__base__/graphics/entity/beam/beam-head.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      animation_speed = 0.5,
      blend_mode = beam_blend_mode,
      tint = tint
    },
    tail =
    {
      filename = "__base__/graphics/entity/beam/beam-tail.png",
      line_length = 16,
      width = 45,
      height = 39,
      frame_count = 16,
      blend_mode = beam_blend_mode,
      tint = tint
    },
    body =
    {
      {
        filename = "__base__/graphics/entity/beam/beam-body-1.png",
        line_length = 16,
        width = 45,
        height = 39,
        frame_count = 16,
        blend_mode = beam_blend_mode,
        tint = tint
      },
      {
        filename = "__base__/graphics/entity/beam/beam-body-2.png",
        line_length = 16,
        width = 45,
        height = 39,
        frame_count = 16,
        blend_mode = beam_blend_mode,
        tint = tint
      },
      {
        filename = "__base__/graphics/entity/beam/beam-body-3.png",
        line_length = 16,
        width = 45,
        height = 39,
        frame_count = 16,
        blend_mode = beam_blend_mode,
        tint = tint
      },
      {
        filename = "__base__/graphics/entity/beam/beam-body-4.png",
        line_length = 16,
        width = 45,
        height = 39,
        frame_count = 16,
        blend_mode = beam_blend_mode,
        tint = tint
      },
      {
        filename = "__base__/graphics/entity/beam/beam-body-5.png",
        line_length = 16,
        width = 45,
        height = 39,
        frame_count = 16,
        blend_mode = beam_blend_mode,
        tint = tint
      },
      {
        filename = "__base__/graphics/entity/beam/beam-body-6.png",
        line_length = 16,
        width = 45,
        height = 39,
        frame_count = 16,
        blend_mode = beam_blend_mode,
        tint = tint
      },
    }
  }
  
  if sound then
    result.working_sound =
    {
      {
        filename = "__base__/sound/fight/electric-beam.ogg",
        volume = 0.7
      }
    }
    result.name = name
  else
    result.name = name .. "-no-sound"
  end
  return result;
end

data:extend(
{
  makeBeam("microwave-beam", true, 2.5, {r=1,g=0,b=0}),
  makeBeam("microwave-beam", false, 2.5, {r=1,g=0,b=0}),
  makeBeam("orbital-microwave-beam", true, 10, {r=1,g=0,b=0}),
  makeBeam("orbital-microwave-beam", false, 10, {r=1,g=0,b=0})
}
)
