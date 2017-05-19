--
-- Created by IntelliJ IDEA.
-- User: lucien
-- Date: 2016/11/18
-- Time: 16:12
-- To change this template use File | Settings | File Templates.
--


return {
    no_consumer = true, -- this plugin will only be API-wide,
    fields = {
        -- Describe your plugin's configuration's schema here.
        some_string = {type = "string", required = true},
        some_boolean = {type = "boolean", default = false},
        some_array = {type = "array", enum = {"GET", "POST", "PUT", "DELETE"}}
    },
    self_check = function(schema, plugin_t, dao, is_updating)
        -- perform any custom verification
        return true
    end
}

