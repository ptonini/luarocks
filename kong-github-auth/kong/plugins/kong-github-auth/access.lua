local decode_base64 = ngx.decode_base64
local re_gmatch = ngx.re.gmatch
local re_match = ngx.re.match
local kong = kong
local https = require ('ssl.https')
local http = require ("socket.http")
local ltn12 = require ("ltn12")
local json = require ("cjson.safe")


local _M = {}


local function HttpsWGet(strURL, headers, timeout)

    local result = {}
    local to = timeout or 60

    http.TIMEOUT = to

    local bdy,cde,hdrs,stts = https.request{
        url = strURL,
        method = "GET",
        headers = headers,
        protocol = "any",
        options =  {"all", "no_sslv2", "no_sslv3"},
        verify = "none",
        sink=ltn12.sink.table(result)
    }

    -- Mimick luup.inet.get return values
   if bdy == 1 then bdy = 0 else bdy = 1 end
   return table.concat(result),cde


end


local function retrieve_credentials(header_name, conf)
    local username, password
    local authorization_header = kong.request.get_header(header_name)

    if authorization_header then
        local iterator, iter_err = re_gmatch(authorization_header, "\\s*[Bb]asic\\s*(.+)")
        if not iterator then
            kong.log.err(iter_err)
            return
        end

        local m, err = iterator()
        if err then
            kong.log.err(err)
            return
        end

        if m and m[1] then
            local decoded_basic = decode_base64(m[1])
            if decoded_basic then
                local basic_parts, err = re_match(decoded_basic, "([^:]+):(.*)", "oj")
                if err then
                    kong.log.err(err)
                    return
                end

                if not basic_parts then
                    kong.log.err("header has unrecognized format")
                    return
                end

                username = basic_parts[1]
                password = basic_parts[2]

            end
        end
    end

    if conf.hide_credentials then
        kong.service.request.clear_header(header_name)
    end

    return username, password

end


local function fail_authentication()
    return false, { status = 401, message = "Invalid authentication credentials" }
end


local function do_authentication(conf)

    -- If both headers are missing, return 401
    if not (kong.request.get_header("authorization") or kong.request.get_header("proxy-authorization")) then
        return false, {
            status = 401,
            message = "Unauthorized",
            headers = {
                ["WWW-Authenticate"] = 'Basic realm="github/' .. conf.organization .. '"'
            }
        }
    end

    local given_username, given_password = retrieve_credentials("proxy-authorization", conf)
    if not given_username or not given_password then
        given_username, given_password = retrieve_credentials("authorization", conf)
    end

    if not given_username or not given_password then
        return fail_authentication()
    end

    local headers = {["Authorization"] = "token " .. given_password}
    local token_type = string.sub(given_password, 1, 3)

    if token_type == "ghp" then

        local response1, code1 = HttpsWGet(conf.github_api_addr .. "/user", headers)
        local response2, code2 = HttpsWGet(conf.github_api_addr .. "/orgs/" .. conf.organization .. "/members/" .. given_username, headers)

        if json.decode(response1)["login"] == given_username and code2 == 204 then
            return true
        end

    elseif token_type == "ghs" then

        if given_username == "x-access-token"  then
            local response, code = HttpsWGet(conf.github_api_addr .. "/orgs/" .. conf.organization, headers)
            if json.decode(response)['plan'] then
                return true
            end
        else
            local response, code = HttpsWGet(conf.github_api_addr .. "/repos/" .. conf.organization .. "/" .. given_username, headers)
            local r = json.decode(response)
            if r.private and r.owner.login == conf.organization then
                return true
            end
        end

    end

    return fail_authentication()

end


function _M.execute(conf)

    local ok, err = do_authentication(conf)
    if not ok then
        return kong.response.error(err.status, err.message, err.headers)
    end
end


return _M