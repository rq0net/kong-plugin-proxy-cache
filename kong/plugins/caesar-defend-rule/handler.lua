---
-- curl -X POST http://kong:8001/services/<service-name-or-id>/plugins \
--    -d "name=my-custom-plugin" \
--    -d "config.environment=development" \
--    -d "config.server.host=http://localhost"
---

local require     = require
local kong        = kong
local ngx         = ngx
local BasePlugin  = require "kong.plugins.base_plugin"
local utils       = require "kong.tools.utils"
local utils2      = require "kong.plugins.caesar-challenge.utils"
local split        = utils.split



local _plugin = BasePlugin:extend()

_plugin.VERSION  = "0.0.1"
_plugin.PRIORITY = 80


local function auto_remote_addr()
  local remote_addr = ""
  if ngx.var.http_cf_connecting_ip ~= nil then
    remote_addr = ngx.var.http_cf_connecting_ip
  elseif ngx.var.http_x_forwarded_for ~= nil then
    remote_addr = ngx.var.http_x_forwarded_for
  else
    remote_addr = ngx.var.remote_addr
  end
  return remote_addr
end


function _plugin:init_worker()
  -- Implement logic for the init_worker phase here (http/stream)
  kong.log("init_worker: CaesarHelloHandler!")
end


function _plugin:do_action(rule)
  if rule.action_code == ngx.HTTP_OK then
    local output = ngx.exit(ngx.OK) --Go to content
    return output
  elseif rule.action_code == ngx.HTTP_MOVED_TEMPORARILY then
    local replace_map = {
      { "{host}", ngx.var.host },
      { "{query}", kong.request.get_raw_query() },
      { "{request_uri}", ngx.var.request_uri },
    }
    local target_url = rule.action_value
    local replace_map_length = #replace_map
    for i=1,replace_map_length do --for each host in our table
      local v = replace_map[i]
      target_url = string.gsub( target_url,v[1],v[2] )
    end
    return ngx.redirect(target_url, rule.action_code)  --redirect
  else
    local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
    return output
  end
end


function _plugin:access(conf)
  _plugin.super.access(self)

  local rule_list = conf.rules

  local rule_list_length = #rule_list
    for i=1,rule_list_length do
      local rule = rule_list[i]
      if rule.condition == "IP" then
        local ip = auto_remote_addr
        if utils2.ip_address_in_range(rule.match_needle, ip) == true then
          local output = self.do_action(rule)
          return output
        end
      elseif rule.condition == "User-Agent" then
        local user_agent = ngx.var.http_user_agent
        if utils2.check_user_agent(user_agent, rule.match_needle) then
          local output = self.do_action(rule)
          return output
        end
      elseif rule.condition == "URI" then
        local request_uri = ngx.var.request_uri --request uri is full URL link including query strings and arguements

        if string.match(request_uri, rule.match_needle) then --if our host matches one in the table
          local output = self.do_action(rule)
          return output
        end
      elseif rule.condition == "Header" then
        local argument_request_headers = ngx.req.get_headers() --get our client request headers and put them into a table
        local argument_name, argument_value  = split(rule.match_needle, ':')

        if next(argument_request_headers) ~= nil then --Check Header args table has contents 
          for key, value in next, argument_request_headers do
            local args_name = tostring(key) or "" --variable to store Header data argument name
            local args_value = tostring(ngx.req.get_headers()[args_name]) or ""
            local m1, m2 = nil, nil
            if string.match(args_name, argument_name) then --if the argument name in my table matches the one in the request
              m1 = 1
            end
            if string.match(args_value, argument_value) then --if the argument value in my table matches the one the request
              m2 = 1
            end
            if m1 and m2 then --if what would of been our empty vars have been changed to not empty meaning a WAF match then block the request
              local output = self.do_action(rule)
              return output
            end
          end
        end
      end
    end
    return -- no rule matched
end

return _plugin
