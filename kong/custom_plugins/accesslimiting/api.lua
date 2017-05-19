--
-- Created by IntelliJ IDEA.
-- User: lucien
-- Date: 2016/11/18
-- Time: 16:13
-- To change this template use File | Settings | File Templates.
--

local crud = require "kong.api.crud_helpers"
local utils = require "kong.tools.utils"
local cjson = require "cjson"

return {
    ["/accesslimiting/"] = {
        GET = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(helpers))
        end,
        PUT = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(dao_factory))
        end,
        POST = function(self, dao_factory, helpers)
            -- 获取黑名单列表,一次添加一个
            ngx.log(ngx.ERR, cjson.encode(self))
        end
    },
    ["/accesslimiting/period"] = {
        GET = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(helpers))
        end,
        PUT = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(dao_factory))
        end,
        POST = function(self, dao_factory, helpers)
            -- 获取黑名单列表,一次添加一个
            ngx.log(ngx.ERR, cjson.encode(self))
        end
    },
    ["/accesslimiting/limit"] = {
        GET = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(helpers))
        end,
        PUT = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(dao_factory))
        end,
        POST = function(self, dao_factory, helpers)
            -- 获取黑名单列表,一次添加一个
            ngx.log(ngx.ERR, cjson.encode(self))
        end
    },
    ["/accesslimiting/blacklist"] = {
        GET = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(helpers))
        end,
        PUT = function(self, dao_factory, helpers)
            ngx.log(ngx.ERR, cjson.encode(dao_factory))
        end,
        POST = function(self, dao_factory, helpers)
            -- 获取黑名单列表,一次添加一个
            local remote_addr = self.params.ip
            local accesslimiting = dao_factory.accesslimiting
            local plugins, err = dao_factory.plugins:find_all {name = "accesslimiting"}
            if err then
                return helpers.responses.send_HTTP_NOT_FOUND("can not find apis")
            end

            for i = 1, #plugins do
                local plugin = plugins[i]
                local api_id = plugin.api_id
                local block, err = accesslimiting:check(api_id, remote_addr)
                if err then
                    ngx.log(ngx.ERR, cjson.encode(err))
                    return helpers.responses.send_HTTP_INTERNAL_SERVER_ERROR("server error!")
                end
                if block then
                    return helpers.responses.send_HTTP_OK("IP address is in black list")
                end

                local _, err = accesslimiting:insert(
                    accesslimiting.table_extend,
                    accesslimiting.schema,
                    {
                        api_id = api_id,
                        ip = remote_addr
                    })
                if err then
                    ngx.log(ngx.ERR, err)
                    return helpers.responses.send_HTTP_INTERNAL_SERVER_ERROR("server error!")
                end
            end
            helpers.responses.send_HTTP_CREATED("success!")
        end
    }
}
