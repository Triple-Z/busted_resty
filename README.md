<!-- omit in toc -->
# busted_resty
An extra mocking layer for OpenResty CLI Tool (resty) in busted testing environment.

Writing pure Lua unit tests without mocking any OpenResty APIs which cannot be used in `ngx.timer.*` phase.

<!-- omit in toc -->
## Table Of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Mocked API List](#mocked-api-list)
- [Tests](#tests)
- [License](#license)

## Installation

This module has been published in [LuaRocks](https://luarocks.org/modules/triple-z/busted_resty), you can easily install it via LuaRocks.

```bash
$ luarocks install busted_resty
```

## Usage

First, run `busted_resty` in your `resty` entry file.

```lua
-- busted_runner.lua
-- this file will be called by: `resty busted_runner.lua`
require "busted_resty"()

require "busted.runner"({ standalone = false })
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

## Mocked API List

This module mocks the following OpenResty APIs:

- ngx.status
- ngx.exit
- ngx.exec
- ngx.redirect
- ngx.send_headers
- ngx.headers_sent
- ngx.print
- ngx.say
- ngx.flush
- ngx.eof
- ngx.is_subrequest
- ngx.on_abort
- ngx.arg.*
- ngx.var.*
- ngx.header.*
- ngx.location.*
- ngx.req.*
- ngx.resp.*

## Tests

Run tests:

```bash
# Install test dependencies, clean & reinstall busted_resty
# Run the unit tests
$ make test
```

## License

Copyright &copy; 2020 Zhenzhen Zhao

This module is licensed under the [MIT License](./LICENSE).
