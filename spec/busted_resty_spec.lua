describe("busted_resty module unit tests", function()

    before_each(function()
        require "busted_resty".clear()
    end)

    it("init the busted_resty", function()
        require "busted_resty".restore()
        local unmocked_ngx = _G.ngx

        require "busted_resty"()
        assert.is_not_equal(unmocked_ngx, _G.ngx)
        assert.is_equal(unmocked_ngx, getmetatable(_G.ngx).__index)
    end)

    it("testing ngx disabled APIs", function()
        assert.has_no.errors(function()
            ngx.say("hello, world!")
            ngx.print("hello")
            ngx.flush()
            ngx.eof()
            ngx.exit()
        end)

        assert.stub(ngx.say).was_called()
        assert.stub(ngx.print).was_called()
        assert.stub(ngx.flush).was_called()
        assert.stub(ngx.eof).was_called()
        assert.stub(ngx.exit).was_called()
    end)

    it("the ngx calling tracing is isolated", function()
        assert.stub(ngx.say).was_not_called()
    end)
end)
