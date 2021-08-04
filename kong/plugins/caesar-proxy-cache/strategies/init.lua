local require = require
local setmetatable = setmetatable
local merge        = table.merge


function table_merge(t1, t2)
  for k,v in pairs(t2) do t1[k] = v end
end


local _M = {}

_M.STRATEGY_TYPES = {
  "memory",
  "redis",
  "file"
}

_M.SESS = {
  ".*[J|S]ESS.*"
}


_M.CONTENT_TYPES = {
  ["MEDIAS"] = { "audio/.*", "video/.*", "application/x-shockwave-flash"},
  ["IMAGES"] = { "image/.*", "font/*" },
  ["PACKAGES"] = {"application/zip", "application/java-archive", "application/vnd.android.package-archive", "application/apk"},
  ["JS"] = {"text/javascript"},
  ["STATIC"] = {}
}

table_merge( _M.CONTENT_TYPES["STATIC"], _M.CONTENT_TYPES['MEDIAS'] )
table_merge( _M.CONTENT_TYPES["STATIC"], _M.CONTENT_TYPES['IMAGES'] )
table_merge( _M.CONTENT_TYPES["STATIC"], _M.CONTENT_TYPES['PACKAGES'] )
table_merge( _M.CONTENT_TYPES["STATIC"], _M.CONTENT_TYPES['JS'] )


_M.CACHE_DATA = {
  ["NONE"] = {},
  ["STATIC"] = {},
  ["AUTO"] = {}
}


-- strategies that store cache data only on the node, instead of
-- cluster-wide. this is typically used to handle purge notifications
_M.LOCAL_DATA_STRATEGIES = {
  memory = true,
  [1]    = "memory",
}

local function require_strategy(name)
  return require("kong.plugins.caesar-proxy-cache.strategies." .. name)
end

return setmetatable(_M, {
  __call = function(_, opts)
    return require_strategy(opts.strategy_name).new(opts.strategy_opts)
  end
})