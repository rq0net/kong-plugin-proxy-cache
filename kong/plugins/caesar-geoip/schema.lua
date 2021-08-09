local iputils = require "resty.iputils"

local function validate_ips(v, t, column)
  if v and type(v) == "table" then
    for _, ip in ipairs(v) do
      local _, err = iputils.parse_cidr(ip)
      if type(err) == "string" then -- It's an error only if the second variable is a string
        return false, "cannot parse '" .. ip .. "': " .. err
      end
    end
  end
  return true
end

return {
  name = "caesar-geoip",
  fields = {
    { config = {
      type = "record",
      fields = {
        { whitelist_ips = {
          type = "array",
          elements = { type = "string" },
          required = false,
          custom_validator = validate_ips
        }},
        { request_method = {
          type = "array",
          elements = {
            type = "string"
          },
          required = false
        }},
      }
    }},
  }
}
