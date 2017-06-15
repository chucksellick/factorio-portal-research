data:extend(
{
  {
    type = "battery-equipment",
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
      usage_priority = "primary-output",
      buffer_capacity = "20MJ",
      input_flow_limit = "0MW",
      output_flow_limit = "10MW" -- Decently stronger than fusion reactor @ 0.75MW
    },
    --power = "5MW",
    categories = {"armor"}
  }
}
)