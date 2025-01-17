local cjson = require "cjson.safe"
local lfs = require("lfs")

local ngx          = ngx
local type         = type
local time         = ngx.time
local shared       = ngx.shared
local setmetatable = setmetatable




--- Create Cache File storage

local Cfs = {}   -- CacheFileStorage

function Cfs:new(opts)
  local self = {
    cache_path = opts.dictionary_name,
    opts = opts,
  }

  return setmetatable(self, {
    __index = Cfs,
  })
end

function Cfs:mkdir(dir)
  local sep, pStr = package.config:sub(1, 1), ""

  -- /var/cache/kong/07/7e
  local basedir = string.sub(dir, 1, #dir - 5)
  local tail = string.sub(dir, #dir - 5, #dir)

  for dir in tail:gmatch("[^" .. sep .. "]+") do
    pStr = pStr .. dir .. sep
    lfs.mkdir(basedir .. pStr)
  end
end

function Cfs:set(key, content)
  local f1, f2 = string.sub(key, 1, 2), string.sub(key, 3, 4)
  local dir = self.cache_path .. '/' .. f1 .. '/' .. f2

  self:mkdir(dir)

  local f, err = io.open(dir .. '/' .. key, "w")
  if not f then 
    return nil, err
    
  end

  f:write(content)
  f:flush()
  f:close()
  f = nil

  return true
end


function Cfs:get(key, content)
  local f1, f2 = string.sub(key, 1, 2), string.sub(key, 3, 4)
  local dir = self.cache_path .. '/' .. f1 .. '/' .. f2

  local f, err = io.open(dir .. '/' .. key, "rb")

  -- Error may:
  -- No such file or directory

  if not f then
    return nil, "request object not in cache"
  end

  local contents = f:read( "*a" )

  f:close()
  f = nil

  return contents, err
end

function Cfs:delete(key)
  local f1, f2 = string.sub(key, 1, 2), string.sub(key, 3, 4)
  local dir = self.cache_path .. '/' .. f1 .. '/' .. f2
  return os.remove(dir .. '/' .. key)
end



local _M = {}

--- Create new memory strategy object
-- @table opts Strategy options: contains 'dictionary_name' and 'ttl' fields
function _M.new(opts)
  local cfs = Cfs:new(opts)

  local self = {
    cfs = cfs,
    opts = opts,
  }

  return setmetatable(self, {
    __index = _M,
  })
end


--- Store a new request entity in the shared memory
-- @string key The request key
-- @table req_obj The request object, represented as a table containing
--   everything that needs to be cached
-- @int[opt] ttl The TTL for the request; if nil, use default TTL specified
--   at strategy instantiation time
function _M:store(key, req_obj, req_ttl)
  local ttl = req_ttl or self.opts.ttl

  if type(key) ~= "string" then
    return nil, "key must be a string"
  end

  -- encode request table representation as JSON
  local req_json = cjson.encode(req_obj)
  if not req_json then
    return nil, "could not encode request object"
  end

  local succ, err = self.cfs:set(key, req_json)
  return succ and req_json or nil, err
end


--- Fetch a cached request
-- @string key The request key
-- @return Table representing the request
function _M:fetch(key)
  if type(key) ~= "string" then
    return nil, "key must be a string"
  end

  -- retrieve object from shared dict
  local req_json, err = self.cfs:get(key)
  if not req_json then
    if not err then
      return nil, "request object not in cache"

    else
      return nil, err
    end
  end

  --   os.fs.stat('MyTempFile')


  -- decode object from JSON to table
  local req_obj = cjson.decode(req_json)
  if not req_json then
    return nil, "could not decode request object"
  end

  return req_obj
end


--- Purge an entry from the request cache
-- @return true on success, nil plus error message otherwise
function _M:purge(key)
  if type(key) ~= "string" then
    return nil, "key must be a string"
  end

  self.cfs:delete(key)
  return true
end


--- Reset TTL for a cached request
function _M:touch(key, req_ttl, timestamp)
  if type(key) ~= "string" then
    return nil, "key must be a string"
  end

  -- check if entry actually exists
  local req_json, err = self.cfs:get(key)
  if not req_json then
    if not err then
      return nil, "request object not in cache"

    else
      return nil, err
    end
  end

  -- decode object from JSON to table
  local req_obj = cjson.decode(req_json)
  if not req_json then
    return nil, "could not decode request object"
  end

  -- refresh timestamp field
  req_obj.timestamp = timestamp or time()

  -- store it again to reset the TTL
  return _M:store(key, req_obj, req_ttl)
end


--- Marks all entries as expired and remove them from the memory
-- @param free_mem Boolean indicating whether to free the memory; if false,
--   entries will only be marked as expired
-- @return true on success, nil plus error message otherwise
function _M:flush(free_mem)
  -- mark all items as expired
  -- self.dict:flush_all()
  -- flush items from memory
  --if free_mem then
  --  self.dict:flush_expired()
  --end

  return true
end

return _M
