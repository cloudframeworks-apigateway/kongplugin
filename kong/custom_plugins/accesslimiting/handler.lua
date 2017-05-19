-- Extending the Base Plugin handler is optional, as there is no real
-- concept of interface in Lua, but the Base Plugin handler's methods
-- can be called from your child implementation and will print logs
-- in your `error.log` file (where all logs are printed).
local BasePlugin = require "kong.plugins.base_plugin"

--local iputils = require "resty.iputils"
local access = require "kong.plugins.accesslimiting.access"

local CustomHandler = BasePlugin:extend()
CustomHandler.PRIORITY = 10002

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function CustomHandler:new()
    CustomHandler.super.new(self, "accesslimiting")
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
    access.execute(config)
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

function CustomHandler:log(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.log(self)

    -- Implement any custom logic here
end

-- This module needs to return the created table, so that Kong
-- can execute those functions.
return CustomHandler


