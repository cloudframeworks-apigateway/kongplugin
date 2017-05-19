local BasePlugin = require "kong.plugins.base_plugin"
local serializer_extend = require "kong.plugins.log2zmq.serializers"
local cjson = require "cjson"
local zmq = require "lzmq"
require "kong.plugins.log2zmq.zhelpers"

local CustomHandler = BasePlugin:extend()
CustomHandler.PRIORITY = 10001
local context, publisher, err
local service_id = os.getenv("SERVICE_ID") or ""
local fmt = string.format


-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function CustomHandler:new()
    CustomHandler.super.new(self, "log2zmq")
end

function CustomHandler:init_worker(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.init_worker(self)

    -- Implement any custom logic here

end

function CustomHandler:certificate(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.certificate(self)

    -- Implement any custom logic here
end

function CustomHandler:access(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.access(self)
    -- Implement any custom logic here
end

function CustomHandler:header_filter(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.header_filter(self)

    -- Implement any custom logic here
end

function CustomHandler:body_filter(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.body_filter(self)

    -- Implement any custom logic here
end

local function sendmessage(premature, config, message)
    if premature then
        return
    end

    local json_message = cjson.encode(message)
    ngx.log(ngx.ERR, json_message)
    if not context then
        context = zmq.context()
    end
    if not publisher then
        local bind_url = string.format("tcp://%s:%d", config.zmq_host, config.zmq_port)
        publisher, err = context:socket{zmq.PUB, connect = bind_url}
        zassert(publisher, err)
    end
    publisher:sendx(config.zmq_topic, json_message)
end


function CustomHandler:log(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.log(self)

    -- Implement any custom logic here
    local message = serializer_extend.serialize(ngx, service_id)
    local ok, err = ngx.timer.at(0, sendmessage, config, message)
    if not ok then
        ngx.log(ngx.ERR, "[tcp-log] failed to create timer: ", err)
    end
end

-- This module needs to return the created table, so that Kong
-- can execute those functions.
return CustomHandler


