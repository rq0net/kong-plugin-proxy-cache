-- schema.lua
local typedefs = require "kong.db.schema.typedefs"


return {
  name = "caesar-hostname",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            environment = {
              type = "string",
              required = true,
              one_of = {
                "production",
                "development",
              },
            },
          },
        }
      },
    },
  },
}