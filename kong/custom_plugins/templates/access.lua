--
-- Created by IntelliJ IDEA.
-- User: lucien
-- Date: 2016/11/22
-- Time: 11:18
-- To change this template use File | Settings | File Templates.
--

local _M = {}

function _M.execute(conf)
    if conf.some_boolean then
        ngx.log(ngx.ERR, "============ Hello World! ============")
        ngx.header["Hello-World"] = conf.some_string
    else
        ngx.log(ngx.ERR, "============ Bye World! ============")
        ngx.header["Hello-World"] = "Bye World!!!"
    end
end

return _M

