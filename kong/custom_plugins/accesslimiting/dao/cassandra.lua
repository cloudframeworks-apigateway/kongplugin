local CassandraDB = require "kong.dao.cassandra_db"
local cassandra = require "cassandra"
local fmt = string.format
local _M = CassandraDB:extend()

_M.table = "accesslimiting_record"
_M.schema = require("kong.plugins.accesslimiting.schema")

function _M:count(api_id, ip, begin_time, end_time)
    local where = fmt("api_id = ? and ip = ? and created_at < ? and created_at > ?")
    local args = {
        api_id,
        ip,
        cassandra.timestamp(begin_time),
        cassandra.timestamp(end_time)
    }
    local query = _M.super:get_select_query(_M.table, where, "COUNT(*)")
    local res, err = self:query(query, args)
    if err then
        return nil, err
    elseif res and #res > 0 then
        return res[1].count
    end
end

return { accesslimiting = _M }

