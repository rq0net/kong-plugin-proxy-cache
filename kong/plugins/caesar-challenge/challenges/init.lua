local require = require
local setmetatable = setmetatable




local _M = {}

_M.CHALLENGE_TYPES = {
  "js",
  "puzzle",
  "cookie"
}


local function require_challenge(name)
  return require("kong.plugins.caesar-challenge.challenges." .. name)
end

return setmetatable(_M, {
  __call = function(_, opts)
    return require_challenge(opts.challenge_name).new(opts.challenge_opts)
  end
})
