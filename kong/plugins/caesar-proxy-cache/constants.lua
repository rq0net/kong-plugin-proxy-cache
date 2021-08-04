

function table_merge(t1, t2)
  for k,v in pairs(t2) do table.insert(t1, v) end
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

_M.CACHE_PATHES = {
    "/static", "/uploads"
}

_M.CONTENT_TYPES = {
  ["MEDIAS"] = { "audio/.*", "video/.*", "application/x-shockwave-flash", "text/css"},
  ["IMAGES"] = { "image/.*", "font/*" },
  ["PACKAGES"] = {"application/zip", "application/java-archive", "application/vnd.android.package-archive", "application/apk"},
  ["JS"] = {"text/javascript", "application/javascript"},
  ["*STATIC"] = {},
  ["*NONE"] = {},
  ["*AUTO"] = {},
}

table_merge( _M.CONTENT_TYPES["*STATIC"], _M.CONTENT_TYPES['MEDIAS'] )
table_merge( _M.CONTENT_TYPES["*STATIC"], _M.CONTENT_TYPES['IMAGES'] )
table_merge( _M.CONTENT_TYPES["*STATIC"], _M.CONTENT_TYPES['PACKAGES'] )
table_merge( _M.CONTENT_TYPES["*STATIC"], _M.CONTENT_TYPES['JS'] )


_M.CACHE_DATA = {
    ["NONE"] = {},
    ["STATIC"] = {},
    ["AUTO"] = {}
}

return _M
