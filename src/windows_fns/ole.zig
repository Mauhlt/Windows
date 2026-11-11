//! ole32.dll (COM runtime)
const t = @import("../windows_types.zig");
const e = @import("../windows_enums.zig");
const s = @import("../windows_structs.zig");
const com = @import("../windows_com.zig");

/// Returns `.ok`, `.false` (already initialized on this thread — still pair with
/// CoUninitialize), or `.rpc_changed_mode`.
pub extern "ole32" fn CoInitializeEx(reserved: ?*anyopaque, coinit: e.CoInit) callconv(.winapi) t.HRESULT;
pub extern "ole32" fn CoUninitialize() callconv(.winapi) void;

pub extern "ole32" fn CoCreateInstance(
    clsid: s.REFCLSID,
    outer: ?*com.IUnknown,
    context: e.ClsCtx,
    iid: s.REFIID,
    out: *?*anyopaque,
) callconv(.winapi) t.HRESULT;

pub extern "ole32" fn CoTaskMemAlloc(size: usize) callconv(.winapi) ?*anyopaque;
pub extern "ole32" fn CoTaskMemFree(pv: ?*const anyopaque) callconv(.winapi) void;
