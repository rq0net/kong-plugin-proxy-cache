-- schema.lua
local typedefs = require "kong.db.schema.typedefs"


return {
  name = "caesar-defend-rule",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            rules = {
              type = "array",
              elements = {
                type = "record",
                fields = {
                  {
                    condition = {
                      type = "string",
                      required = true,
                      one_of = {
                        "IP",
                        "User-Agent",
                        "URI",
                        "Header",
                        "Protocol"
                      },
                    },
                    match_needle = {
                      type = "string",
                      required = true,
                    },
                    action_code = {
                      type = "string",
                      required = true,
                      one_of = {
                        ngx.HTTP_OK,
                        ngx.HTTP_MOVED_TEMPORARILY,
                        ngx.HTTP_BAD_REQUEST,
                      },
                    },
                    action_value = {
                      type = "string",
                      required = false,
                    },
                    description = {
                      type = "string",
                      required = false,
                    }
                  }
                },
              },
            },
          },
        },
      },
    },
  },
}