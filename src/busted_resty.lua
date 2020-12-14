local spy = require "luassert.spy"
local stub = require "luassert.stub"

local _M = {
    --- @type busted_resty
    _VERSION = "0.5.0",
    _unmocked_ngx = nil,
}

--- create a metatable which return a mock string in its `__index` metamethod
--- @return table a table for being a metatable
local function create_new_var_metatable(prefix)
    return {
        __index = function(tbl, key)
            tbl[key] = "mock_var"
            return tbl[key]
        end
    }
end

--- create a metatable which return stubbed function in its `__index` metamethod
--- @return table a table for being a metatable
local function create_new_func_metatable(prefix)
    return {
        __index = function(tbl, key)
            tbl[key] = function() end
            tbl[key] = stub(tbl, key)
            return tbl[key]
        end
    }
end

--- create a new ngx object for further mocking
--- @return table new partially mocked ngx object
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

--- init the mock objects for the target table
--- @param _ngx table
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

--- clear all the calling traces for spy objects in a table, recursively
--- @param tbl table target table (i.e. ngx)
--- @return boolean cleared for true, tbl is not a table for false
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

--- clear all calling traces if the `ngx` is mocked by this module.
function _M.clear()
    if not _M._unmocked_ngx then
        return
    end

    clear_spy_calls(_G.ngx)
end

--- restore `ngx` global object if mocked before
function _M.restore()
    if _M._unmocked_ngx then
        _G.ngx = _M._unmocked_ngx
    end
end

--- init the busted_resty
--- restore `ngx` global variable if mocked before.
--- create new mocked `ngx` with `__index` metamethod.
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

-- create a callable module
-- init this module by `require "busted_resty"()`
return setmetatable(_M, {
    __call = function(self)
        self.init()
    end
})
