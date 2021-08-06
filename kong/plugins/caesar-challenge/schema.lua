-- schema.lua
local challenges = require "kong.plugins.caesar-challenge.challenges"
local typedefs = require "kong.db.schema.typedefs"


return {
  name = "caesar-challenge",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          { challenge = {
            type = "string",
            one_of = challenges.CHALLENGE_TYPES,
            required = true,
          }}
        },
      },
    },
  },
}