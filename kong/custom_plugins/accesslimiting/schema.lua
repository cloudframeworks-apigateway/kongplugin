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
        period = {type = "number", required = true, default=1},
        limit = {type = "number", default = true, default=5}
    },
    self_check = function(schema, plugin_t, dao, is_updating)
        -- perform any custom verification
        local period = plugin_t.period
        local limit = plugin_t.limit
        if not string.find(period, "^%d+$") then
            return false, Errors.schema "period must be digit"
        end
        if not string.find(limit, "^%d+$") then
            return false, Errors.schema "limit must be digit"
        end
        return true
    end
}

