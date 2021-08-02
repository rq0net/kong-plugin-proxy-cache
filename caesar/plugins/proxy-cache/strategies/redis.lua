local cjson = require "cjson.safe"
local redis = require "resty.redis"

local ngx          = ngx
local type         = type
local time         = ngx.time
local shared       = ngx.shared
local setmetatable = setmetatable



local _M = {}

--- Redis connection
local redis_connection = function(conf)
  local red = redis:new()
  local sock_opts = {}
  red:set_timeout(conf.redis_timeout)

  -- use a special pool name only if redis_database is set to non-zero
  -- otherwise use the default pool name host:port
  sock_opts.pool = conf.redis_database and
                   conf.redis_host .. ":" .. conf.redis_port ..
                   ":" .. conf.redis_database
  local ok, err = red:connect(conf.redis_host, conf.redis_port,
                              sock_opts)
  if not ok then
    kong.log.err("failed to connect to Redis: ", err)
    return nil, err
  end

  local times, err = red:get_reused_times()
  if err then
    kong.log.err("failed to get connect reused times: ", err)
    return nil, err
  end

  if times == 0 then
    if is_present(conf.redis_password) then
      local ok, err = red:auth(conf.redis_password)
      if not ok then
        kong.log.err("failed to auth Redis: ", err)
        return nil, err
      end
    end

    if conf.redis_database ~= 0 then
      -- Only call select first time, since we know the connection is shared
      -- between instances that use the same redis database

      local ok, err = red:select(conf.redis_database)
      if not ok then
        kong.log.err("failed to change Redis database: ", err)
        return nil, err
      end
    end
  end
  return red
end

--- Create new memory strategy object
-- @table opts Strategy options: contains 'dictionary_name' and 'ttl' fields
function _M.new(opts)
  local red = redis_connection(opts) -- shared[opts.dictionary_name]

  local self = {
    red = red,
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

  local succ, err = self.red:set(key, req_json, "EX", ttl)

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
  local req_json, err = self.red:get(key)
  if not req_json then
    if not err then
      return nil, "request object not in cache"

    else
      return nil, err
    end
  end

  -- decode object from JSON to table
  local req_obj = cjson.decode(req_json)
  if not req_obj then
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

  self.red:del(key)
  return true
end


--- Reset TTL for a cached request
function _M:touch(key, req_ttl, timestamp)
  if type(key) ~= "string" then
    return nil, "key must be a string"
  end

  -- check if entry actually exists
  local req_json, err = self.dict:get(key)
  if not req_json then
    if not err then
      return nil, "request object not in cache"

    else
      return nil, err
    end
  end

  local succ, err = self.red:expire(key, ttl)
  return true

end


--- Marks all entries as expired and remove them from the memory
-- @param free_mem Boolean indicating whether to free the memory; if false,
--   entries will only be marked as expired
-- @return true on success, nil plus error message otherwise
function _M:flush(free_mem)
  -- mark all items as expired
  self.red:flushdb()

  return true
end

return _M
