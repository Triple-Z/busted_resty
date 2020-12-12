<!-- omit in toc -->
# busted_resty
An extra mocking layer for OpenResty in busted testing environment.

<!-- omit in toc -->
## Table Of Contents
- [Quick Start](#quick-start)
- [License](#license)
## Quick Start

First, run `busted_resty` in your `resty` entry file.

```lua
-- busted_runner.lua
-- this file will be called by: `resty busted_runner.lua`
require "busted_resty"()

require "busted_runner"({ standalone = false })
```

Then, clear call traces every time you run a `busted` unit test.

```lua
describe("this is a busted test block", function()

    before_each(function()
        require "busted_resty".clear()
    end)

    it("this is a busted test", function()
        ngx.say("Hello, TripleZ.")
        assert.stub(ngx.say).was_called()
    end)

    it("test ngx call tracing is isolated", function()
        assert.stub(ngx.say).was_not_called()
    end)
end)
```

## License

Copyright &copy; 2020 Zhenzhen Zhao

This module is licensed under the [MIT License](./LICENSE).
