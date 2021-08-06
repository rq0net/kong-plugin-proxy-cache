-- schema.lua
local typedefs = require "kong.db.schema.typedefs"


return {
  name = "caesar-challenge",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          { strategy = {
            type = "string",
            one_of = strategies.CHALLENGE_TYPES,
            required = true,
          }}
        },
      },
    },
  },
}