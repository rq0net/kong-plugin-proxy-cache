
--[[
Introduction and details :

Copyright Conor McKnight

https://github.com/C0nw0nk/Nginx-Lua-Anti-DDoS

Information :
My name is Conor McKnight I am a developer of Lua, PHP, HTML, Javascript, MySQL, Visual Basics and various other languages over the years.
This script was my soloution to check web traffic comming into webservers to authenticate that the inbound traffic is a legitimate browser and request,
It was to help the main internet structure aswell as every form of webserver that sends traffic by HTTP(S) protect themselves from the DoS / DDoS (Distributed Denial of Service) antics of the internet.

If you have any bugs issues or problems just post a Issue request. https://github.com/C0nw0nk/Nginx-Lua-Anti-DDoS/issues

If you fork or make any changes to improve this or fix problems please do make a pull request for the community who also use this. https://github.com/C0nw0nk/Nginx-Lua-Anti-DDoS/pulls


Disclaimer :
I am not responsible for what you do with this script nor liable,
This script was released under default Copyright Law as a proof of concept.
For those who want to know what that means for your use of this script read the following : http://choosealicense.com/no-license/

Legal Usage :
For those who wish to use this in production you should contact me to purchase a private license to use this legally.
For those who wish to use this in a commerical enviorment contact me to come to an agreement and purchase a commerical usage license.
For those who wish to purchase the rights to this from me contact me also to discuss pricing and terms and come to a sensible agreement.

Contact : (You can also contact me via github)
https://www.facebook.com/C0nw0nk

]]

--[[
Configuration :
]]

--[[
localize all standard Lua and Spring API functions I use for better performance.
]]
local os = os
local string = string
local math = math
local table = table
local tonumber = tonumber
local tostring = tostring
local next = next
--[[
End localization
]]

--[[
Shared memory cache

If you use this make sure you add this to your nginx configuration

http { #inside http block
     lua_shared_dict antiddos 10m; #Anti-DDoS shared memory zone
}

]]
--local shared_memory = ngx.shared.antiddos --What ever memory space your server has set / defined for this to use

--[[
This is a password that encrypts our puzzle and cookies unique to your sites and servers you should change this from the default.
]]
local secret = " enigma" --Signature secret key --CHANGE ME FROM DEFAULT!

--[[
Unique id to identify each individual user and machine trying to access your website IP address works well.

ngx.var.http_cf_connecting_ip --If you proxy your traffic through cloudflare use this
ngx.var.http_x_forwarded_for --If your traffic is proxied through another server / service.
ngx.var.remote_addr --Users IP address
ngx.var.binary_remote_addr --Users IP address in binary
ngx.var.http_user_agent --use this to protect Tor servers from DDoS

You can combine multiple if you like. You can do so like this.
local remote_addr = ngx.var.remote_addr .. ngx.var.http_user_agent

remote_addr = "tor" this will mean this script will be functioning for tor users only
remote_addr = "auto" the script will automatically get the clients IP this is the default it is the smartest and most compatible method with every service proxy etc
]]
local remote_addr = "auto" --Default Automatically get the Clients IP address

--[[
How long when a users request is authenticated will they be allowed to browse and access the site until they will see the auth page again.

The time is expressed in seconds.
None : 0 (This would result in every page and request showing the auth before granting access) --DO NOT SET AS 0 I recommend nothing less than 30 seconds.
One minute: 60
One hour: 3600
One day: 86400
One week: 604800
One month: 2628000
One year: 31536000
Ten years: 315360000
]]
local expire_time = 86400 --One day

--[[
The type of javascript based pingback authentication method to use if it should be GET or POST or can switch between both making it as dynamic as possible.
1 = GET
2 = POST
3 = DYNAMIC
]]
local javascript_REQUEST_TYPE = 2 --Default 2

--[[
Timer to refresh auth page
Time is in seconds only.
]]
local refresh_auth = 5


--[[
Javascript variable checks
These custom javascript checks are to prevent our authentication javascript puzzle / question being solved by the browser if the browser is a fake ghost browser / bot etc.
Only if the web browser does not trigger any of these or does not match conditions defined will the browser solve the authentication request.
]]
local JavascriptVars_opening = [[
if(!window._phantom || !window.callPhantom){/*phantomjs*/
if(!window.__phantomas){/*phantomas PhantomJS-based web perf metrics + monitoring tool*/
if(!window.Buffer){/*nodejs*/
if(!window.emit){/*couchjs*/
if(!window.spawn){/*rhino*/
if(!window.webdriver){/*selenium*/
if(!window.domAutomation || !window.domAutomationController){/*chromium based automation driver*/
if(!window.document.documentElement.getAttribute("webdriver")){
/*if(navigator.userAgent){*/
if(!/bot|curl|kodi|xbmc|wget|urllib|python|winhttp|httrack|alexa|ia_archiver|facebook|twitter|linkedin|pingdom/i.test(navigator.userAgent)){
/*if(navigator.cookieEnabled){*/
/*if(document.cookie.match(/^(?:.*;)?\s*[0-9a-f]{32}\s*=\s*([^;]+)(?:.*)?$/)){*//*HttpOnly Cookie flags prevent this*/
]]

--[[
Javascript variable blacklist
]]
local JavascriptVars_closing = [[
/*}*/
/*}*/
}
/*}*/
}
}
}
}
}
}
}
}
]]


