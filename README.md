<!-- omit in toc -->
# busted_resty
An extra mocking layer for OpenResty in busted testing environment.

<!-- omit in toc -->
## Table Of Contents
- [Usage](#usage)
- [Mocked API List](#mocked-api-list)
- [Run Tests](#run-tests)
- [Test Coverage](#test-coverage)
- [License](#license)

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

## Run Tests

```bash
# Install dependencies
$ luarocks --lua-version 5.1 install busted luacov

# Run unit tests
$ ./run_test.sh
```

## Test Coverage

```
File                 Hits Missed Coverage
-----------------------------------------
src/busted_resty.lua 52   11     82.54%
-----------------------------------------
Total                52   11     82.54%
```

## License

Copyright &copy; 2020 Zhenzhen Zhao

This module is licensed under the [MIT License](./LICENSE).
