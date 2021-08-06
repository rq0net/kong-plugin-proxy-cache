local require = require
local setmetatable = setmetatable




local _M = {}

_M.CHALLENGE_TYPES = {
  "js",
  "cookie"
}


local function require_strategy(name)
  return require("kong.plugins.caesar-challenge.challenges." .. name)
end

return setmetatable(_M, {
  __call = function(_, opts)
    return require_strategy(opts.strategy_name).new(opts.strategy_opts)
  end
})
