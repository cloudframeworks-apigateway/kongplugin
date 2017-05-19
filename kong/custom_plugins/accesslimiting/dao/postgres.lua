local PostgresDB = require "kong.dao.postgres_db"
local fmt = string.format
local timestamp = require "kong.tools.timestamp"

--local timestamp = require "kong.tools.timestamp"
--local concat = table.concat

local _M = PostgresDB:extend()

_M.table = "accesslimiting_record"
_M.table_extend = "accesslimiting_blacklist"
_M.schema = require("kong.plugins.accesslimiting.schema")

function _M:count(api_id, ip, begin_time, end_time)
    --return _M.super.count(self, _M.table, nil, _M.schema)
    local btime = os.date("!%Y-%m-%d %H:%M:%S", begin_time/1000)
    local etime = os.date("!%Y-%m-%d %H:%M:%S", end_time/1000)
    local where = fmt("api_id = '%s' and ip = '%s' and created_at <= '%s' and created_at >= '%s'", api_id, ip, etime, btime)
    local query = _M.super:get_select_query("COUNT(*)", _M.schema, _M.table, where)
    local res, err = self:query(query)
    if err then
        return nil, err
    elseif res and #res > 0 then
        return res[1].count
    end
end

function _M:check(api_id, ip)
    local where = fmt("api_id = '%s' and ip = '%s'", api_id, ip)
    local query = _M.super:get_select_query("COUNT(*)", _M.schema, _M.table_extend, where)
    local res, err = self:query(query)
    if err then
        return false, err
    elseif res and #res > 0 then
        return true, nil
    end
end


return { accesslimiting = _M }
