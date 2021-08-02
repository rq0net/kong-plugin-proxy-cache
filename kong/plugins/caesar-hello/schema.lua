-- schema.lua
local typedefs = require "kong.db.schema.typedefs"


return {
  name = "caesar-hello",
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
          {
            server = {
              type = "record",
              fields = {
                {
                  host = typedefs.host {
                    default = "example.com",
                  },
                },
                {
                  port = {
                    type = "number",
                    default = 80,
                    between = {
                      0,
                      65534
                    },
                  },
                },  
              },
            },
          },
        },
      },
    },
  },
}