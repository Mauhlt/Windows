const t = @import("windows_types.zig");
const ClassStyles = @import("windows_enums.zig").ClassStyles;
// Structs
pub const WNDCLASSA = extern struct {
    style: u32 = 0,
    wnd_proc: *const fn (t.HWND, u32, t.WPARAM, t.LPARAM) callconv(.winapi) t.LRESULT,
    cb_cls_extra: i32 = 0,
    cb_wnd_extra: i32 = 0,
    instance: t.HINSTANCE,
    icon: t.HICON,
    cursor: t.HCURSOR,
    brush: t.HBRUSH,
    menu_name: ?[*:0]const u8,
    class_name: ?[*:0]const u8,
};
pub const WNDCLASSEXA = extern struct {
    style: u32 = 0,
    wnd_proc: *const fn (t.HWND, u32, t.WPARAM, t.LPARAM) callconv(.winapi) t.LRESULT,
    cb_cls_extra: i32 = 0,
    cb_wnd_extra: i32 = 0,
    instance: t.HINSTANCE,
    icon: t.HICON,
    cursor: t.HCURSOR,
    brush: t.HBRUSH,
    menu_name: ?[*:0]const u8,
    class_name: ?[*:0]const u8,
    icon_sm: t.HICON,
};
pub const WNDCLASSW = extern struct {
    style: u32 = 0,
    wnd_proc: *const fn (t.HWND, u32, t.WPARAM, t.LPARAM) callconv(.winapi) t.LRESULT,
    cls_extra: i32 = 0,
    wnd_extra: i32 = 0,
    instance: t.HINSTANCE,
    icon: t.HICON,
    cursor: t.HCURSOR,
    brush: t.HBRUSH,
    menu_name: ?[*:0]const u16,
    class_name: ?[*:0]const u16,
};
pub const WNDCLASSEXW = extern struct {
    size: u32 = @sizeOf(WNDCLASSEXW),
    style: u32 = 0,
    wnd_proc: *const fn (t.HWND, u32, t.WPARAM, t.LPARAM) callconv(.winapi) t.LRESULT,
    cls_extra: i32 = 0,
    wnd_extra: i32 = 0,
    instance: t.HINSTANCE,
    icon: t.HICON,
    cursor: t.HCURSOR,
    brush: t.HBRUSH,
    menu_name: ?[*:0]const u16,
    class_name: ?[*:0]const u16,
    small_icon: t.HICON,
};
pub const MSG = extern struct {
    hwnd: t.HWND,
    msg: u32,
    wParam: t.WPARAM,
    lParam: t.LPARAM,
    time: u32,
    pt: POINT,
    private: u32,
};
pub const POINT = extern struct {
    x: i32,
    y: i32,
};
pub const RECT = extern struct {
    left: i32,
    top: i32,
    right: i32,
    bot: i32,
};
