# Squall router

Lua binding for https://crates.io/crates/squall-router

Implementation for other languages:
 - [Python](https://pypi.org/project/squall-router/)
 - [Rust](https://crates.io/crates/squall-router)


### Installation

Building of library requires Rust installation. Ubuntu example

```
apt update
apt install -y unzip curl make build-essential
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

If you don't have installed luarocks. You also should execute following lines.

```shell
curl -L -O https://luarocks.org/releases/luarocks-3.7.0.tar.gz
tar xpf luarocks-3.7.0.tar.gz && cd luarocks-3.7.0 && ./configure && make && make install && cd .. && rm -rf luarocks-3.7.0*
```

Build library

```shell
luarocks install squall-router
````

Please refer `examples` folder for the example of building the library as a part of OpenResty image.

### Usage example

```lua
router = require("squall_router").new_router()

-- Ignore trailing slashes on routes registration and resolving
router:set_ignore_trailing_slashes()

-- Register validators for dynamic octets
router:add_validator("int", "^[0-9]+$")
router:add_validator("uuid", "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")

-- Endpoind without matching of dynamic octet
router:add_route("GET", "/repo/{repo_name}", 0)

-- Endpoind with matching of dynamic octet to `int`
router:add_route("GET", "/user/{user_id:int}", 1)

-- Endpoind with matching of dynamic octet to `uuid`
router:add_route("GET", "/event/{event_id:uuid}", 2)

-- Location endpoint. 
-- Request matched by a prefix. No dynamic octets allowed 
router:add_location("GET", "/static", 3)

res, err = router:resolve("GET", "/repo/squall", true)
assert(res[1] == 0)
assert(res[2]['repo_name'] == "squall")

res, err = router:resolve("GET", "/user/123", true)
assert(res[1] == 1)
assert(res[2]['user_id'] == "123")

res, err = router:resolve("GET", "/user/user", true)
assert(res == nil)

event_id = "6d1a7b12-f2de-4ba7-b3c5-a4af3cab757d"
res, err = router:resolve("GET", "/event/" .. event_id, true)
assert(res[1] == 2)
assert(res[2]['event_id'] == event_id)

res, err = router:resolve("GET", "/event/123432", true)
assert(res == nil)

res, err = router:resolve("GET", "/static/css/style.css")
assert(res[1] == 3)
```