
local _M = {}

--[[
Start IP range function
]]
function _M.ip_address_in_range(input_ip, client_connecting_ip)
    if string.match(input_ip, "/") then --input ip is a subnet
        --do nothing
    else
        return
    end

    local ip_type = nil
    if string.match(input_ip, "%:") and string.match(client_connecting_ip, "%:") then --if both input and connecting ip are ipv6 addresses
        --ipv6
        ip_type = 1
    elseif string.match(input_ip, "%.") and string.match(client_connecting_ip, "%.") then --if both input and connecting ip are ipv4 addresses
        --ipv4
        ip_type = 2
    else
        return
    end
    if ip_type == nil then
        --input and connecting IP one is ipv4 and one is ipv6
        return
    end

    if ip_type == 1 then --ipv6

        local function explode(string, divide)
            if divide == '' then return false end
            local pos, arr = 0, {}
            local arr_table_length = 1
            --for each divider found
            for st, sp in function() return string.find(string, divide, pos, true) end do
                arr[arr_table_length] = string.sub(string, pos, st - 1 ) --attach chars left of current divider
                arr_table_length=arr_table_length+1
                pos = sp + 1 --jump past current divider
            end
                arr[arr_table_length] = string.sub(string, pos) -- Attach chars right of last divider
                arr_table_length=arr_table_length+1
            return arr
        end

        --[[
        Input IP
        ]]
        --validate actual ip
        local a, b, ip, mask = input_ip:find('([%w:]+)/(%d+)')

        --get ip bits
        local ipbits = explode(ip, ':')

        --now to build an expanded ip
        local zeroblock
        local ipbits_length = #ipbits
        for i=1,ipbits_length do
            local k = i
            local v = ipbits[i]
            --length 0? we're at the :: bit
            if v:len() == 0 then
                zeroblock = k

                --length not 0 but not 4, prepend 0's
            elseif v:len() < 4 then
                local padding = 4 - v:len()
                for i = 1, padding do
                    ipbits[k] = 0 .. ipbits[k]
                end
            end
        end
        if zeroblock and #ipbits < 8 then
            --remove zeroblock
            ipbits[zeroblock] = '0000'
            local padding = 8 - #ipbits

            for i = 1, padding do
                ipbits[zeroblock] = '0000'
                --ipbits_length=ipbits_length+1
            end
        end
        --[[
        End Input IP
        ]]

        --[[
        Client IP
        ]]
        --validate actual ip
        local a, b, clientip, mask_client = client_connecting_ip:find('([%w:]+)')

        --get ip bits
        local ipbits_client = explode(clientip, ':')

        --now to build an expanded ip
        local zeroblock_client
        local ipbits_client_length = #ipbits_client
        for i=1,ipbits_client_length do
            local k = i
            local v = ipbits_client[i]
            --length 0? we're at the :: bit
            if v:len() == 0 then
                zeroblock_client = k

                --length not 0 but not 4, prepend 0's
            elseif v:len() < 4 then
                local padding = 4 - v:len()
                for i = 1, padding do
                    ipbits_client[k] = 0 .. ipbits_client[k]
                end
            end
        end
        if zeroblock_client and #ipbits_client < 8 then
            --remove zeroblock
            ipbits_client[zeroblock_client] = '0000'
            local padding = 8 - #ipbits_client

            for i = 1, padding do
                ipbits_client[zeroblock_client] = '0000'
                --ipbits_client_length=ipbits_client_length+1
            end
        end
        --[[
        End Client IP
        ]]

        local expanded_ip_count = (ipbits[1] or "0000") .. ':' .. (ipbits[2] or "0000") .. ':' .. (ipbits[3] or "0000") .. ':' .. (ipbits[4] or "0000") .. ':' .. (ipbits[5] or "0000") .. ':' .. (ipbits[6] or "0000") .. ':' .. (ipbits[7] or "0000") .. ':' .. (ipbits[8] or "0000")
        expanded_ip_count = ngx.re.gsub(expanded_ip_count, ":", "", ngx_re_options)

        local client_connecting_ip_count = (ipbits_client[1] or "0000") .. ':' .. (ipbits_client[2] or "0000") .. ':' .. (ipbits_client[3] or "0000") .. ':' .. (ipbits_client[4] or "0000") .. ':' .. (ipbits_client[5] or "0000") .. ':' .. (ipbits_client[6] or "0000") .. ':' .. (ipbits_client[7] or "0000") .. ':' .. (ipbits_client[8] or "0000")
        client_connecting_ip_count = ngx.re.gsub(client_connecting_ip_count, ":", "", ngx_re_options)

        --generate wildcard from mask
        local indent = mask / 4

        expanded_ip_count = string.sub(expanded_ip_count, 0, indent)
        client_connecting_ip_count = string.sub(client_connecting_ip_count, 0, indent)

        local client_connecting_ip_expanded = ngx.re.gsub(client_connecting_ip_count, "....", "%1:", ngx_re_options)
        client_connecting_ip_expanded = ngx.re.gsub(client_connecting_ip_count, ":$", "", ngx_re_options)
        local expanded_ip = ngx.re.gsub(expanded_ip_count, "....", "%1:", ngx_re_options)
        expanded_ip = ngx.re.gsub(expanded_ip_count, ":$", "", ngx_re_options)

        local wildcardbits = {}
        local wildcardbits_table_length = 1
        for i = 0, indent - 1 do
            wildcardbits[wildcardbits_table_length] = 'f'
            wildcardbits_table_length=wildcardbits_table_length+1
        end
        for i = 0, 31 - indent do
            wildcardbits[wildcardbits_table_length] = '0'
            wildcardbits_table_length=wildcardbits_table_length+1
        end
        --convert into 8 string array each w/ 4 chars
        local count, index, wildcard = 1, 1, {}
        local wildcardbits_length = #wildcardbits
        for i=1,wildcardbits_length do
            local k = i
            local v = wildcardbits[i]
            if count > 4 then
                count = 1
                index = index + 1
            end
            if not wildcard[index] then wildcard[index] = '' end
            wildcard[index] = wildcard[index] .. v
            count = count + 1
        end

            --loop each letter in each ipbit group
            local topip = {}
            local bottomip = {}
            local ipbits_length = #ipbits
            for i=1,ipbits_length do
                local k = i
                local v = ipbits[i]
                local topbit = ''
                local bottombit = ''
                for i = 1, 4 do
                    local wild = wildcard[k]:sub(i, i)
                    local norm = v:sub(i, i)
                    if wild == 'f' then
                        topbit = topbit .. norm
                        bottombit = bottombit .. norm
                    else
                        topbit = topbit .. '0'
                        bottombit = bottombit .. 'f'
                    end
                end
                topip[k] = topbit
                bottomip[k] = bottombit
            end

        --count ips in mask
        local ipcount = math.pow(2, 128 - mask)

        if expanded_ip == client_connecting_ip_expanded then
            --print("ipv6 is in range")
            return true
        end

        --output
        --[[
        print()
        print('indent' .. indent)
        print('client_ip numeric : ' .. client_connecting_ip_count )
        print('input ip numeric : ' .. expanded_ip_count )
        print('client_ip : ' .. client_connecting_ip_expanded )
        print('input ip : ' .. expanded_ip )
        print()
        print( '###### INFO ######' )
        print( 'IP in: ' .. ip )
        print( '=> Expanded IP: ' .. (ipbits[1] or "0000") .. ':' .. (ipbits[2] or "0000") .. ':' .. (ipbits[3] or "0000") .. ':' .. (ipbits[4] or "0000") .. ':' .. (ipbits[5] or "0000") .. ':' .. (ipbits[6] or "0000") .. ':' .. (ipbits[7] or "0000") .. ':' .. (ipbits[8] or "0000") )
        print( 'Mask in: /' .. mask )
        print( '=> Mask Wildcard: ' .. (wildcard[1] or "0000") .. ':' .. (wildcard[2] or "0000") .. ':' .. (wildcard[3] or "0000") .. ':' .. (wildcard[4] or "0000") .. ':' .. (wildcard[5] or "0000") .. ':' .. (wildcard[6] or "0000") .. ':' .. (wildcard[7] or "0000") .. ':' .. (wildcard[8] or "0000") )
        print( '\n###### BLOCK ######' )
        print( '#IP\'s: ' .. ipcount )
        print( 'Range Start: ' .. (topip[1] or "0000") .. ':' .. (topip[2] or "0000") .. ':' .. (topip[3] or "0000") .. ':' .. (topip[4] or "0000") .. ':' .. (topip[5] or "0000") .. ':' .. (topip[6] or "0000") .. ':' .. (topip[7] or "0000") .. ':' .. (topip[8] or "0000") )
        print( 'Range End: ' .. (bottomip[1] or "ffff") .. ':' .. (bottomip[2] or "ffff") .. ':' .. (bottomip[3] or "ffff") .. ':' .. (bottomip[4] or "ffff") .. ':' .. (bottomip[5] or "ffff") .. ':' .. (bottomip[6] or "ffff") .. ':' .. (bottomip[7] or "ffff") .. ':' .. (bottomip[8] or "ffff") )
        ]]

    end

    if ip_type == 2 then --ipv4

        local a, b, ip1, ip2, ip3, ip4, mask = input_ip:find('(%d+).(%d+).(%d+).(%d+)/(%d+)')
        local ip = { tonumber( ip1 ), tonumber( ip2 ), tonumber( ip3 ), tonumber( ip4 ) }
        local a, b, client_ip1, client_ip2, client_ip3, client_ip4 = client_connecting_ip:find('(%d+).(%d+).(%d+).(%d+)')
        local client_ip = { tonumber( client_ip1 ), tonumber( client_ip2 ), tonumber( client_ip3 ), tonumber( client_ip4 ) }

        --list masks => wildcard
        local masks = {
            [1] = { 127, 255, 255, 255 },
            [2] = { 63, 255, 255, 255 },
            [3] = { 31, 255, 255, 255 },
            [4] = { 15, 255, 255, 255 },
            [5] = { 7, 255, 255, 255 },
            [6] = { 3, 255, 255, 255 },
            [7] = { 1, 255, 255, 255 },
            [8] = { 0, 255, 255, 255 },
            [9] = { 0, 127, 255, 255 },
            [10] = { 0, 63, 255, 255 },
            [11] = { 0, 31, 255, 255 },
            [12] = { 0, 15, 255, 255 },
            [13] = { 0, 7, 255, 255 },
            [14] = { 0, 3, 255, 255 },
            [15] = { 0, 1, 255, 255 },
            [16] = { 0, 0, 255, 255 },
            [17] = { 0, 0, 127, 255 },
            [18] = { 0, 0, 63, 255 },
            [19] = { 0, 0, 31, 255 },
            [20] = { 0, 0, 15, 255 },
            [21] = { 0, 0, 7, 255 },
            [22] = { 0, 0, 3, 255 },
            [23] = { 0, 0, 1, 255 },
            [24] = { 0, 0, 0, 255 },
            [25] = { 0, 0, 0, 127 },
            [26] = { 0, 0, 0, 63 },
            [27] = { 0, 0, 0, 31 },
            [28] = { 0, 0, 0, 15 },
            [29] = { 0, 0, 0, 7 },
            [30] = { 0, 0, 0, 3 },
            [31] = { 0, 0, 0, 1 }
        }

        --get wildcard
        local wildcard = masks[tonumber( mask )]

        --number of ips in mask
        local ipcount = math.pow(2, ( 32 - mask ))

        --network IP (route/bottom IP)
        local bottomip = {}
        local ip_length = #ip
        for i=1,ip_length do
            local k = i
            local v = ip[i]
            --wildcard = 0?
            if wildcard[k] == 0 then
                bottomip[k] = v
            elseif wildcard[k] == 255 then
                bottomip[k] = 0
            else
                local mod = v % (wildcard[k] + 1)
                bottomip[k] = v - mod
            end
        end

        --use network ip + wildcard to get top ip
        local topip = {}
        local bottomip_length = #bottomip
        for i=1,bottomip_length do
            local k = i
            local v = bottomip[i]
            topip[k] = v + wildcard[k]
        end

        --is input ip = network ip?
        local isnetworkip = ( ip[1] == bottomip[1] and ip[2] == bottomip[2] and ip[3] == bottomip[3] and ip[4] == bottomip[4] )
        local isbroadcastip = ( ip[1] == topip[1] and ip[2] == topip[2] and ip[3] == topip[3] and ip[4] == topip[4] )

        local ip1 = tostring(ip1)
        local ip2 = tostring(ip2)
        local ip3 = tostring(ip3)
        local ip4 = tostring(ip4)
        local client_ip1 = tostring(client_ip1)
        local client_ip2 = tostring(client_ip2)
        local client_ip3 = tostring(client_ip3)
        local client_ip4 = tostring(client_ip4)
        local in_range_low_end1 = tostring(bottomip[1])
        local in_range_low_end2 = tostring(bottomip[2])
        local in_range_low_end3 = tostring(bottomip[3])
        local in_range_low_end4 = tostring(bottomip[4])
        local in_range_top_end1 = tostring(topip[1])
        local in_range_top_end2 = tostring(topip[2])
        local in_range_top_end3 = tostring(topip[3])
        local in_range_top_end4 = tostring(topip[4])

        if tonumber(mask) == 1 then --127, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 2 then --63, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 3 then --31, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 4 then --15, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 5 then --7, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 6 then --3, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 7 then --1, 255, 255, 255
            if client_ip1 >= in_range_low_end1 --in range low end
            and client_ip1 <= in_range_top_end1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 8 then --0, 255, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 9 then --0, 127, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 10 then --0, 63, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 11 then --0, 31, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 12 then --0, 15, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 13 then --0, 7, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 14 then --0, 3, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 15 then --0, 1, 255, 255
            if ip1 == client_ip1 
            and client_ip2 >= in_range_low_end2 --in range low end
            and client_ip2 <= in_range_top_end2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 16 then --0, 0, 255, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 17 then --0, 0, 127, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 18 then --0, 0, 63, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 19 then --0, 0, 31, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 20 then --0, 0, 15, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 21 then --0, 0, 7, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 22 then --0, 0, 3, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 23 then --0, 0, 1, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and client_ip3 >= in_range_low_end3 --in range low end
            and client_ip3 <= in_range_top_end3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 24 then --0, 0, 0, 255
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 25 then --0, 0, 0, 127
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 26 then --0, 0, 0, 63
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 27 then --0, 0, 0, 31
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 28 then --0, 0, 0, 15
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 29 then --0, 0, 0, 7
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 30 then --0, 0, 0, 3
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end
        if tonumber(mask) == 31 then --0, 0, 0, 1
            if ip1 == client_ip1 
            and ip2 == client_ip2 
            and ip3 == client_ip3 
            and client_ip4 >= in_range_low_end4 --in range low end
            and client_ip4 <= in_range_top_end4 then --in range top end
                return true
            end
        end

        --output
        --[[
        print()
        print( '###### INFO ######' )
        print( 'IP in: ' .. ip[1] .. '.' .. ip[2] .. '.' .. ip[3] .. '.' .. ip[4]  )
        print( 'Mask in: /' .. mask )
        print( '=> Mask Wildcard: ' .. wildcard[1] .. '.' .. wildcard[2] .. '.' .. wildcard[3] .. '.' .. wildcard[4]  )
        print( '=> in IP is network-ip: ' .. tostring( isnetworkip ) )
        print( '=> in IP is broadcast-ip: ' .. tostring( isbroadcastip ) )
        print( '\n###### BLOCK ######' )
        print( '#IP\'s: ' .. ipcount )
        print( 'Bottom/Network: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] .. '/' .. mask )
        print( 'Top/Broadcast: ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] )
        print( 'Subnet Range: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] .. ' - ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] )
        print( 'Host Range: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] + 1 .. ' - ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] - 1 )
        ]]

    end

end
--[[
usage
if ip_address_in_range("255.255.0.0/17", ngx.var.remote_addr) == true then --ipv4
    print("IPv4 in range")
end
if ip_address_in_range("2a02:0c68::/29", ngx.var.remote_addr) == true then --ipv6
    print("IPv6 in range")
end
]]
--[[
End IP range function
]]




local function check_user_agent_blacklist(http_user_agent, user_agent_needle)
    local a1, a2 = string.lower(http_user_agent), string.lower(user_agent_needle)
    return string.match(http_user_agent, user_agent_needle)
end
-- check_user_agent_blacklist(user_agent_blacklist_var, user_agent_blacklist_table) --run user agent blacklist check function


return _M