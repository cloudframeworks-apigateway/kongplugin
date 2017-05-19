local events = require "kong.core.events"

--    if message_t.collection == "oauth2_credentials" then

return {
    [events.TYPES.ENTITY_UPDATED] = function(message_t)
        ngx.log(ngx.ERR, "updated")
    end,
    [events.TYPES.ENTITY_DELETED] = function(message_t)
        ngx.log(ngx.ERR, "deleted")
    end,
    [events.TYPES.ENTITY_CREATED] = function(message_t)
        ngx.log(ngx.ERR, "created")
    end,
    [events.TYPES["MEMBER-JOIN"]] = function(message_t)
        ngx.log(ngx.ERR, "JOIN")
    end,
    [events.TYPES["MEMBER-LEAVE"]] = function(message_t)
        ngx.log(ngx.ERR, "LEAVE")
    end,
    [events.TYPES["MEMBER-FAILED"]] = function(message_t)
        ngx.log(ngx.ERR, "FAILED")
    end,
    [events.TYPES["MEMBER-UPDATE"]] = function(message_t)
        ngx.log(ngx.ERR, "UPDATE")
    end,
    [events.TYPES["MEMBER-REAP"]] = function(message_t)
        ngx.log(ngx.ERR, "REAP")
    end
}
