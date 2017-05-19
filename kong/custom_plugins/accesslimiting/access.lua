local timestamp = require "kong.tools.timestamp"
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"
local cjson = require "cjson"

local _M = {}

function _M.execute(config)
    --1、获取访问的ip地址
    local remote_addr = ngx.var.remote_addr
    if not remote_addr then
        return responses.send_HTTP_FORBIDDEN("Cannot identify the client IP address, unix domain sockets are not supported.")
    end
    -- api_id
    local api_id = ngx.ctx.api.id

    --2、检查ip地址是否在黑名单内,使用的是
    local block, err = singletons.dao.accesslimiting:check(api_id, remote_addr)
    if err then
        ngx.log(ngx.ERR, cjson.encode(err))
    end
    if block then
        return responses.send_HTTP_FORBIDDEN("Your IP address is not allowed")
    end
    --3、检查ip地址在过去n分钟内的访问次数
    local current_time = timestamp.get_utc()
    local previous_time = current_time - config.period * 6000

    local period_count, err = singletons.dao.accesslimiting:count(api_id, remote_addr, previous_time, current_time)
    if err then
        ngx.log(ngx.ERR, cjson.encode(err))
    end
    if period_count > config.limit then
        return responses.send_HTTP_FORBIDDEN("Your request is too frequent.pls wait a minute")
    end
    --4、添加访问记录
    local accesslimiting = singletons.dao.accesslimiting
    accesslimiting:insert(
        accesslimiting.table,
        accesslimiting.schema,
        {
            api_id = api_id,
            ip = remote_addr
        })
end

-- blacklist
function _M.add_blacklist(config, dao)

end



return _M

