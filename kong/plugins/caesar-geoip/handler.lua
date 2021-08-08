local inspect = require 'inspect'
-- local geoip_module = require 'geoip'
-- local geoip_country = require 'geoip.country'
local geoip = require "geoip.mmdb"

local geoip_country_filename = '/usr/share/GeoLite2-Country.mmdb'
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"
local BasePlugin  = require "kong.plugins.base_plugin"
local setmetatable = setmetatable

local current_ip = '1.1.1.1'

local CaesarGeoipHandler = BasePlugin:extend()


CaesarGeoipHandler.VERSION  = "0.0.2"
CaesarGeoipHandler.PRIORITY = 80




function CaesarGeoipHandler:init_worker()
  -- Implement logic for the init_worker phase here (http/stream)
  kong.log("init_worker: CaesarGeoipHandler!")

end

function CaesarGeoipHandler:new()
  kong.log("init_worker: CaesarGeoipHandler! create new db handler")
  local self = {
    db = geoip.load_database(geoip_country_filename)
  }

  return setmetatable(self, {
    __index = CaesarGeoipHandler,
  })
end


function CaesarGeoipHandler:access(conf)
  CaesarGeoipHandler.super.access(self)
end

function CaesarGeoipHandler:header_filter(conf)
  CaesarGeoipHandler.super.header_filter(self)
  local current_ip = ngx.var.remote_addr;
  local country_code, err = self.db:lookup_value(current_ip, "country", "iso_code"))

  for i,line in ipairs(conf.blacklist_countries) do
    if line == country_code then
      block = 1
    end
  end

  -- Unblocking ips in whitelist
  for i,line in ipairs(conf.whitelist_ips) do
    if line == current_ip then
      block = 0
    end
  end

  if block == 1 then 
    -- return ngx.exit(ngx.HTTP_ILLEGAL) 
    return responses.send_HTTP_FORBIDDEN()
  end
end


return CaesarGeoipHandler
