use mlua::prelude::*;
use mlua::{Lua, Result, Table, UserData, UserDataMethods};
use squall_router::SquallRouter;

type AddRouteArgs = (String, String, i32); // method, path, handler_id
type AddLocationArgs = (String, String, i32); // method, path, handler_id
type AddValidatorArgs = (String, String); // alias, regex
type ResolveArgs = (String, String, bool); // method, path, return params
type MutResult = Result<(bool, Option<String>)>;

struct LuaRouter {
    vendor: SquallRouter,
}

#[inline]
fn set_ignore_trailing_slashes(_lua: &Lua, router: &mut LuaRouter, _: ()) -> MutResult {
    router.vendor.set_ignore_trailing_slashes();
    Ok((true, None))
}

#[inline]
fn add_route(_lua: &Lua, router: &mut LuaRouter, args: AddRouteArgs) -> MutResult {
    match router.vendor.add_route(args.0, args.1, args.2) {
        Err(e) => Ok((false, Some(e))),
        _ => Ok((true, None)),
    }
}

#[inline]
fn add_location(_lua: &Lua, router: &mut LuaRouter, args: AddLocationArgs) -> MutResult {
    // Should be reworked after implementation of the following issue
    // https://github.com/mtag-dev/rs-squall-router/issues/6
    router.vendor.add_location(args.0, args.1, args.2);
    Ok((true, None))
}

#[inline]
fn add_validator(_lua: &Lua, router: &mut LuaRouter, args: AddValidatorArgs) -> MutResult {
    match router.vendor.add_validator(args.0, args.1) {
        Err(e) => Ok((false, Some(e))),
        _ => Ok((true, None)),
    }
}

#[inline]
fn resolve<'lua>(
    lua: &'lua Lua,
    router: &LuaRouter,
    args: ResolveArgs,
) -> Result<(Option<Table<'lua>>, Option<String>)> {
    match router.vendor.resolve(args.0.as_str(), args.1.as_str()) {
        Some(v) => {
            let result = lua.create_table()?;
            let params = lua.create_table()?;

            // Fill parameters values only if required
            if args.2 {
                for (param, value) in v.1 {
                    params.set(param, value)?;
                }
            }

            result.set(1, v.0)?;
            result.set(2, params)?;
            Ok((Some(result), None))
        }
        None => Ok((None, None)),
    }
}

impl UserData for LuaRouter {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method_mut("set_ignore_trailing_slashes", set_ignore_trailing_slashes);
        methods.add_method_mut("add_route", add_route);
        methods.add_method_mut("add_location", add_location);
        methods.add_method_mut("add_validator", add_validator);
        methods.add_method("resolve", resolve);
    }
}

#[inline]
fn create_router(_lua: &Lua, _args: ()) -> Result<LuaRouter> {
    Ok(LuaRouter {
        vendor: SquallRouter::new(),
    })
}

#[mlua::lua_module]
fn squall_router(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("new_router", lua.create_function(create_router)?)?;
    Ok(exports)
}
