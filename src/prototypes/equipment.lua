data:extend(
{
  {
    type = "generator-equipment",
    name = "personal-microwave-antenna-equipment",
    sprite =
    {
      filename = "__base__/graphics/equipment/fusion-reactor-equipment.png",
      width = 128,
      height = 128,
      priority = "medium",
      tint = {r=0,g=0,b=1}
    },
    -- Can simply drop in place of fusion reactors, no need to drastically reorganise kitt
    -- TODO: Or, what about a different shape?
    shape =
    {
      width = 4,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "10MW", -- Suitably stronger than fusion reactor @ 0.75MW
    categories = {"armor"}
  },
  -- TODO: Realistically two ways to implement this. Either perform some item-sleight-of-hand to swap with a "dead" version, or manipulate the internal
  -- buffer. 2nd option probably more satisfactory gameplay-wise for the case when not full 10MW is availablle.
  --[[
  {
    -- 
    type = "generator-equipment",
    name = "personal-microwave-antenna-equipment-dead",
    sprite =
    {
      filename = "__base__/graphics/equipment/fusion-reactor-equipment.png",
      width = 128,
      height = 128,
      priority = "medium",
      tint = {r=1,g=0,b=0}
    },
    -- Can simply drop in place of fusion reactors, no need to drastically reorganise kitt
    -- TODO: Or, what about a different shape?
    shape =
    {
      width = 4,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "0MW",
    categories = {"armor"}
  }]]
}
)