--[[
Javascript Puzzle for web browser to solve do not touch this unless you understand Javascript, HTML and Lua
]]
--Simple static Javascript puzzle where every request all year round the question and answer would be the same pretty predictable for bots.
--local JavascriptPuzzleVars = [[22 + 22]] --44
--local JavascriptPuzzleVars_answer = "44" --if this does not equal the equation above you will find access to your site will be blocked make sure you can do maths!?

--Make our Javascript puzzle a little bit more dynamic than the static equation above it will change every 24 hours :) I made this because the static one is pretty poor security compared to this but this can be improved allot though.
--TODO: IMPROVE THIS!
local JavascriptPuzzleVars = [[parseInt("]] .. os.date("%Y%m%d",os.time()-24*60*60) .. [[", 10) + parseInt("]] .. os.date("%d%m%Y",os.time()-24*60*60) ..[[", 10)]] --Javascript output of our two random numbers
local JavascriptPuzzleVars_answer = os.date("%Y%m%d",os.time()-24*60*60) + os.date("%d%m%Y",os.time()-24*60*60) --lua output of our two random numbers
local JavascriptPuzzleVars_answer = math.floor(JavascriptPuzzleVars_answer+0.5) --fix bug removing the 0. decimal on the end of the figure
local JavascriptPuzzleVars_answer = tostring(JavascriptPuzzleVars_answer) --convert the numeric output to a string

--[[
X-Auth-Header to be static or Dynamic setting this as dynamic is the best form of security
1 = Static
2 = Dynamic
]]
local x_auth_header = 2 --Default 2
local x_auth_header_name = "x-auth-answer" --the header our server will expect the client to send us with the javascript answer this will change if you set the config as dynamic

--[[
Cookie Anti-DDos names
]]
local challenge = "__uip" --this is the first main unique identification of our cookie name
local cookie_name_start_date = challenge.."_start_date" --our cookie start date name of our firewall
local cookie_name_end_date = challenge.."_end_date" --our cookie end date name of our firewall
local cookie_name_encrypted_start_and_end_date = challenge.."_combination" --our cookie challenge unique id name

--[[
Anti-DDoS Cookies to be Encrypted for better security
1 = Cookie names will be plain text above
2 = Encrypted cookie names unique to each individual client/user
]]
local encrypt_anti_ddos_cookies = 2 --Default 2

--[[
Encrypt/Obfuscate Javascript output to prevent content scrappers and bots decrypting it to try and bypass the browser auth checks. Wouldn't want to make life to easy for them now would I.
0 = Random Encryption Best form of security and default
1 = No encryption / Obfuscation
2 = Base64 Data URI only
3 = Hex encryption
4 = Base64 Javascript Encryption
5 = Conor Mcknight's Javascript Scrambler (Obfuscate Javascript by putting it into vars and shuffling them like a deck of cards)
]]
local encrypt_javascript_output = 0

--[[
IP Address Whitelist
Any IP Addresses specified here will be whitelisted to grant direct access to your site bypassing our firewall checks
you can specify IP's like search engine crawler ip addresses here most search engines are smart enough they do not need to be specified,
Major search engines can execute javascript such as Google, Yandex, Bing, Baidu and such so they can solve the auth page puzzle and index your site same as how companies like Cloudflare, Succuri, BitMitigate etc work and your site is still indexed.
Supports IPv4 and IPv6 addresses aswell as subnet ranges
To find all IP ranges of an ASN use : https://www.enjen.net/asn-blocklist/index.php?asn=16509&type=iplist
]]
local ip_whitelist_remote_addr = "auto" --Automatically get the Clients IP address
local ip_whitelist = {
--"127.0.0.1", --localhost
--"192.168.0.1", --localhost
}


