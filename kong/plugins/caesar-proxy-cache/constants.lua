

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