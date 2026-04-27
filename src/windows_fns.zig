const t = @import("windows_types.zig");
const e = @import("windows_enums.zig");
const s = @import("windows_structs.zig");

pub extern "user32" fn CreateWindowA(
    class_name: [*:0]const u8,
    window_name: [*:0]const u8,
    style: u32,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    lp_param: t.LPVOID,
) callconv(.winapi) t.HWND;

pub extern "user32" fn CreateWindowExA(
    style: u32,
    class_name: [*:0]const u8,
    window_name: [*:0]const u8,
    style: u32,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    lp_param: t.LPVOID,
) callconv(.winapi) t.HWND;

pub extern "user32" fn CreateWindowW(
    class_name: [*:0]const u16,
    window_name: [*:0]const u16,
    style: u32,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    lp_param: t.LPVOID,
) callconv(.winapi) t.HWND;

pub extern "user32" fn CreateWindowExW(
    style: u32,
    class_name: [*:0]const u16,
    window_name: [*:0]const u16,
    style: u32,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    lp_param: t.LPVOID,
) callconv(.winapi) t.HWND;

pub extern "user32" fn DefWindowProcA(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
) callconv(.winapi) t.LRESULT;

pub extern "user32" fn DefWindowProcW(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
) callconv(.winapi) t.LRESULT;

pub extern "user32" fn DestroyWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;

pub extern "user32" fn DispatchMessageA(msg: *const s.MSG) callconv(.winapi) t.LRESULT;

pub extern "user32" fn DispatchMessageW(msg: *const s.MSG) callconv(.winapi) t.LRESULT;

pub extern "user32" fn GetMessageA(
    msg: *s.MSG,
    hwnd: t.HWND,
    msg_filter_min: u32,
    msg_filter_max: u32,
) callconv(.winapi) i32;

pub extern "user32" fn GetMessageW(
    msg: *s.MSG,
    hwnd: t.HWND,
    msg_filter_min: u32,
    msg_filter_max: u32,
) callconv(.winapi) i32;

pub extern "kernel32" fn GetModuleHandleA(
    module_name: ?[*:0]const u8,
) callconv(.winapi) t.HINSTANCE;

pub extern "kernel32" fn GetModuleHandleW(
    module_name: ?[*:0]const u16,
) callconv(.winapi) t.HINSTANCE;

pub extern "gdi32" fn GetSysColorBrush(index: e.Color) callconv(.winapi) t.HBRUSH;

pub extern "user32" fn LoadCursorA(
    instance: t.HINSTANCE,
    cursor_name: [*:0]const u16,
) callconv(.winapi) t.HCURSOR;

pub extern "user32" fn LoadCursorW(
    instance: t.HINSTANCE,
    cursor_name: [*:0]const u16,
) callconv(.winapi) t.HCURSOR;

pub extern "user32" fn LoadIconA(
    instance: t.HINSTANCE,
    icon_name: [*:0]const u8,
) callconv(.winapi) t.HICON;

pub extern "user32" fn LoadIconW(
    instance: t.HINSTANCE,
    icon_name: [*:0]const u16,
) callconv(.winapi) t.HICON;

pub extern "user32" fn PostQuitMessage(exit_code: i32) callconv(.winapi) void;

pub extern "user32" fn RegisterClassA(
    class: *const s.WNDCLASSA,
) callconv(.winapi) t.ATOM;

pub extern "user32" fn RegisterClassW(
    class: *const s.WNDCLASSW,
) callconv(.winapi) t.ATOM;

pub extern "user32" fn RegisterClassExA(
    class: *const s.WNDCLASSEXA,
) callconv(.winapi) t.ATOM;

pub extern "user32" fn RegisterClassExW(
    class: *const s.WNDCLASSEXW,
) callconv(.winapi) t.ATOM;

pub extern "user32" fn ShowWindow(hwnd: t.HWND, show_cmd: e.SW) callconv(.winapi) i32;

pub extern "user32" fn TranslateMessage(msg: *const s.MSG) callconv(.winapi) i32;

pub extern "user32" fn UnregisterClassA(
    class_name: [*:0]const u8,
    instance: t.HINSTANCE,
) t.BOOL;

pub extern "user32" fn UnregisterClassW(
    class_name: [*:0]const u16,
    instance: t.HINSTANCE,
) t.BOOL;

pub extern "user32" fn UpdateWindow(hwnd: t.HWND) callconv(.winapi) i32;

pub export fn WndProcA(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
) callconv(.winapi) t.LRESULT {
    switch (@as(e.Messages, @enumFromInt(msg))) {
        .destroy => {
            PostQuitMessage(0);
            return @enumFromInt(0);
        },
        else => return DefWindowProcA(hwnd, msg, w_param, l_param),
    }
}

pub export fn WndProcW(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
) callconv(.winapi) t.LRESULT {
    switch (@as(e.Messages, @enumFromInt(msg))) {
        .destroy => {
            PostQuitMessage(0);
            return @enumFromInt(0);
        },
        else => return DefWindowProcW(hwnd, msg, w_param, l_param),
    }
}