--[[
IP Address Blacklist
To block access to any abusive IP's that you do not want to ever access your website
Supports IPv4 and IPv6 addresses aswell as subnet ranges
To find all IP ranges of an ASN use : https://www.enjen.net/asn-blocklist/index.php?asn=16276&type=iplist
For the worst Botnet ASN IP's see here : https://www.spamhaus.org/statistics/botnet-asn/ You can add their IP addresses. https://www.abuseat.org/public/asninfections.html
]]
local ip_blacklist_remote_addr = "auto" --Automatically get the Clients IP address
local ip_blacklist = {
--"127.0.0.1/30", --localhost
--"192.168.0.1", --localhost
--ASN AS16276 OVH IP ranges Block all OVH Servers
"107.189.64.0/18","91.90.92.0/24","198.245.48.0/20","185.243.16.0/24","217.182.0.0/16","51.79.128.0/17","103.5.12.0/22","198.27.64.0/18","46.105.200.0/24","51.79.0.0/17","2607:5300::/32","144.217.0.0/16","46.244.32.0/20","46.105.201.0/24","46.105.198.0/24","54.39.0.0/16","46.105.203.0/24","51.81.128.0/17","46.105.0.0/16","51.178.0.0/16","167.114.128.0/18","91.90.88.0/24","8.7.244.0/24","139.99.128.0/17","144.2.32.0/19","51.38.0.0/16","91.90.94.0/24","8.33.128.0/21","8.21.41.0/24","216.32.194.0/24","51.89.0.0/16","5.196.0.0/16","195.110.30.0/23","51.195.0.0/16","2001:41d0::/32","91.90.93.0/24","8.29.224.0/24","167.114.192.0/19","8.24.8.0/21","91.90.90.0/24","167.114.0.0/17","91.121.0.0/16","51.91.0.0/16","139.99.0.0/17","178.32.0.0/15","8.26.94.0/24","51.77.0.0/16","91.90.89.0/24","185.228.97.0/24","151.80.0.0/16","213.251.128.0/18","149.56.0.0/16","37.59.0.0/16","213.186.32.0/19","2402:1f00::/32","193.70.0.0/17","142.44.128.0/17","51.161.0.0/17","54.38.0.0/16","185.228.98.0/24","91.90.88.0/21","216.32.220.0/24","92.222.0.0/16","147.135.128.0/17","142.4.192.0/19","5.135.0.0/16","192.95.0.0/18","46.105.202.0/24","185.12.32.0/23","145.239.0.0/16","213.32.0.0/17","37.187.0.0/16","37.60.48.0/21","198.100.144.0/20","149.202.0.0/16","94.23.0.0/16","167.114.224.0/19","193.109.63.0/24","51.254.0.0/15","91.90.91.0/24","216.32.213.0/24","216.32.218.0/24","8.33.96.0/21","5.39.0.0/17","185.228.96.0/24","164.132.0.0/16","158.69.0.0/16","46.105.199.0/24","8.30.208.0/21","54.37.0.0/16","46.105.204.0/24","2402:1f00:8100::/40","87.98.128.0/17","51.68.0.0/16","37.60.56.0/21","8.20.110.0/24","51.83.0.0/16","185.45.160.0/22","216.32.192.0/24","198.50.128.0/17","205.218.49.0/24","216.32.216.0/24","51.75.0.0/16","195.246.232.0/23","91.90.95.0/24","51.81.0.0/17","2402:1f00:8000::/40","23.92.224.0/19","192.240.152.0/21","91.134.0.0/16","92.246.224.0/19","176.31.0.0/16","79.137.0.0/17","193.104.19.0/24","137.74.0.0/16","192.99.0.0/16","198.27.92.0/24","147.135.0.0/17","8.33.136.0/24","2604:2dc0::/32","8.33.137.0/24","188.165.0.0/16","66.70.128.0/17","8.18.172.0/24","185.228.99.0/24","54.36.0.0/16","8.18.128.0/24",
--ASN AS12876 ONLINE S.A.S. IP ranges
"62.4.0.0/19","151.115.0.0/18","51.15.0.0/17","163.172.208.0/20","212.129.0.0/18","2001:bc8::/32","212.83.160.0/19","212.47.224.0/19","2001:bc8:1c00::/38","51.158.128.0/17","163.172.0.0/16","212.83.128.0/19","51.158.0.0/15","195.154.0.0/16","51.15.0.0/16","62.210.0.0/16",
}

--[[
Allow or block all Tor users
1 = Allow
2 = block
]]
local tor = 1 --Allow Tor Users

--[[
Unique ID to identify each individual Tor user who connects to the website
Using their User-Agent as a static variable to latch onto works well.
ngx.var.http_user_agent --Default
]]
local tor_remote_addr = ngx.var.http_user_agent

--[[
X-Tor-Header to be static or Dynamic setting this as dynamic is the best form of security
1 = Static
2 = Dynamic
]]
local x_tor_header = 2 --Default 2
local x_tor_header_name = "x-tor" --tor header name
local x_tor_header_name_allowed = "true" --tor header value when we want to allow access
local x_tor_header_name_blocked = "blocked" --tor header value when we want to block access

