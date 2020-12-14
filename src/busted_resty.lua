local spy = require "luassert.spy"
local stub = require "luassert.stub"

local _M = {
    _VERSION = "0.5.0",
    _unmocked_ngx = nil,
}

local function create_new_var_metatable(prefix)
    return {
        __index = function(tbl, key)
            tbl[key] = "mock_var"
            return tbl[key]
        end
    }
end

local function create_new_func_metatable(prefix)
    return {
        __index = function(tbl, key)
            tbl[key] = function() end
            tbl[key] = stub(tbl, key)
            return tbl[key]
        end
    }
end

local function create_mock_ngx()
    return {
        status = 0,

        -- vars
        arg = setmetatable({}, create_new_var_metatable()),
        var = setmetatable({}, create_new_var_metatable()),
        header = setmetatable({}, create_new_var_metatable()),

        -- functions
        location = setmetatable({}, create_new_func_metatable()),
        req = setmetatable({}, create_new_func_metatable()),
        resp = setmetatable({}, create_new_func_metatable()),
    }
end

local function init_mocks(_ngx)
    if type(_ngx) ~= "table" then
        error("[busted_resty:init_mocks] _ngx is not a table")
    end

    stub(_ngx, "exit")
    stub(_ngx, "exec")
    stub(_ngx, "redirect")
    stub(_ngx, "send_headers")
    stub(_ngx, "headers_sent")
    stub(_ngx, "print")
    stub(_ngx, "say")
    stub(_ngx, "flush")
    stub(_ngx, "eof")
    stub(_ngx, "is_subrequest")
    stub(_ngx, "on_abort")

    stub(_ngx.req, "get_headers", {})
    stub(_ngx.req, "get_uri_args", {})
    stub(_ngx.req, "get_method", "GET")
    stub(_ngx.req, "http_version", 1.1)
end

local function clear_spy_calls(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    for k, v in pairs(tbl) do
        if spy.is_spy(v) then
            v:clear()
        elseif type(v) == "table" then
            clear_spy_calls(tbl[k])
        end
    end

    return true
end

function _M.clear()
    if not _M._unmocked_ngx then
        return
    end

    clear_spy_calls(_G.ngx)
end

function _M.restore()
    if _M._unmocked_ngx then
        _G.ngx = _M._unmocked_ngx
    end
end

function _M.init()
    if not _M._unmocked_ngx then
        _M._unmocked_ngx = _G.ngx
    else
        _M.restore()
    end

    local new_ngx = create_mock_ngx()
    init_mocks(new_ngx)
    _G.ngx = setmetatable(new_ngx, {
        __index = _G.ngx
    })
end

return setmetatable(_M, {
    __call = function(self)
        self.init()
    end
})
