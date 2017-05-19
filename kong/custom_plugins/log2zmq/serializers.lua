--
-- Created by IntelliJ IDEA.
-- User: lucien
-- Date: 2016/12/8
-- Time: 10:26
-- To change this template use File | Settings | File Templates.
--

local _M = {}
local cjson = require "cjson"

function _M.serialize(ngx, service_id)
    local authenticated_entity
    if ngx.ctx.authenticated_credential ~= nil then
        authenticated_entity = {
            id = ngx.ctx.authenticated_credential.id,
            consumer_id = ngx.ctx.authenticated_credential.consumer_id
        }
    end

    local api = ngx.ctx.api
    local req_headers = ngx.req.get_headers()

    return {
        topic = "weblog",
        service_id = service_id,
        started_at = ngx.req.start_time() * 1000,
        ended_at = ngx.now(),
        client_ip = ngx.var.remote_addr,

        request_method = ngx.req.get_method(),
        request_uri = ngx.var.request_uri,
        request_size = ngx.var.request_length,
        request_request_uri = ngx.var.scheme.."://"..ngx.var.host..":"..ngx.var.server_port..ngx.var.request_uri,
        request_querystring = cjson.encode(ngx.req.get_uri_args()),
--        request_headers = ngx.req.get_headers(),
        request_headers_cookie = req_headers.cookie or "",

        response_status = ngx.status,
        response_size = ngx.var.bytes_sent,
--        response_headers = ngx.resp.get_headers(),

        latencies_kong = (ngx.ctx.KONG_ACCESS_TIME or 0) + (ngx.ctx.KONG_RECEIVE_TIME or 0),
        latencies_proxy = ngx.ctx.KONG_WAITING_TIME or -1,
        latencies_request = ngx.var.request_time * 1000,

--        authenticated_entity = authenticated_entity,
--        api = ngx.ctx.api,
        api_upstream_url = api.upstream_url,
        api_created_at = api.created_at,
        api_id = api.id,
        api_name = api.name,
        api_request_host = api.request_host,
    }
end

return _M

