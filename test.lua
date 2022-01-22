describe("Busted unit testing framework", function()
  describe("should be awesome", function()
    local router = require("squall_router").new_router()

    it("router instance not a nil", function()
      assert.is_true(router ~= nil)
    end)

    it("router should accept correct validators", function()
      local res, err
      -- int validator
      res, err = router:add_validator("int", "^[0-9]+$")
      assert.is_true(res)
      assert.is_true(err == nil)
      -- validator for numeric values with optional dot
      res, err = router:add_validator("float", "^[0-9]+(.[0-9]+)?$")
      assert.is_true(res)
      assert.is_true(err == nil)
      -- validator for uuid values
      res, err = router:add_validator("uuid", "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
      assert.is_true(res)
      assert.is_true(err == nil)
    end)

    it("router should not accept incorrect validators", function()
      local res, err = router:add_validator("wrong", "^[0-9+$")
      assert.is_false(res)
      assert.is_true(require('string').find(err, "regex parse error") ~= nil)
    end)

    it("should register valid static routes", function()
      local res, err = router:add_route("GET", "/static/route", 0)
      assert.is_true(res)
      assert.is_true(err == nil)
    end)

    it("should register valid dynamic routes", function()
      local res, err
      -- no validator specified in dynamic octet
      res, err = router:add_route("GET", "/repo/{repo_name}", 1)
      assert.is_true(res)
      assert.is_true(err == nil)
      -- already registered `int` validator specified in dynamic octet
      res, err = router:add_route("GET", "/user/{user_id:int}", 2)
      assert.is_true(res)
      assert.is_true(err == nil)
    end)

    it("should register locations", function()
      local res, err = router:add_location("GET", "/static", 3)
      assert.is_true(res)
      assert.is_true(err == nil)
    end)

    it("should disallow registration on invalid routes", function()
      local res, err = router:add_route("GET", "$%^&*", 4)
      assert.is_false(res)
      assert.is_true(require('string').find(err, "Path processing error") ~= nil)
    end)

    it("should disallow registration of routes with unknown validator", function()
      local res, err = router:add_route("GET", "/user/{user_id:unknown_validator}", 5)
      assert.is_false(res)
      assert.is_true(require('string').find(err, "Unknown validator: unknown_validator") ~= nil)
    end)

    it("should disallow registration of routes with wrong validator", function()
      local res, err = router:add_route("GET", "/user/{user_id:wrong}", 6)
      assert.is_false(res)
      assert.is_true(require('string').find(err, "Unknown validator: wrong") ~= nil)
    end)

    it("should resolve static routes", function()
      local res, err = router:resolve("GET", "/static/route")
      assert.is_true(res[1] == 0)
      assert.is_true(err == nil)
    end)

    it("should resolve dynamic route", function()
      local res, err = router:resolve("GET", "/user/123", true)
      assert.is_true(res[1] == 2)
      assert.is_true(res[2]['user_id'] == "123")
      assert.is_true(err == nil)
    end)

    it("should not resolve dynamic if validator not matched", function()
      local res, err = router:resolve("GET", "/user/onetwotree", true)
      assert.is_true(res == nil)
      assert.is_true(err == nil)
    end)

    it("should resolve location", function()
      local res, err = router:resolve("GET", "/static/css/style.css")
      assert.is_true(res[1] == 3)
      assert.is_true(err == nil)
    end)
  end)
end)
