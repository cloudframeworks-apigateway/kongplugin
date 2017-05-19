--
-- Created by IntelliJ IDEA.
-- User: lucien
-- Date: 2016/11/18
-- Time: 16:12
-- To change this template use File | Settings | File Templates.
--

local Errors = require "kong.dao.errors"
local SUB_HOST = os.getenv("SUB_HOST") or "127.0.0.1"
local SUB_PORT = os.getenv("SUB_PORT") or 9001
return {
    no_consumer = true, -- this plugin will only be API-wide,
    fields = {
        -- Describe your plugin's configuration's schema here.
        zmq_host = {type = "string", required = true, default=SUB_HOST},
        zmq_port = {type = "number", required = true, default=SUB_PORT},
        zmq_topic = {type = "string", required = false, default="weblog"},
    },
    self_check = function(schema, plugin_t, dao, is_updating)
        -- perform any custom verification
        local zmq_host = plugin_t.zmq_host
        local zmq_port = plugin_t.zmq_port
        if not string.find(zmq_host, "^%d+.%d+.%d+.%d+$") then
            return false, Errors.schema "zmq host must be ip"
        end
        if zmq_port < 1 then
            return false, Errors.schema "zmq port must be port"
        end
        return true
    end
}

