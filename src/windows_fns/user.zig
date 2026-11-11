//! user32.dll
//!
//! Every function declared in winuser.h, grouped by topic. `A` / `W` pairs are both bound;
//! prefer the `W` (UTF-16) versions. Out-buffers are `[*]u16` / `[*]u8` with a separate
//! length; in-strings are `[*:0]const u16` (or `?` when NULL is allowed).
const t = @import("../windows_types.zig");
const e = @import("../windows_enums.zig");
const s = @import("../windows_structs.zig");
const kernel = @import("kernel.zig");
const L = @import("std").unicode.utf8ToUtf16LeStringLiteral;

pub const WndProc = t.WndProc;
pub const TimerProc = t.TimerProc;
pub const DlgProc = t.DlgProc;
pub const HookProc = t.HookProc;

const is_64 = @sizeOf(usize) == 8;

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
/// x / y / w / h value meaning "let the system choose".
pub const CW_USEDEFAULT: i32 = @bitCast(@as(u32, 0x80000000));
pub const USER_DEFAULT_SCREEN_DPI: u32 = 96;
/// One notch of WM_MOUSEWHEEL / WM_MOUSEHWHEEL.
pub const WHEEL_DELTA: i16 = 120;
/// TRACKMOUSEEVENT.hover_time_ms: use the system hover time.
pub const HOVER_DEFAULT: u32 = 0xFFFFFFFF;

// MessageBox `kind` (MB_*).
pub const MB_OK: u32 = 0x00000000;
pub const MB_OKCANCEL: u32 = 0x00000001;
pub const MB_ABORTRETRYIGNORE: u32 = 0x00000002;
pub const MB_YESNOCANCEL: u32 = 0x00000003;
pub const MB_YESNO: u32 = 0x00000004;
pub const MB_RETRYCANCEL: u32 = 0x00000005;
pub const MB_ICONERROR: u32 = 0x00000010;
pub const MB_ICONQUESTION: u32 = 0x00000020;
pub const MB_ICONWARNING: u32 = 0x00000030;
pub const MB_ICONINFORMATION: u32 = 0x00000040;
pub const MB_SETFOREGROUND: u32 = 0x00010000;
pub const MB_TOPMOST: u32 = 0x00040000;

// MessageBox / DialogBox results (ID*).
pub const IDOK: i32 = 1;
pub const IDCANCEL: i32 = 2;
pub const IDABORT: i32 = 3;
pub const IDRETRY: i32 = 4;
pub const IDIGNORE: i32 = 5;
pub const IDYES: i32 = 6;
pub const IDNO: i32 = 7;

// Standard clipboard formats (CF_*).
pub const CF_TEXT: u32 = 1;
pub const CF_BITMAP: u32 = 2;
pub const CF_OEMTEXT: u32 = 7;
pub const CF_DIB: u32 = 8;
pub const CF_UNICODETEXT: u32 = 13;
pub const CF_HDROP: u32 = 15;
pub const CF_LOCALE: u32 = 16;
pub const CF_DIBV5: u32 = 17;

// RegisterDeviceNotification / RegisterPowerSettingNotification `flags`.
pub const DEVICE_NOTIFY_WINDOW_HANDLE: u32 = 0x0;
pub const DEVICE_NOTIFY_SERVICE_HANDLE: u32 = 0x1;
pub const DEVICE_NOTIFY_ALL_INTERFACE_CLASSES: u32 = 0x4;

// EnumDisplaySettings `mode_num`.
pub const ENUM_CURRENT_SETTINGS: u32 = 0xFFFFFFFF;
pub const ENUM_REGISTRY_SETTINGS: u32 = 0xFFFFFFFE;

// ---------------------------------------------------------------------------
// Message parameter helpers (LOWORD / HIWORD / GET_*_LPARAM macros)
// ---------------------------------------------------------------------------
/// Raw bits of a WPARAM / LPARAM / LRESULT or plain integer.
fn rawBits(v: anytype) usize {
    const raw = if (@typeInfo(@TypeOf(v)) == .@"enum") @backingInt(v) else v;
    const Wide = switch (@typeInfo(@TypeOf(raw)).int.signedness) {
        .signed => isize,
        .unsigned => usize,
    };
    return @bitCast(@as(Wide, raw));
}
/// LOWORD of a WPARAM, LPARAM, LRESULT or integer.
pub fn loWord(v: anytype) u16 {
    return @truncate(rawBits(v));
}
/// HIWORD of a WPARAM, LPARAM, LRESULT or integer.
pub fn hiWord(v: anytype) u16 {
    return @truncate(rawBits(v) >> 16);
}
/// GET_X_LPARAM: signed x of a mouse message.
pub fn getXLParam(l_param: t.LPARAM) i32 {
    return @as(i16, @bitCast(loWord(l_param)));
}
/// GET_Y_LPARAM: signed y of a mouse message.
pub fn getYLParam(l_param: t.LPARAM) i32 {
    return @as(i16, @bitCast(hiWord(l_param)));
}
/// GET_WHEEL_DELTA_WPARAM: multiples of WHEEL_DELTA.
pub fn getWheelDeltaWParam(w_param: t.WPARAM) i16 {
    return @bitCast(hiWord(w_param));
}

// ---------------------------------------------------------------------------
// Window classes
// ---------------------------------------------------------------------------
pub extern "user32" fn RegisterClassA(class: *const s.WNDCLASSA) callconv(.winapi) t.ATOM;
pub extern "user32" fn RegisterClassW(class: *const s.WNDCLASSW) callconv(.winapi) t.ATOM;
pub extern "user32" fn RegisterClassExA(class: *const s.WNDCLASSEXA) callconv(.winapi) t.ATOM;
pub extern "user32" fn RegisterClassExW(class: *const s.WNDCLASSEXW) callconv(.winapi) t.ATOM;
pub extern "user32" fn UnregisterClassA(class_name: [*:0]const u8, instance: t.HINSTANCE) callconv(.winapi) t.BOOL;
pub extern "user32" fn UnregisterClassW(class_name: [*:0]const u16, instance: t.HINSTANCE) callconv(.winapi) t.BOOL;
/// `class_name` may be a class atom (`makeIntResourceA(@backingInt(atom))`).
pub extern "user32" fn GetClassInfoA(instance: t.HINSTANCE, class_name: t.ResourceNameA, class: *s.WNDCLASSA) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetClassInfoW(instance: t.HINSTANCE, class_name: t.ResourceNameW, class: *s.WNDCLASSW) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetClassInfoExA(instance: t.HINSTANCE, class_name: t.ResourceNameA, class: *s.WNDCLASSEXA) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetClassInfoExW(instance: t.HINSTANCE, class_name: t.ResourceNameW, class: *s.WNDCLASSEXW) callconv(.winapi) t.BOOL;
/// Returns the number of chars copied (excluding the terminator), 0 on failure.
pub extern "user32" fn GetClassNameA(hwnd: t.HWND, buf: [*]u8, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetClassNameW(hwnd: t.HWND, buf: [*]u16, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn RealGetWindowClassA(hwnd: t.HWND, buf: [*]u8, buf_len: u32) callconv(.winapi) u32;
pub extern "user32" fn RealGetWindowClassW(hwnd: t.HWND, buf: [*]u16, buf_len: u32) callconv(.winapi) u32;

pub extern "user32" fn GetClassWord(hwnd: t.HWND, index: e.ClassLongIndex) callconv(.winapi) u16;
pub extern "user32" fn SetClassWord(hwnd: t.HWND, index: e.ClassLongIndex, value: u16) callconv(.winapi) u16;
pub extern "user32" fn GetClassLongA(hwnd: t.HWND, index: e.ClassLongIndex) callconv(.winapi) u32;
pub extern "user32" fn GetClassLongW(hwnd: t.HWND, index: e.ClassLongIndex) callconv(.winapi) u32;
pub extern "user32" fn SetClassLongA(hwnd: t.HWND, index: e.ClassLongIndex, value: i32) callconv(.winapi) u32;
pub extern "user32" fn SetClassLongW(hwnd: t.HWND, index: e.ClassLongIndex, value: i32) callconv(.winapi) u32;

// On 32-bit the *ClassLongPtr functions are macros for *ClassLong.
pub const GetClassLongPtrA = if (is_64) struct {
    extern "user32" fn GetClassLongPtrA(hwnd: t.HWND, index: e.ClassLongIndex) callconv(.winapi) usize;
}.GetClassLongPtrA else struct {
    fn GetClassLongPtrA(hwnd: t.HWND, index: e.ClassLongIndex) usize {
        return GetClassLongA(hwnd, index);
    }
}.GetClassLongPtrA;

pub const GetClassLongPtrW = if (is_64) struct {
    extern "user32" fn GetClassLongPtrW(hwnd: t.HWND, index: e.ClassLongIndex) callconv(.winapi) usize;
}.GetClassLongPtrW else struct {
    fn GetClassLongPtrW(hwnd: t.HWND, index: e.ClassLongIndex) usize {
        return GetClassLongW(hwnd, index);
    }
}.GetClassLongPtrW;

pub const SetClassLongPtrA = if (is_64) struct {
    extern "user32" fn SetClassLongPtrA(hwnd: t.HWND, index: e.ClassLongIndex, value: isize) callconv(.winapi) usize;
}.SetClassLongPtrA else struct {
    fn SetClassLongPtrA(hwnd: t.HWND, index: e.ClassLongIndex, value: isize) usize {
        return SetClassLongA(hwnd, index, @intCast(value));
    }
}.SetClassLongPtrA;

pub const SetClassLongPtrW = if (is_64) struct {
    extern "user32" fn SetClassLongPtrW(hwnd: t.HWND, index: e.ClassLongIndex, value: isize) callconv(.winapi) usize;
}.SetClassLongPtrW else struct {
    fn SetClassLongPtrW(hwnd: t.HWND, index: e.ClassLongIndex, value: isize) usize {
        return SetClassLongW(hwnd, index, @intCast(value));
    }
}.SetClassLongPtrW;

// ---------------------------------------------------------------------------
// Window lifetime / state
// ---------------------------------------------------------------------------
pub extern "user32" fn CreateWindowExA(
    ex_style: e.WindowStyleEx,
    class_name: [*:0]const u8,
    window_name: ?[*:0]const u8,
    style: e.WindowStyle,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    param: t.LPVOID,
) callconv(.winapi) t.HWND;

pub extern "user32" fn CreateWindowExW(
    ex_style: e.WindowStyleEx,
    class_name: [*:0]const u16,
    window_name: ?[*:0]const u16,
    style: e.WindowStyle,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    param: t.LPVOID,
) callconv(.winapi) t.HWND;

/// CreateWindowA is a macro in winuser.h, not a user32 export.
pub inline fn CreateWindowA(
    class_name: [*:0]const u8,
    window_name: ?[*:0]const u8,
    style: e.WindowStyle,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    param: t.LPVOID,
) t.HWND {
    return CreateWindowExA(.{}, class_name, window_name, style, x, y, w, h, parent, menu, instance, param);
}

/// CreateWindowW is a macro in winuser.h, not a user32 export.
pub inline fn CreateWindowW(
    class_name: [*:0]const u16,
    window_name: ?[*:0]const u16,
    style: e.WindowStyle,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    menu: t.HMENU,
    instance: t.HINSTANCE,
    param: t.LPVOID,
) t.HWND {
    return CreateWindowExW(.{}, class_name, window_name, style, x, y, w, h, parent, menu, instance, param);
}

pub extern "user32" fn DestroyWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsWindowUnicode(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsChild(parent: t.HWND, hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn ShowWindow(hwnd: t.HWND, show_cmd: e.SW) callconv(.winapi) t.BOOL;
pub extern "user32" fn ShowWindowAsync(hwnd: t.HWND, show_cmd: e.SW) callconv(.winapi) t.BOOL;
pub extern "user32" fn ShowOwnedPopups(hwnd: t.HWND, show: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn AnimateWindow(hwnd: t.HWND, time_ms: u32, flags: e.AnimateWindowFlags) callconv(.winapi) t.BOOL;
pub extern "user32" fn UpdateWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsWindowVisible(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// True if minimized.
pub extern "user32" fn IsIconic(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// True if maximized.
pub extern "user32" fn IsZoomed(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// Restores a minimized window.
pub extern "user32" fn OpenIcon(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// Minimizes the window (it does not destroy it).
pub extern "user32" fn CloseWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// Returns `.true` if the window was previously disabled.
pub extern "user32" fn EnableWindow(hwnd: t.HWND, enable: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsWindowEnabled(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsHungAppWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn DisableProcessWindowsGhosting() callconv(.winapi) void;
pub extern "user32" fn FlashWindow(hwnd: t.HWND, invert: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn FlashWindowEx(info: *const s.FLASHWINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn EndTask(hwnd: t.HWND, shut_down: t.BOOL, force: t.BOOL) callconv(.winapi) t.BOOL;
/// `flags`: PW_CLIENTONLY (1) | PW_RENDERFULLCONTENT (2).
pub extern "user32" fn PrintWindow(hwnd: t.HWND, hdc: t.HDC, flags: u32) callconv(.winapi) t.BOOL;

pub extern "user32" fn SetWindowTextA(hwnd: t.HWND, text: ?[*:0]const u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetWindowTextW(hwnd: t.HWND, text: ?[*:0]const u16) callconv(.winapi) t.BOOL;
/// Returns the number of chars copied (excluding the terminator).
pub extern "user32" fn GetWindowTextA(hwnd: t.HWND, buf: [*]u8, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetWindowTextW(hwnd: t.HWND, buf: [*]u16, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetWindowTextLengthA(hwnd: t.HWND) callconv(.winapi) i32;
pub extern "user32" fn GetWindowTextLengthW(hwnd: t.HWND) callconv(.winapi) i32;
/// Like GetWindowTextW but never sends WM_GETTEXT.
pub extern "user32" fn InternalGetWindowText(hwnd: t.HWND, buf: [*]u16, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetWindowModuleFileNameA(hwnd: t.HWND, buf: [*]u8, buf_len: u32) callconv(.winapi) u32;
pub extern "user32" fn GetWindowModuleFileNameW(hwnd: t.HWND, buf: [*]u16, buf_len: u32) callconv(.winapi) u32;

// ---------------------------------------------------------------------------
// Window geometry
// ---------------------------------------------------------------------------
pub extern "user32" fn GetClientRect(hwnd: t.HWND, rect: *s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetWindowRect(hwnd: t.HWND, rect: *s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn AdjustWindowRect(rect: *s.RECT, style: e.WindowStyle, menu: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn AdjustWindowRectEx(
    rect: *s.RECT,
    style: e.WindowStyle,
    menu: t.BOOL,
    ex_style: e.WindowStyleEx,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn AdjustWindowRectExForDpi(
    rect: *s.RECT,
    style: e.WindowStyle,
    menu: t.BOOL,
    ex_style: e.WindowStyleEx,
    dpi: u32,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetWindowPos(
    hwnd: t.HWND,
    insert_after: t.HWND,
    x: i32,
    y: i32,
    cx: i32,
    cy: i32,
    flags: e.SetWindowPosFlags,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn MoveWindow(hwnd: t.HWND, x: i32, y: i32, w: i32, h: i32, repaint: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn BringWindowToTop(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetWindowPlacement(hwnd: t.HWND, placement: *s.WINDOWPLACEMENT) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetWindowPlacement(hwnd: t.HWND, placement: *const s.WINDOWPLACEMENT) callconv(.winapi) t.BOOL;

/// Batch several SetWindowPos calls: Begin, Defer (re-assign the returned HDWP), End.
pub extern "user32" fn BeginDeferWindowPos(num_windows: i32) callconv(.winapi) t.HDWP;
pub extern "user32" fn DeferWindowPos(
    dwp: t.HDWP,
    hwnd: t.HWND,
    insert_after: t.HWND,
    x: i32,
    y: i32,
    cx: i32,
    cy: i32,
    flags: e.SetWindowPosFlags,
) callconv(.winapi) t.HDWP;
pub extern "user32" fn EndDeferWindowPos(dwp: t.HDWP) callconv(.winapi) t.BOOL;

pub extern "user32" fn ClientToScreen(hwnd: t.HWND, point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn ScreenToClient(hwnd: t.HWND, point: *s.POINT) callconv(.winapi) t.BOOL;
/// `from` / `to` may be `.null` for screen coordinates.
pub extern "user32" fn MapWindowPoints(from: t.HWND, to: t.HWND, points: [*]s.POINT, count: u32) callconv(.winapi) i32;
pub extern "user32" fn LogicalToPhysicalPoint(hwnd: t.HWND, point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn PhysicalToLogicalPoint(hwnd: t.HWND, point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn LogicalToPhysicalPointForPerMonitorDPI(hwnd: t.HWND, point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn PhysicalToLogicalPointForPerMonitorDPI(hwnd: t.HWND, point: *s.POINT) callconv(.winapi) t.BOOL;

pub extern "user32" fn WindowFromPoint(point: s.POINT) callconv(.winapi) t.HWND;
pub extern "user32" fn WindowFromPhysicalPoint(point: s.POINT) callconv(.winapi) t.HWND;
pub extern "user32" fn ChildWindowFromPoint(parent: t.HWND, point: s.POINT) callconv(.winapi) t.HWND;
pub extern "user32" fn ChildWindowFromPointEx(parent: t.HWND, point: s.POINT, flags: e.ChildFromPoint) callconv(.winapi) t.HWND;
pub extern "user32" fn RealChildWindowFromPoint(parent: t.HWND, parent_client_point: s.POINT) callconv(.winapi) t.HWND;

/// `flags` are TPM_* alignment / animation flags.
pub extern "user32" fn CalculatePopupWindowPosition(
    anchor: *const s.POINT,
    window_size: *const s.SIZE,
    flags: e.TrackPopupMenuFlags,
    exclude: ?*const s.RECT,
    popup_position: *s.RECT,
) callconv(.winapi) t.BOOL;

/// Returns ERROR (0), NULLREGION (1), SIMPLEREGION (2) or COMPLEXREGION (3).
pub extern "user32" fn GetWindowRgn(hwnd: t.HWND, rgn: t.HRGN) callconv(.winapi) i32;
pub extern "user32" fn GetWindowRgnBox(hwnd: t.HWND, rect: *s.RECT) callconv(.winapi) i32;
/// The system owns `rgn` after a successful call.
pub extern "user32" fn SetWindowRgn(hwnd: t.HWND, rgn: t.HRGN, redraw: t.BOOL) callconv(.winapi) i32;

// MDI-style arrangement.
pub extern "user32" fn ArrangeIconicWindows(hwnd: t.HWND) callconv(.winapi) u32;
/// `how`: MDITILE_VERTICAL (0) / MDITILE_HORIZONTAL (1) / MDITILE_SKIPDISABLED (2) / MDITILE_ZORDER (4).
pub extern "user32" fn TileWindows(parent: t.HWND, how: u32, rect: ?*const s.RECT, count: u32, kids: ?[*]const t.HWND) callconv(.winapi) u16;
pub extern "user32" fn CascadeWindows(parent: t.HWND, how: u32, rect: ?*const s.RECT, count: u32, kids: ?[*]const t.HWND) callconv(.winapi) u16;

// ---------------------------------------------------------------------------
// Window hierarchy / enumeration / info
// ---------------------------------------------------------------------------
pub extern "user32" fn GetDesktopWindow() callconv(.winapi) t.HWND;
pub extern "user32" fn GetShellWindow() callconv(.winapi) t.HWND;
pub extern "user32" fn GetParent(hwnd: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn SetParent(child: t.HWND, new_parent: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn GetAncestor(hwnd: t.HWND, flags: e.Ancestor) callconv(.winapi) t.HWND;
pub extern "user32" fn GetWindow(hwnd: t.HWND, cmd: e.GetWindowCmd) callconv(.winapi) t.HWND;
pub extern "user32" fn GetTopWindow(hwnd: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn GetLastActivePopup(hwnd: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn AnyPopup() callconv(.winapi) t.BOOL;

/// `class_name` may be a class atom.
pub extern "user32" fn FindWindowA(class_name: ?t.ResourceNameA, window_name: ?[*:0]const u8) callconv(.winapi) t.HWND;
pub extern "user32" fn FindWindowW(class_name: ?t.ResourceNameW, window_name: ?[*:0]const u16) callconv(.winapi) t.HWND;
pub extern "user32" fn FindWindowExA(
    parent: t.HWND,
    child_after: t.HWND,
    class_name: ?t.ResourceNameA,
    window_name: ?[*:0]const u8,
) callconv(.winapi) t.HWND;
pub extern "user32" fn FindWindowExW(
    parent: t.HWND,
    child_after: t.HWND,
    class_name: ?t.ResourceNameW,
    window_name: ?[*:0]const u16,
) callconv(.winapi) t.HWND;

pub extern "user32" fn EnumWindows(func: t.WndEnumProc, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumChildWindows(parent: t.HWND, func: t.WndEnumProc, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumThreadWindows(thread_id: u32, func: t.WndEnumProc, l_param: t.LPARAM) callconv(.winapi) t.BOOL;

/// Returns the thread id; writes the process id to `process_id` if given.
pub extern "user32" fn GetWindowThreadProcessId(hwnd: t.HWND, process_id: ?*u32) callconv(.winapi) u32;
pub extern "user32" fn IsGUIThread(convert: t.BOOL) callconv(.winapi) t.BOOL;
/// `thread_id` 0 = foreground thread. Set `info.size` (the default does).
pub extern "user32" fn GetGUIThreadInfo(thread_id: u32, info: *s.GUITHREADINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetWindowInfo(hwnd: t.HWND, info: *s.WINDOWINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetTitleBarInfo(hwnd: t.HWND, info: *s.TITLEBARINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetAltTabInfoA(hwnd: t.HWND, item: i32, info: *s.ALTTABINFO, item_text: ?[*]u8, item_text_len: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetAltTabInfoW(hwnd: t.HWND, item: i32, info: *s.ALTTABINFO, item_text: ?[*]u16, item_text_len: u32) callconv(.winapi) t.BOOL;

pub extern "user32" fn RegisterShellHookWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn DeregisterShellHookWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// LAYOUT_RTL (1) when mirrored.
pub extern "user32" fn GetProcessDefaultLayout(layout: *u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetProcessDefaultLayout(layout: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetWindowContextHelpId(hwnd: t.HWND, id: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetWindowContextHelpId(hwnd: t.HWND) callconv(.winapi) u32;

// ---------------------------------------------------------------------------
// Layered windows / capture affinity
// ---------------------------------------------------------------------------
/// Requires WS_EX_LAYERED. `alpha` is 0 (transparent) .. 255 (opaque).
pub extern "user32" fn SetLayeredWindowAttributes(hwnd: t.HWND, key: t.COLORREF, alpha: u8, flags: e.LayeredWindowFlags) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetLayeredWindowAttributes(hwnd: t.HWND, key: ?*t.COLORREF, alpha: ?*u8, flags: ?*e.LayeredWindowFlags) callconv(.winapi) t.BOOL;
pub extern "user32" fn UpdateLayeredWindow(
    hwnd: t.HWND,
    hdc_dst: t.HDC,
    dst: ?*const s.POINT,
    size: ?*const s.SIZE,
    hdc_src: t.HDC,
    src: ?*const s.POINT,
    key: t.COLORREF,
    blend: ?*const s.BLENDFUNCTION,
    flags: e.UpdateLayeredWindowFlags,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn UpdateLayeredWindowIndirect(hwnd: t.HWND, info: *const s.UPDATELAYEREDWINDOWINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetWindowDisplayAffinity(hwnd: t.HWND, affinity: *e.WindowDisplayAffinity) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetWindowDisplayAffinity(hwnd: t.HWND, affinity: e.WindowDisplayAffinity) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Window data (GWLP_USERDATA etc.). On 32-bit the *LongPtr functions are macros for *Long.
// ---------------------------------------------------------------------------
pub extern "user32" fn GetWindowWord(hwnd: t.HWND, index: i32) callconv(.winapi) u16;
pub extern "user32" fn SetWindowWord(hwnd: t.HWND, index: i32, value: u16) callconv(.winapi) u16;
pub extern "user32" fn GetWindowLongA(hwnd: t.HWND, index: e.WindowLongIndex) callconv(.winapi) i32;
pub extern "user32" fn GetWindowLongW(hwnd: t.HWND, index: e.WindowLongIndex) callconv(.winapi) i32;
pub extern "user32" fn SetWindowLongA(hwnd: t.HWND, index: e.WindowLongIndex, value: i32) callconv(.winapi) i32;
pub extern "user32" fn SetWindowLongW(hwnd: t.HWND, index: e.WindowLongIndex, value: i32) callconv(.winapi) i32;

pub const GetWindowLongPtrA = if (is_64) struct {
    extern "user32" fn GetWindowLongPtrA(hwnd: t.HWND, index: e.WindowLongIndex) callconv(.winapi) isize;
}.GetWindowLongPtrA else struct {
    fn GetWindowLongPtrA(hwnd: t.HWND, index: e.WindowLongIndex) isize {
        return GetWindowLongA(hwnd, index);
    }
}.GetWindowLongPtrA;

pub const GetWindowLongPtrW = if (is_64) struct {
    extern "user32" fn GetWindowLongPtrW(hwnd: t.HWND, index: e.WindowLongIndex) callconv(.winapi) isize;
}.GetWindowLongPtrW else struct {
    fn GetWindowLongPtrW(hwnd: t.HWND, index: e.WindowLongIndex) isize {
        return GetWindowLongW(hwnd, index);
    }
}.GetWindowLongPtrW;

pub const SetWindowLongPtrA = if (is_64) struct {
    extern "user32" fn SetWindowLongPtrA(hwnd: t.HWND, index: e.WindowLongIndex, value: isize) callconv(.winapi) isize;
}.SetWindowLongPtrA else struct {
    fn SetWindowLongPtrA(hwnd: t.HWND, index: e.WindowLongIndex, value: isize) isize {
        return SetWindowLongA(hwnd, index, @intCast(value));
    }
}.SetWindowLongPtrA;

pub const SetWindowLongPtrW = if (is_64) struct {
    extern "user32" fn SetWindowLongPtrW(hwnd: t.HWND, index: e.WindowLongIndex, value: isize) callconv(.winapi) isize;
}.SetWindowLongPtrW else struct {
    fn SetWindowLongPtrW(hwnd: t.HWND, index: e.WindowLongIndex, value: isize) isize {
        return SetWindowLongW(hwnd, index, @intCast(value));
    }
}.SetWindowLongPtrW;

/// Stores `ptr` in GWLP_USERDATA. Pair with `getUserData` inside your WndProc.
pub fn setUserData(hwnd: t.HWND, ptr: ?*anyopaque) void {
    _ = SetWindowLongPtrW(hwnd, .user_data, @bitCast(@intFromPtr(ptr)));
}
/// Reads the pointer stored by `setUserData`, or null.
pub fn getUserData(comptime T: type, hwnd: t.HWND) ?*T {
    const raw: usize = @bitCast(GetWindowLongPtrW(hwnd, .user_data));
    return @ptrFromInt(raw);
}

// ---------------------------------------------------------------------------
// Window properties (SetProp / GetProp). `name` may be an atom.
// ---------------------------------------------------------------------------
pub extern "user32" fn SetPropA(hwnd: t.HWND, name: t.ResourceNameA, data: t.HANDLE) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetPropW(hwnd: t.HWND, name: t.ResourceNameW, data: t.HANDLE) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPropA(hwnd: t.HWND, name: t.ResourceNameA) callconv(.winapi) t.HANDLE;
pub extern "user32" fn GetPropW(hwnd: t.HWND, name: t.ResourceNameW) callconv(.winapi) t.HANDLE;
pub extern "user32" fn RemovePropA(hwnd: t.HWND, name: t.ResourceNameA) callconv(.winapi) t.HANDLE;
pub extern "user32" fn RemovePropW(hwnd: t.HWND, name: t.ResourceNameW) callconv(.winapi) t.HANDLE;
/// Returns the last value returned by `func`, or -1 if there are no properties.
pub extern "user32" fn EnumPropsA(hwnd: t.HWND, func: t.PropEnumProcA) callconv(.winapi) i32;
pub extern "user32" fn EnumPropsW(hwnd: t.HWND, func: t.PropEnumProcW) callconv(.winapi) i32;
pub extern "user32" fn EnumPropsExA(hwnd: t.HWND, func: t.PropEnumProcExA, l_param: t.LPARAM) callconv(.winapi) i32;
pub extern "user32" fn EnumPropsExW(hwnd: t.HWND, func: t.PropEnumProcExW, l_param: t.LPARAM) callconv(.winapi) i32;

// ---------------------------------------------------------------------------
// Messages
// ---------------------------------------------------------------------------
pub extern "user32" fn DefWindowProcA(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DefWindowProcW(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn CallWindowProcA(prev: t.WndProc, hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn CallWindowProcW(prev: t.WndProc, hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DispatchMessageA(msg: *const s.MSG) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DispatchMessageW(msg: *const s.MSG) callconv(.winapi) t.LRESULT;
/// Returns >0 for a message, 0 for WM_QUIT, -1 on error.
pub extern "user32" fn GetMessageA(msg: *s.MSG, hwnd: t.HWND, filter_min: u32, filter_max: u32) callconv(.winapi) i32;
/// Returns >0 for a message, 0 for WM_QUIT, -1 on error.
pub extern "user32" fn GetMessageW(msg: *s.MSG, hwnd: t.HWND, filter_min: u32, filter_max: u32) callconv(.winapi) i32;
pub extern "user32" fn PeekMessageA(msg: *s.MSG, hwnd: t.HWND, filter_min: u32, filter_max: u32, remove: e.RemoveMessage) callconv(.winapi) t.BOOL;
pub extern "user32" fn PeekMessageW(msg: *s.MSG, hwnd: t.HWND, filter_min: u32, filter_max: u32, remove: e.RemoveMessage) callconv(.winapi) t.BOOL;
pub extern "user32" fn TranslateMessage(msg: *const s.MSG) callconv(.winapi) t.BOOL;
pub extern "user32" fn WaitMessage() callconv(.winapi) t.BOOL;
pub extern "user32" fn PostQuitMessage(exit_code: i32) callconv(.winapi) void;

pub extern "user32" fn PostMessageA(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn PostMessageW(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn PostThreadMessageA(thread_id: u32, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn PostThreadMessageW(thread_id: u32, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn SendMessageA(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn SendMessageW(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
/// Returns `.null` on failure or timeout; the window proc's result goes to `result`.
pub extern "user32" fn SendMessageTimeoutA(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
    flags: e.SendMessageTimeoutFlags,
    timeout_ms: u32,
    result: ?*usize,
) callconv(.winapi) t.LRESULT;
pub extern "user32" fn SendMessageTimeoutW(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
    flags: e.SendMessageTimeoutFlags,
    timeout_ms: u32,
    result: ?*usize,
) callconv(.winapi) t.LRESULT;
pub extern "user32" fn SendNotifyMessageA(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn SendNotifyMessageW(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn SendMessageCallbackA(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
    callback: t.SendAsyncProc,
    data: usize,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn SendMessageCallbackW(
    hwnd: t.HWND,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
    callback: t.SendAsyncProc,
    data: usize,
) callconv(.winapi) t.BOOL;

/// `flags` are BSF_*; `recipients` are BSM_* (in / out).
pub extern "user32" fn BroadcastSystemMessageA(flags: u32, recipients: ?*u32, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) i32;
pub extern "user32" fn BroadcastSystemMessageW(flags: u32, recipients: ?*u32, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) i32;
pub extern "user32" fn BroadcastSystemMessageExA(
    flags: u32,
    recipients: ?*u32,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
    info: ?*s.BSMINFO,
) callconv(.winapi) i32;
pub extern "user32" fn BroadcastSystemMessageExW(
    flags: u32,
    recipients: ?*u32,
    msg: u32,
    w_param: t.WPARAM,
    l_param: t.LPARAM,
    info: ?*s.BSMINFO,
) callconv(.winapi) i32;

pub extern "user32" fn ReplyMessage(result: t.LRESULT) callconv(.winapi) t.BOOL;
pub extern "user32" fn InSendMessage() callconv(.winapi) t.BOOL;
/// Returns ISMEX_* flags.
pub extern "user32" fn InSendMessageEx(reserved: ?*anyopaque) callconv(.winapi) u32;
pub extern "user32" fn AttachThreadInput(attach: u32, attach_to: u32, do_attach: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn WaitForInputIdle(process: t.HANDLE, timeout_ms: u32) callconv(.winapi) u32;
pub extern "user32" fn SetMessageQueue(max_messages: i32) callconv(.winapi) t.BOOL;

/// Screen position of the last message, packed as POINTS (use loWord / hiWord).
pub extern "user32" fn GetMessagePos() callconv(.winapi) u32;
pub extern "user32" fn GetUnpredictedMessagePos() callconv(.winapi) u32;
pub extern "user32" fn GetMessageTime() callconv(.winapi) i32;
pub extern "user32" fn GetMessageExtraInfo() callconv(.winapi) t.LPARAM;
pub extern "user32" fn SetMessageExtraInfo(l_param: t.LPARAM) callconv(.winapi) t.LPARAM;
pub extern "user32" fn IsWow64Message() callconv(.winapi) t.BOOL;
/// High word: kinds of messages currently in the queue; low word: added since last call.
pub extern "user32" fn GetQueueStatus(flags: e.QueueStatus) callconv(.winapi) u32;
pub extern "user32" fn GetInputState() callconv(.winapi) t.BOOL;
/// Returns WAIT_OBJECT_0 + n, WAIT_OBJECT_0 + count (input available), WAIT_TIMEOUT, ...
pub extern "user32" fn MsgWaitForMultipleObjects(
    count: u32,
    handles: ?[*]const t.HANDLE,
    wait_all: t.BOOL,
    timeout_ms: u32,
    wake_mask: e.QueueStatus,
) callconv(.winapi) u32;
/// `flags` are MWMO_* (WAITALL 1, ALERTABLE 2, INPUTAVAILABLE 4).
pub extern "user32" fn MsgWaitForMultipleObjectsEx(
    count: u32,
    handles: ?[*]const t.HANDLE,
    timeout_ms: u32,
    wake_mask: e.QueueStatus,
    flags: u32,
) callconv(.winapi) u32;

pub extern "user32" fn RegisterWindowMessageA(name: [*:0]const u8) callconv(.winapi) u32;
pub extern "user32" fn RegisterWindowMessageW(name: [*:0]const u16) callconv(.winapi) u32;
pub extern "user32" fn CallMsgFilterA(msg: *s.MSG, code: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn CallMsgFilterW(msg: *s.MSG, code: i32) callconv(.winapi) t.BOOL;
/// `flag`: MSGFLT_ADD (1) / MSGFLT_REMOVE (2). Prefer ChangeWindowMessageFilterEx.
pub extern "user32" fn ChangeWindowMessageFilter(msg: u32, flag: u32) callconv(.winapi) t.BOOL;
/// `action`: MSGFLT_RESET (0) / MSGFLT_ALLOW (1) / MSGFLT_DISALLOW (2).
pub extern "user32" fn ChangeWindowMessageFilterEx(hwnd: t.HWND, msg: u32, action: u32, info: ?*s.CHANGEFILTERSTRUCT) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetCurrentInputMessageSource(source: *s.INPUT_MESSAGE_SOURCE) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetCIMSSM(source: *s.INPUT_MESSAGE_SOURCE) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Hooks
// ---------------------------------------------------------------------------
/// `thread_id` 0 = all threads on the desktop (then `module` must contain `func`).
pub extern "user32" fn SetWindowsHookExA(id: e.HookId, func: t.HookProc, module: t.HINSTANCE, thread_id: u32) callconv(.winapi) t.HHOOK;
pub extern "user32" fn SetWindowsHookExW(id: e.HookId, func: t.HookProc, module: t.HINSTANCE, thread_id: u32) callconv(.winapi) t.HHOOK;
pub extern "user32" fn UnhookWindowsHookEx(hook: t.HHOOK) callconv(.winapi) t.BOOL;
pub extern "user32" fn CallNextHookEx(hook: t.HHOOK, code: i32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
/// Obsolete 16-bit API; use SetWindowsHookExA.
pub extern "user32" fn SetWindowsHookA(id: e.HookId, func: t.HookProc) callconv(.winapi) t.HHOOK;
/// Obsolete 16-bit API; use SetWindowsHookExW.
pub extern "user32" fn SetWindowsHookW(id: e.HookId, func: t.HookProc) callconv(.winapi) t.HHOOK;
/// Obsolete 16-bit API; use UnhookWindowsHookEx.
pub extern "user32" fn UnhookWindowsHook(id: e.HookId, func: t.HookProc) callconv(.winapi) t.BOOL;

/// Accessibility (EVENT_*) hooks.
pub extern "user32" fn SetWinEventHook(
    event_min: u32,
    event_max: u32,
    module: t.HMODULE,
    func: t.WinEventProc,
    process_id: u32,
    thread_id: u32,
    flags: e.WinEventHookFlags,
) callconv(.winapi) t.HWINEVENTHOOK;
pub extern "user32" fn UnhookWinEvent(hook: t.HWINEVENTHOOK) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsWinEventHookInstalled(event: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn NotifyWinEvent(event: u32, hwnd: t.HWND, id_object: i32, id_child: i32) callconv(.winapi) void;

// ---------------------------------------------------------------------------
// Device / power notifications. `recipient` is an HWND (cast to HANDLE) or service handle.
// ---------------------------------------------------------------------------
/// `filter` points to a DEV_BROADCAST_* header.
pub extern "user32" fn RegisterDeviceNotificationA(recipient: t.HANDLE, filter: *anyopaque, flags: u32) callconv(.winapi) t.HDEVNOTIFY;
pub extern "user32" fn RegisterDeviceNotificationW(recipient: t.HANDLE, filter: *anyopaque, flags: u32) callconv(.winapi) t.HDEVNOTIFY;
pub extern "user32" fn UnregisterDeviceNotification(handle: t.HDEVNOTIFY) callconv(.winapi) t.BOOL;
pub extern "user32" fn RegisterPowerSettingNotification(recipient: t.HANDLE, setting: *const s.GUID, flags: u32) callconv(.winapi) t.HPOWERNOTIFY;
pub extern "user32" fn UnregisterPowerSettingNotification(handle: t.HPOWERNOTIFY) callconv(.winapi) t.BOOL;
pub extern "user32" fn RegisterSuspendResumeNotification(recipient: t.HANDLE, flags: u32) callconv(.winapi) t.HPOWERNOTIFY;
pub extern "user32" fn UnregisterSuspendResumeNotification(handle: t.HPOWERNOTIFY) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Painting
// ---------------------------------------------------------------------------
pub extern "user32" fn BeginPaint(hwnd: t.HWND, paint: *s.PAINTSTRUCT) callconv(.winapi) t.HDC;
pub extern "user32" fn EndPaint(hwnd: t.HWND, paint: *const s.PAINTSTRUCT) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetDC(hwnd: t.HWND) callconv(.winapi) t.HDC;
pub extern "user32" fn GetDCEx(hwnd: t.HWND, clip: t.HRGN, flags: e.GetDCExFlags) callconv(.winapi) t.HDC;
/// DC for the whole window, including the non-client area.
pub extern "user32" fn GetWindowDC(hwnd: t.HWND) callconv(.winapi) t.HDC;
pub extern "user32" fn ReleaseDC(hwnd: t.HWND, hdc: t.HDC) callconv(.winapi) i32;
pub extern "user32" fn WindowFromDC(hdc: t.HDC) callconv(.winapi) t.HWND;

pub extern "user32" fn InvalidateRect(hwnd: t.HWND, rect: ?*const s.RECT, erase: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn ValidateRect(hwnd: t.HWND, rect: ?*const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn InvalidateRgn(hwnd: t.HWND, rgn: t.HRGN, erase: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn ValidateRgn(hwnd: t.HWND, rgn: t.HRGN) callconv(.winapi) t.BOOL;
/// Returns `.false` if there is no update region. Pass `rect = null` to just ask.
pub extern "user32" fn GetUpdateRect(hwnd: t.HWND, rect: ?*s.RECT, erase: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetUpdateRgn(hwnd: t.HWND, rgn: t.HRGN, erase: t.BOOL) callconv(.winapi) i32;
pub extern "user32" fn ExcludeUpdateRgn(hdc: t.HDC, hwnd: t.HWND) callconv(.winapi) i32;
pub extern "user32" fn RedrawWindow(hwnd: t.HWND, update: ?*const s.RECT, update_rgn: t.HRGN, flags: e.RedrawWindowFlags) callconv(.winapi) t.BOOL;
/// Pass `.null` to unlock.
pub extern "user32" fn LockWindowUpdate(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn PaintDesktop(hdc: t.HDC) callconv(.winapi) t.BOOL;

pub extern "user32" fn GetSysColor(index: e.Color) callconv(.winapi) t.COLORREF;
pub extern "user32" fn GetSysColorBrush(index: e.Color) callconv(.winapi) t.HBRUSH;
pub extern "user32" fn SetSysColors(count: i32, elements: [*]const e.Color, values: [*]const t.COLORREF) callconv(.winapi) t.BOOL;

/// `edge`: BDR_* / EDGE_*; `flags`: BF_*.
pub extern "user32" fn DrawEdge(hdc: t.HDC, rect: *s.RECT, edge: u32, flags: u32) callconv(.winapi) t.BOOL;
/// `kind`: DFC_*; `state`: DFCS_*.
pub extern "user32" fn DrawFrameControl(hdc: t.HDC, rect: *s.RECT, kind: u32, state: u32) callconv(.winapi) t.BOOL;
/// `flags`: DC_*.
pub extern "user32" fn DrawCaption(hwnd: t.HWND, hdc: t.HDC, rect: *const s.RECT, flags: u32) callconv(.winapi) t.BOOL;
/// `id_ani`: IDANI_CAPTION (3).
pub extern "user32" fn DrawAnimatedRects(hwnd: t.HWND, id_ani: i32, from: *const s.RECT, to: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn DrawFocusRect(hdc: t.HDC, rect: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn FillRect(hdc: t.HDC, rect: *const s.RECT, brush: t.HBRUSH) callconv(.winapi) i32;
pub extern "user32" fn FrameRect(hdc: t.HDC, rect: *const s.RECT, brush: t.HBRUSH) callconv(.winapi) i32;
pub extern "user32" fn InvertRect(hdc: t.HDC, rect: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn DrawIcon(hdc: t.HDC, x: i32, y: i32, icon: t.HICON) callconv(.winapi) t.BOOL;
/// `flags`: DI_NORMAL (3), DI_COMPAT, DI_DEFAULTSIZE, ...
pub extern "user32" fn DrawIconEx(
    hdc: t.HDC,
    x: i32,
    y: i32,
    icon: t.HICON,
    cx: i32,
    cy: i32,
    ani_step: u32,
    flicker_free_brush: t.HBRUSH,
    flags: u32,
) callconv(.winapi) t.BOOL;
/// `flags`: DST_* | DSS_*.
pub extern "user32" fn DrawStateA(
    hdc: t.HDC,
    fore: t.HBRUSH,
    callback: ?t.DrawStateProc,
    l_data: t.LPARAM,
    w_data: t.WPARAM,
    x: i32,
    y: i32,
    cx: i32,
    cy: i32,
    flags: u32,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn DrawStateW(
    hdc: t.HDC,
    fore: t.HBRUSH,
    callback: ?t.DrawStateProc,
    l_data: t.LPARAM,
    w_data: t.WPARAM,
    x: i32,
    y: i32,
    cx: i32,
    cy: i32,
    flags: u32,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn GrayStringA(
    hdc: t.HDC,
    brush: t.HBRUSH,
    output: ?t.GrayStringProc,
    data: t.LPARAM,
    count: i32,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn GrayStringW(
    hdc: t.HDC,
    brush: t.HBRUSH,
    output: ?t.GrayStringProc,
    data: t.LPARAM,
    count: i32,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
) callconv(.winapi) t.BOOL;

/// `len` = -1 for a NUL-terminated string. Returns the text height.
pub extern "user32" fn DrawTextA(hdc: t.HDC, text: [*]const u8, len: i32, rect: *s.RECT, format: e.DrawTextFormat) callconv(.winapi) i32;
pub extern "user32" fn DrawTextW(hdc: t.HDC, text: [*]const u16, len: i32, rect: *s.RECT, format: e.DrawTextFormat) callconv(.winapi) i32;
/// `text` is modified in place with `.modify_string`.
pub extern "user32" fn DrawTextExA(hdc: t.HDC, text: [*]u8, len: i32, rect: *s.RECT, format: e.DrawTextFormat, params: ?*s.DRAWTEXTPARAMS) callconv(.winapi) i32;
pub extern "user32" fn DrawTextExW(hdc: t.HDC, text: [*]u16, len: i32, rect: *s.RECT, format: e.DrawTextFormat, params: ?*s.DRAWTEXTPARAMS) callconv(.winapi) i32;
/// Returns the string extent packed as (height << 16 | width).
pub extern "user32" fn TabbedTextOutA(
    hdc: t.HDC,
    x: i32,
    y: i32,
    text: [*]const u8,
    len: i32,
    tab_count: i32,
    tab_stops: ?[*]const i32,
    tab_origin: i32,
) callconv(.winapi) i32;
pub extern "user32" fn TabbedTextOutW(
    hdc: t.HDC,
    x: i32,
    y: i32,
    text: [*]const u16,
    len: i32,
    tab_count: i32,
    tab_stops: ?[*]const i32,
    tab_origin: i32,
) callconv(.winapi) i32;
pub extern "user32" fn GetTabbedTextExtentA(hdc: t.HDC, text: [*]const u8, len: i32, tab_count: i32, tab_stops: ?[*]const i32) callconv(.winapi) u32;
pub extern "user32" fn GetTabbedTextExtentW(hdc: t.HDC, text: [*]const u16, len: i32, tab_count: i32, tab_stops: ?[*]const i32) callconv(.winapi) u32;

// ---------------------------------------------------------------------------
// Rectangles
// ---------------------------------------------------------------------------
pub extern "user32" fn SetRect(rect: *s.RECT, left: i32, top: i32, right: i32, bottom: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetRectEmpty(rect: *s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn CopyRect(dst: *s.RECT, src: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn InflateRect(rect: *s.RECT, dx: i32, dy: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn OffsetRect(rect: *s.RECT, dx: i32, dy: i32) callconv(.winapi) t.BOOL;
/// Returns `.false` (and an empty `dst`) if they don't intersect.
pub extern "user32" fn IntersectRect(dst: *s.RECT, a: *const s.RECT, b: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn UnionRect(dst: *s.RECT, a: *const s.RECT, b: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn SubtractRect(dst: *s.RECT, a: *const s.RECT, b: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsRectEmpty(rect: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn EqualRect(a: *const s.RECT, b: *const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn PtInRect(rect: *const s.RECT, point: s.POINT) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Scrolling
// ---------------------------------------------------------------------------
pub extern "user32" fn ScrollWindow(hwnd: t.HWND, dx: i32, dy: i32, rect: ?*const s.RECT, clip: ?*const s.RECT) callconv(.winapi) t.BOOL;
/// `flags`: SW_SCROLLCHILDREN (1) | SW_INVALIDATE (2) | SW_ERASE (4) | SW_SMOOTHSCROLL (0x10).
pub extern "user32" fn ScrollWindowEx(
    hwnd: t.HWND,
    dx: i32,
    dy: i32,
    scroll: ?*const s.RECT,
    clip: ?*const s.RECT,
    update_rgn: t.HRGN,
    update: ?*s.RECT,
    flags: u32,
) callconv(.winapi) i32;
pub extern "user32" fn ScrollDC(
    hdc: t.HDC,
    dx: i32,
    dy: i32,
    scroll: ?*const s.RECT,
    clip: ?*const s.RECT,
    update_rgn: t.HRGN,
    update: ?*s.RECT,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetScrollPos(hwnd: t.HWND, bar: e.ScrollBar, pos: i32, redraw: t.BOOL) callconv(.winapi) i32;
pub extern "user32" fn GetScrollPos(hwnd: t.HWND, bar: e.ScrollBar) callconv(.winapi) i32;
pub extern "user32" fn SetScrollRange(hwnd: t.HWND, bar: e.ScrollBar, min: i32, max: i32, redraw: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetScrollRange(hwnd: t.HWND, bar: e.ScrollBar, min: *i32, max: *i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn ShowScrollBar(hwnd: t.HWND, bar: e.ScrollBar, show: t.BOOL) callconv(.winapi) t.BOOL;
/// `arrows`: ESB_ENABLE_BOTH (0) / ESB_DISABLE_LTUP (1) / ESB_DISABLE_RTDN (2) / ESB_DISABLE_BOTH (3).
pub extern "user32" fn EnableScrollBar(hwnd: t.HWND, bar: e.ScrollBar, arrows: u32) callconv(.winapi) t.BOOL;
/// Returns the new scroll position.
pub extern "user32" fn SetScrollInfo(hwnd: t.HWND, bar: e.ScrollBar, info: *const s.SCROLLINFO, redraw: t.BOOL) callconv(.winapi) i32;
pub extern "user32" fn GetScrollInfo(hwnd: t.HWND, bar: e.ScrollBar, info: *s.SCROLLINFO) callconv(.winapi) t.BOOL;
/// `id_object`: OBJID_HSCROLL (-6) / OBJID_VSCROLL (-5) / OBJID_CLIENT (-4, scroll bar control).
pub extern "user32" fn GetScrollBarInfo(hwnd: t.HWND, id_object: i32, info: *s.SCROLLBARINFO) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Timers
// ---------------------------------------------------------------------------
pub extern "user32" fn SetTimer(hwnd: t.HWND, id_event: usize, elapse_ms: u32, timer_func: ?TimerProc) callconv(.winapi) usize;
/// `tolerance_ms`: TIMERV_DEFAULT_COALESCING (0) / TIMERV_NO_COALESCING (0xFFFFFFFF) / a delay.
pub extern "user32" fn SetCoalescableTimer(
    hwnd: t.HWND,
    id_event: usize,
    elapse_ms: u32,
    timer_func: ?TimerProc,
    tolerance_ms: u32,
) callconv(.winapi) usize;
pub extern "user32" fn KillTimer(hwnd: t.HWND, id_event: usize) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------------
pub extern "user32" fn CreateDialogParamA(
    instance: t.HINSTANCE,
    template: t.ResourceNameA,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) t.HWND;
pub extern "user32" fn CreateDialogParamW(
    instance: t.HINSTANCE,
    template: t.ResourceNameW,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) t.HWND;
pub extern "user32" fn CreateDialogIndirectParamA(
    instance: t.HINSTANCE,
    template: *const s.DLGTEMPLATE,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) t.HWND;
pub extern "user32" fn CreateDialogIndirectParamW(
    instance: t.HINSTANCE,
    template: *const s.DLGTEMPLATE,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) t.HWND;
/// Modal. Returns the EndDialog result, or -1 on failure.
pub extern "user32" fn DialogBoxParamA(
    instance: t.HINSTANCE,
    template: t.ResourceNameA,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) isize;
pub extern "user32" fn DialogBoxParamW(
    instance: t.HINSTANCE,
    template: t.ResourceNameW,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) isize;
pub extern "user32" fn DialogBoxIndirectParamA(
    instance: t.HINSTANCE,
    template: *const s.DLGTEMPLATE,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) isize;
pub extern "user32" fn DialogBoxIndirectParamW(
    instance: t.HINSTANCE,
    template: *const s.DLGTEMPLATE,
    parent: t.HWND,
    dialog_func: ?DlgProc,
    init_param: t.LPARAM,
) callconv(.winapi) isize;

/// CreateDialogW is a macro in winuser.h, not a user32 export.
pub inline fn CreateDialogW(instance: t.HINSTANCE, template: t.ResourceNameW, parent: t.HWND, dialog_func: ?DlgProc) t.HWND {
    return CreateDialogParamW(instance, template, parent, dialog_func, .null);
}
/// DialogBoxW is a macro in winuser.h, not a user32 export.
pub inline fn DialogBoxW(instance: t.HINSTANCE, template: t.ResourceNameW, parent: t.HWND, dialog_func: ?DlgProc) isize {
    return DialogBoxParamW(instance, template, parent, dialog_func, .null);
}

pub extern "user32" fn EndDialog(dlg: t.HWND, result: isize) callconv(.winapi) t.BOOL;
pub extern "user32" fn DefDlgProcA(dlg: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DefDlgProcW(dlg: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
/// Call from a modeless dialog's message loop; skip Translate/Dispatch when it returns true.
pub extern "user32" fn IsDialogMessageA(dlg: t.HWND, msg: *const s.MSG) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsDialogMessageW(dlg: t.HWND, msg: *const s.MSG) callconv(.winapi) t.BOOL;
/// Converts dialog units to pixels in place.
pub extern "user32" fn MapDialogRect(dlg: t.HWND, rect: *s.RECT) callconv(.winapi) t.BOOL;
/// Low word: horizontal base unit, high word: vertical.
pub extern "user32" fn GetDialogBaseUnits() callconv(.winapi) i32;

pub extern "user32" fn GetDlgItem(dlg: t.HWND, id: i32) callconv(.winapi) t.HWND;
pub extern "user32" fn GetDlgCtrlID(hwnd: t.HWND) callconv(.winapi) i32;
pub extern "user32" fn SetDlgItemInt(dlg: t.HWND, id: i32, value: u32, signed: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetDlgItemInt(dlg: t.HWND, id: i32, translated: ?*t.BOOL, signed: t.BOOL) callconv(.winapi) u32;
pub extern "user32" fn SetDlgItemTextA(dlg: t.HWND, id: i32, text: ?[*:0]const u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetDlgItemTextW(dlg: t.HWND, id: i32, text: ?[*:0]const u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetDlgItemTextA(dlg: t.HWND, id: i32, buf: [*]u8, buf_len: i32) callconv(.winapi) u32;
pub extern "user32" fn GetDlgItemTextW(dlg: t.HWND, id: i32, buf: [*]u16, buf_len: i32) callconv(.winapi) u32;
pub extern "user32" fn SendDlgItemMessageA(dlg: t.HWND, id: i32, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn SendDlgItemMessageW(dlg: t.HWND, id: i32, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
/// `check`: BST_UNCHECKED (0) / BST_CHECKED (1) / BST_INDETERMINATE (2).
pub extern "user32" fn CheckDlgButton(dlg: t.HWND, id: i32, check: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn CheckRadioButton(dlg: t.HWND, first_id: i32, last_id: i32, check_id: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsDlgButtonChecked(dlg: t.HWND, id: i32) callconv(.winapi) u32;
pub extern "user32" fn GetNextDlgGroupItem(dlg: t.HWND, ctl: t.HWND, previous: t.BOOL) callconv(.winapi) t.HWND;
pub extern "user32" fn GetNextDlgTabItem(dlg: t.HWND, ctl: t.HWND, previous: t.BOOL) callconv(.winapi) t.HWND;

/// `path_spec` is an in/out buffer (at least MAX_PATH). `file_type`: DDL_*.
pub extern "user32" fn DlgDirListA(dlg: t.HWND, path_spec: ?[*:0]u8, list_box_id: i32, static_path_id: i32, file_type: u32) callconv(.winapi) i32;
pub extern "user32" fn DlgDirListW(dlg: t.HWND, path_spec: ?[*:0]u16, list_box_id: i32, static_path_id: i32, file_type: u32) callconv(.winapi) i32;
pub extern "user32" fn DlgDirSelectExA(dlg: t.HWND, buf: [*]u8, buf_len: i32, list_box_id: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn DlgDirSelectExW(dlg: t.HWND, buf: [*]u16, buf_len: i32, list_box_id: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn DlgDirListComboBoxA(dlg: t.HWND, path_spec: ?[*:0]u8, combo_box_id: i32, static_path_id: i32, file_type: u32) callconv(.winapi) i32;
pub extern "user32" fn DlgDirListComboBoxW(dlg: t.HWND, path_spec: ?[*:0]u16, combo_box_id: i32, static_path_id: i32, file_type: u32) callconv(.winapi) i32;
pub extern "user32" fn DlgDirSelectComboBoxExA(dlg: t.HWND, buf: [*]u8, buf_len: i32, combo_box_id: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn DlgDirSelectComboBoxExW(dlg: t.HWND, buf: [*]u16, buf_len: i32, combo_box_id: i32) callconv(.winapi) t.BOOL;

pub extern "user32" fn GetComboBoxInfo(combo: t.HWND, info: *s.COMBOBOXINFO) callconv(.winapi) t.BOOL;
/// Returns the number of items per column.
pub extern "user32" fn GetListBoxInfo(hwnd: t.HWND) callconv(.winapi) u32;

/// `kind` is an MB_* bitmask (0 = MB_OK). Returns the ID* of the pressed button.
pub extern "user32" fn MessageBoxA(hwnd: t.HWND, text: ?[*:0]const u8, caption: ?[*:0]const u8, kind: u32) callconv(.winapi) i32;
pub extern "user32" fn MessageBoxW(hwnd: t.HWND, text: ?[*:0]const u16, caption: ?[*:0]const u16, kind: u32) callconv(.winapi) i32;
pub extern "user32" fn MessageBoxExA(hwnd: t.HWND, text: ?[*:0]const u8, caption: ?[*:0]const u8, kind: u32, language_id: u16) callconv(.winapi) i32;
pub extern "user32" fn MessageBoxExW(hwnd: t.HWND, text: ?[*:0]const u16, caption: ?[*:0]const u16, kind: u32, language_id: u16) callconv(.winapi) i32;
pub extern "user32" fn MessageBoxIndirectA(params: *const s.MSGBOXPARAMSA) callconv(.winapi) i32;
pub extern "user32" fn MessageBoxIndirectW(params: *const s.MSGBOXPARAMSW) callconv(.winapi) i32;
/// `kind`: 0xFFFFFFFF (simple beep) or an MB_ICON* value.
pub extern "user32" fn MessageBeep(kind: u32) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// MDI
// ---------------------------------------------------------------------------
pub extern "user32" fn DefFrameProcA(hwnd: t.HWND, mdi_client: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DefFrameProcW(hwnd: t.HWND, mdi_client: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DefMDIChildProcA(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn DefMDIChildProcW(hwnd: t.HWND, msg: u32, w_param: t.WPARAM, l_param: t.LPARAM) callconv(.winapi) t.LRESULT;
pub extern "user32" fn TranslateMDISysAccel(mdi_client: t.HWND, msg: *const s.MSG) callconv(.winapi) t.BOOL;
pub extern "user32" fn CreateMDIWindowA(
    class_name: [*:0]const u8,
    window_name: ?[*:0]const u8,
    style: e.WindowStyle,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    instance: t.HINSTANCE,
    l_param: t.LPARAM,
) callconv(.winapi) t.HWND;
pub extern "user32" fn CreateMDIWindowW(
    class_name: [*:0]const u16,
    window_name: ?[*:0]const u16,
    style: e.WindowStyle,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    parent: t.HWND,
    instance: t.HINSTANCE,
    l_param: t.LPARAM,
) callconv(.winapi) t.HWND;

// ---------------------------------------------------------------------------
// Menus
// ---------------------------------------------------------------------------
pub extern "user32" fn CreateMenu() callconv(.winapi) t.HMENU;
pub extern "user32" fn CreatePopupMenu() callconv(.winapi) t.HMENU;
pub extern "user32" fn DestroyMenu(menu: t.HMENU) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsMenu(menu: t.HMENU) callconv(.winapi) t.BOOL;
pub extern "user32" fn LoadMenuA(instance: t.HINSTANCE, name: t.ResourceNameA) callconv(.winapi) t.HMENU;
pub extern "user32" fn LoadMenuW(instance: t.HINSTANCE, name: t.ResourceNameW) callconv(.winapi) t.HMENU;
pub extern "user32" fn LoadMenuIndirectA(template: *const s.MENUTEMPLATE) callconv(.winapi) t.HMENU;
pub extern "user32" fn LoadMenuIndirectW(template: *const s.MENUTEMPLATE) callconv(.winapi) t.HMENU;
pub extern "user32" fn GetMenu(hwnd: t.HWND) callconv(.winapi) t.HMENU;
pub extern "user32" fn SetMenu(hwnd: t.HWND, menu: t.HMENU) callconv(.winapi) t.BOOL;
pub extern "user32" fn DrawMenuBar(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// `revert = .true` resets the window menu to the default.
pub extern "user32" fn GetSystemMenu(hwnd: t.HWND, revert: t.BOOL) callconv(.winapi) t.HMENU;
pub extern "user32" fn GetSubMenu(menu: t.HMENU, pos: i32) callconv(.winapi) t.HMENU;
/// Returns 0xFFFFFFFF for a submenu or invalid position.
pub extern "user32" fn GetMenuItemID(menu: t.HMENU, pos: i32) callconv(.winapi) u32;
pub extern "user32" fn GetMenuItemCount(menu: t.HMENU) callconv(.winapi) i32;

/// `new_item` is a string, or bitmap / owner-draw data depending on `flags`.
/// `id_new_item` is a command id, or an HMENU (cast to usize) with `.popup`.
pub extern "user32" fn AppendMenuA(menu: t.HMENU, flags: e.MenuFlags, id_new_item: usize, new_item: ?[*:0]const u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn AppendMenuW(menu: t.HMENU, flags: e.MenuFlags, id_new_item: usize, new_item: ?[*:0]const u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn InsertMenuA(menu: t.HMENU, position: u32, flags: e.MenuFlags, id_new_item: usize, new_item: ?[*:0]const u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn InsertMenuW(menu: t.HMENU, position: u32, flags: e.MenuFlags, id_new_item: usize, new_item: ?[*:0]const u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn ModifyMenuA(menu: t.HMENU, position: u32, flags: e.MenuFlags, id_new_item: usize, new_item: ?[*:0]const u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn ModifyMenuW(menu: t.HMENU, position: u32, flags: e.MenuFlags, id_new_item: usize, new_item: ?[*:0]const u16) callconv(.winapi) t.BOOL;
/// Obsolete; use InsertMenu / AppendMenu / ModifyMenu / RemoveMenu / DeleteMenu.
pub extern "user32" fn ChangeMenuA(menu: t.HMENU, cmd: u32, new_item: ?[*:0]const u8, cmd_insert: u32, flags: e.MenuFlags) callconv(.winapi) t.BOOL;
pub extern "user32" fn ChangeMenuW(menu: t.HMENU, cmd: u32, new_item: ?[*:0]const u16, cmd_insert: u32, flags: e.MenuFlags) callconv(.winapi) t.BOOL;
/// Detaches the item (submenus are not destroyed).
pub extern "user32" fn RemoveMenu(menu: t.HMENU, position: u32, flags: e.MenuFlags) callconv(.winapi) t.BOOL;
/// Deletes the item (and destroys its submenu).
pub extern "user32" fn DeleteMenu(menu: t.HMENU, position: u32, flags: e.MenuFlags) callconv(.winapi) t.BOOL;

/// Returns the previous MF_ENABLED / MF_GRAYED / MF_DISABLED state, or -1.
pub extern "user32" fn EnableMenuItem(menu: t.HMENU, id: u32, enable: e.MenuFlags) callconv(.winapi) t.BOOL;
/// Returns the previous MF_CHECKED / MF_UNCHECKED state, or 0xFFFFFFFF.
pub extern "user32" fn CheckMenuItem(menu: t.HMENU, id: u32, check: e.MenuFlags) callconv(.winapi) u32;
pub extern "user32" fn CheckMenuRadioItem(menu: t.HMENU, first: u32, last: u32, check: u32, flags: e.MenuFlags) callconv(.winapi) t.BOOL;
pub extern "user32" fn HiliteMenuItem(hwnd: t.HWND, menu: t.HMENU, id: u32, hilite: e.MenuFlags) callconv(.winapi) t.BOOL;
/// Returns MF_* state bits, or 0xFFFFFFFF.
pub extern "user32" fn GetMenuState(menu: t.HMENU, id: u32, flags: e.MenuFlags) callconv(.winapi) u32;
pub extern "user32" fn GetMenuStringA(menu: t.HMENU, id: u32, buf: ?[*]u8, buf_len: i32, flags: e.MenuFlags) callconv(.winapi) i32;
pub extern "user32" fn GetMenuStringW(menu: t.HMENU, id: u32, buf: ?[*]u16, buf_len: i32, flags: e.MenuFlags) callconv(.winapi) i32;
pub extern "user32" fn SetMenuItemBitmaps(menu: t.HMENU, position: u32, flags: e.MenuFlags, unchecked: t.HBITMAP, checked: t.HBITMAP) callconv(.winapi) t.BOOL;
/// Low word: width, high word: height.
pub extern "user32" fn GetMenuCheckMarkDimensions() callconv(.winapi) i32;

pub extern "user32" fn InsertMenuItemA(menu: t.HMENU, item: u32, by_position: t.BOOL, info: *const s.MENUITEMINFOA) callconv(.winapi) t.BOOL;
pub extern "user32" fn InsertMenuItemW(menu: t.HMENU, item: u32, by_position: t.BOOL, info: *const s.MENUITEMINFOW) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetMenuItemInfoA(menu: t.HMENU, item: u32, by_position: t.BOOL, info: *s.MENUITEMINFOA) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetMenuItemInfoW(menu: t.HMENU, item: u32, by_position: t.BOOL, info: *s.MENUITEMINFOW) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetMenuItemInfoA(menu: t.HMENU, item: u32, by_position: t.BOOL, info: *const s.MENUITEMINFOA) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetMenuItemInfoW(menu: t.HMENU, item: u32, by_position: t.BOOL, info: *const s.MENUITEMINFOW) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetMenuInfo(menu: t.HMENU, info: *s.MENUINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetMenuInfo(menu: t.HMENU, info: *const s.MENUINFO) callconv(.winapi) t.BOOL;
/// `flags`: GMDI_USEDISABLED (1) | GMDI_GOINTOPOPUPS (2). Returns 0xFFFFFFFF if none.
pub extern "user32" fn GetMenuDefaultItem(menu: t.HMENU, by_position: u32, flags: u32) callconv(.winapi) u32;
/// `item` 0xFFFFFFFF clears the default.
pub extern "user32" fn SetMenuDefaultItem(menu: t.HMENU, item: u32, by_position: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetMenuItemRect(hwnd: t.HWND, menu: t.HMENU, item: u32, rect: *s.RECT) callconv(.winapi) t.BOOL;
/// Returns the zero-based item position, or -1.
pub extern "user32" fn MenuItemFromPoint(hwnd: t.HWND, menu: t.HMENU, screen_point: s.POINT) callconv(.winapi) i32;
/// `id_object`: OBJID_MENU (-3) / OBJID_SYSMENU (-1) / OBJID_CLIENT (-4, popup). `id_item` 0 = the bar itself.
pub extern "user32" fn GetMenuBarInfo(hwnd: t.HWND, id_object: i32, id_item: i32, info: *s.MENUBARINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetMenuContextHelpId(menu: t.HMENU, id: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetMenuContextHelpId(menu: t.HMENU) callconv(.winapi) u32;

/// With `.return_cmd` the result is the selected command id (0 = cancelled).
pub extern "user32" fn TrackPopupMenu(
    menu: t.HMENU,
    flags: e.TrackPopupMenuFlags,
    x: i32,
    y: i32,
    reserved: i32,
    hwnd: t.HWND,
    rect: ?*const s.RECT,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn TrackPopupMenuEx(
    menu: t.HMENU,
    flags: e.TrackPopupMenuFlags,
    x: i32,
    y: i32,
    hwnd: t.HWND,
    params: ?*const s.TPMPARAMS,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn EndMenu() callconv(.winapi) t.BOOL;

pub extern "user32" fn DragDetect(hwnd: t.HWND, point: s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn DragObject(parent: t.HWND, from: t.HWND, fmt: u32, data: usize, cursor: t.HCURSOR) callconv(.winapi) u32;

// ---------------------------------------------------------------------------
// Keyboard accelerators
// ---------------------------------------------------------------------------
pub extern "user32" fn LoadAcceleratorsA(instance: t.HINSTANCE, name: t.ResourceNameA) callconv(.winapi) t.HACCEL;
pub extern "user32" fn LoadAcceleratorsW(instance: t.HINSTANCE, name: t.ResourceNameW) callconv(.winapi) t.HACCEL;
pub extern "user32" fn CreateAcceleratorTableA(accels: [*]const s.ACCEL, count: i32) callconv(.winapi) t.HACCEL;
pub extern "user32" fn CreateAcceleratorTableW(accels: [*]const s.ACCEL, count: i32) callconv(.winapi) t.HACCEL;
pub extern "user32" fn DestroyAcceleratorTable(accel: t.HACCEL) callconv(.winapi) t.BOOL;
/// With `dst = null`, returns the number of entries.
pub extern "user32" fn CopyAcceleratorTableA(src: t.HACCEL, dst: ?[*]s.ACCEL, count: i32) callconv(.winapi) i32;
pub extern "user32" fn CopyAcceleratorTableW(src: t.HACCEL, dst: ?[*]s.ACCEL, count: i32) callconv(.winapi) i32;
/// Nonzero = translated; skip TranslateMessage / DispatchMessage.
pub extern "user32" fn TranslateAcceleratorA(hwnd: t.HWND, accel: t.HACCEL, msg: *const s.MSG) callconv(.winapi) i32;
pub extern "user32" fn TranslateAcceleratorW(hwnd: t.HWND, accel: t.HACCEL, msg: *const s.MSG) callconv(.winapi) i32;

// ---------------------------------------------------------------------------
// Resources: cursors / icons / bitmaps / images / strings
// ---------------------------------------------------------------------------
/// Use `ENUMS.SystemCursor.arrow.nameA()` for built-in cursors (with a `.null` instance).
pub extern "user32" fn LoadCursorA(instance: t.HINSTANCE, name: t.ResourceNameA) callconv(.winapi) t.HCURSOR;
/// Use `ENUMS.SystemCursor.arrow.nameW()` for built-in cursors (with a `.null` instance).
pub extern "user32" fn LoadCursorW(instance: t.HINSTANCE, name: t.ResourceNameW) callconv(.winapi) t.HCURSOR;
/// Loads a .cur or .ani file.
pub extern "user32" fn LoadCursorFromFileA(file_name: [*:0]const u8) callconv(.winapi) t.HCURSOR;
pub extern "user32" fn LoadCursorFromFileW(file_name: [*:0]const u16) callconv(.winapi) t.HCURSOR;
pub extern "user32" fn CreateCursor(
    instance: t.HINSTANCE,
    x_hotspot: i32,
    y_hotspot: i32,
    w: i32,
    h: i32,
    and_plane: *const anyopaque,
    xor_plane: *const anyopaque,
) callconv(.winapi) t.HCURSOR;
pub extern "user32" fn DestroyCursor(cursor: t.HCURSOR) callconv(.winapi) t.BOOL;
/// Replaces system cursor `id` (OCR_*) with `cursor`, and destroys `cursor`.
pub extern "user32" fn SetSystemCursor(cursor: t.HCURSOR, id: u32) callconv(.winapi) t.BOOL;

/// Use `ENUMS.SystemIcon.application.nameA()` for built-in icons (with a `.null` instance).
pub extern "user32" fn LoadIconA(instance: t.HINSTANCE, name: t.ResourceNameA) callconv(.winapi) t.HICON;
/// Use `ENUMS.SystemIcon.application.nameW()` for built-in icons (with a `.null` instance).
pub extern "user32" fn LoadIconW(instance: t.HINSTANCE, name: t.ResourceNameW) callconv(.winapi) t.HICON;
pub extern "user32" fn CreateIcon(
    instance: t.HINSTANCE,
    w: i32,
    h: i32,
    planes: u8,
    bits_per_pixel: u8,
    and_bits: [*]const u8,
    xor_bits: [*]const u8,
) callconv(.winapi) t.HICON;
pub extern "user32" fn CreateIconIndirect(info: *const s.ICONINFO) callconv(.winapi) t.HICON;
pub extern "user32" fn CopyIcon(icon: t.HICON) callconv(.winapi) t.HICON;
pub extern "user32" fn DestroyIcon(icon: t.HICON) callconv(.winapi) t.BOOL;
/// The caller owns (must DeleteObject) `info.mask` and `info.color`.
pub extern "user32" fn GetIconInfo(icon: t.HICON, info: *s.ICONINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetIconInfoExA(icon: t.HICON, info: *s.ICONINFOEXA) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetIconInfoExW(icon: t.HICON, info: *s.ICONINFOEXW) callconv(.winapi) t.BOOL;
/// `res_bits` is RT_GROUP_ICON / RT_GROUP_CURSOR data. Returns the best-matching resource id.
pub extern "user32" fn LookupIconIdFromDirectory(res_bits: [*]const u8, is_icon: t.BOOL) callconv(.winapi) i32;
pub extern "user32" fn LookupIconIdFromDirectoryEx(res_bits: [*]const u8, is_icon: t.BOOL, cx: i32, cy: i32, flags: e.LoadImageFlags) callconv(.winapi) i32;
/// `version` should be 0x00030000.
pub extern "user32" fn CreateIconFromResource(res_bits: [*]const u8, size: u32, is_icon: t.BOOL, version: u32) callconv(.winapi) t.HICON;
pub extern "user32" fn CreateIconFromResourceEx(
    res_bits: [*]const u8,
    size: u32,
    is_icon: t.BOOL,
    version: u32,
    cx: i32,
    cy: i32,
    flags: e.LoadImageFlags,
) callconv(.winapi) t.HICON;
/// `icons` / `ids` may be null to count. `flags`: LR_* flags.
pub extern "user32" fn PrivateExtractIconsA(
    file_name: [*:0]const u8,
    icon_index: i32,
    cx: i32,
    cy: i32,
    icons: ?[*]t.HICON,
    ids: ?[*]u32,
    count: u32,
    flags: u32,
) callconv(.winapi) u32;
pub extern "user32" fn PrivateExtractIconsW(
    file_name: [*:0]const u16,
    icon_index: i32,
    cx: i32,
    cy: i32,
    icons: ?[*]t.HICON,
    ids: ?[*]u32,
    count: u32,
    flags: u32,
) callconv(.winapi) u32;

pub extern "user32" fn LoadBitmapA(instance: t.HINSTANCE, name: t.ResourceNameA) callconv(.winapi) t.HBITMAP;
pub extern "user32" fn LoadBitmapW(instance: t.HINSTANCE, name: t.ResourceNameW) callconv(.winapi) t.HBITMAP;
/// Returns an HBITMAP / HICON / HCURSOR as a HANDLE. With `.load_from_file`, `name` is a path.
pub extern "user32" fn LoadImageA(
    instance: t.HINSTANCE,
    name: t.ResourceNameA,
    kind: e.ImageType,
    cx: i32,
    cy: i32,
    flags: e.LoadImageFlags,
) callconv(.winapi) t.HANDLE;
pub extern "user32" fn LoadImageW(
    instance: t.HINSTANCE,
    name: t.ResourceNameW,
    kind: e.ImageType,
    cx: i32,
    cy: i32,
    flags: e.LoadImageFlags,
) callconv(.winapi) t.HANDLE;
pub extern "user32" fn CopyImage(image: t.HANDLE, kind: e.ImageType, cx: i32, cy: i32, flags: e.LoadImageFlags) callconv(.winapi) t.HANDLE;

/// Returns chars copied. With `buf_len = 0`, `buf` receives a read-only pointer into the resource.
pub extern "user32" fn LoadStringA(instance: t.HINSTANCE, id: u32, buf: [*]u8, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn LoadStringW(instance: t.HINSTANCE, id: u32, buf: [*]u16, buf_len: i32) callconv(.winapi) i32;

// ---------------------------------------------------------------------------
// Cursor / caret
// ---------------------------------------------------------------------------
pub extern "user32" fn SetCursor(cursor: t.HCURSOR) callconv(.winapi) t.HCURSOR;
pub extern "user32" fn GetCursor() callconv(.winapi) t.HCURSOR;
/// Returns the new display counter (cursor shows when >= 0).
pub extern "user32" fn ShowCursor(show: t.BOOL) callconv(.winapi) i32;
pub extern "user32" fn GetCursorPos(point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetCursorPos(x: i32, y: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPhysicalCursorPos(point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetPhysicalCursorPos(x: i32, y: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetCursorInfo(info: *s.CURSORINFO) callconv(.winapi) t.BOOL;
/// Confines the cursor to `rect` (screen coordinates); null releases it.
pub extern "user32" fn ClipCursor(rect: ?*const s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetClipCursor(rect: *s.RECT) callconv(.winapi) t.BOOL;

/// `bitmap`: `.null` for a solid caret, `@enumFromInt(1)` for gray, or a bitmap.
pub extern "user32" fn CreateCaret(hwnd: t.HWND, bitmap: t.HBITMAP, w: i32, h: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn DestroyCaret() callconv(.winapi) t.BOOL;
pub extern "user32" fn HideCaret(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn ShowCaret(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetCaretPos(x: i32, y: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetCaretPos(point: *s.POINT) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetCaretBlinkTime() callconv(.winapi) u32;
pub extern "user32" fn SetCaretBlinkTime(ms: u32) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Focus / activation / capture
// ---------------------------------------------------------------------------
pub extern "user32" fn SetFocus(hwnd: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn GetFocus() callconv(.winapi) t.HWND;
pub extern "user32" fn GetActiveWindow() callconv(.winapi) t.HWND;
pub extern "user32" fn SetActiveWindow(hwnd: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn GetForegroundWindow() callconv(.winapi) t.HWND;
pub extern "user32" fn SetForegroundWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
/// `process_id` ASFW_ANY (0xFFFFFFFF) = any process.
pub extern "user32" fn AllowSetForegroundWindow(process_id: u32) callconv(.winapi) t.BOOL;
/// `lock_code`: LSFW_LOCK (1) / LSFW_UNLOCK (2).
pub extern "user32" fn LockSetForegroundWindow(lock_code: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SwitchToThisWindow(hwnd: t.HWND, alt_tab: t.BOOL) callconv(.winapi) void;
pub extern "user32" fn SetCapture(hwnd: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn GetCapture() callconv(.winapi) t.HWND;
pub extern "user32" fn ReleaseCapture() callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Keyboard input
// ---------------------------------------------------------------------------
/// High bit set = key down. `vkey` is a VK_* code.
pub extern "user32" fn GetKeyState(vkey: i32) callconv(.winapi) i16;
pub extern "user32" fn GetAsyncKeyState(vkey: i32) callconv(.winapi) i16;
pub extern "user32" fn GetKeyboardState(state: *[256]u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetKeyboardState(state: *const [256]u8) callconv(.winapi) t.BOOL;
/// `l_param` is the WM_KEYDOWN lParam (scan code in bits 16-23, extended in bit 24).
pub extern "user32" fn GetKeyNameTextA(l_param: i32, buf: [*]u8, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetKeyNameTextW(l_param: i32, buf: [*]u16, buf_len: i32) callconv(.winapi) i32;
/// `type_flag`: 0 = type, 1 = subtype, 2 = number of function keys.
pub extern "user32" fn GetKeyboardType(type_flag: i32) callconv(.winapi) i32;
pub extern "user32" fn MapVirtualKeyA(code: u32, map_type: e.MapVirtualKeyType) callconv(.winapi) u32;
pub extern "user32" fn MapVirtualKeyW(code: u32, map_type: e.MapVirtualKeyType) callconv(.winapi) u32;
pub extern "user32" fn MapVirtualKeyExA(code: u32, map_type: e.MapVirtualKeyType, layout: t.HKL) callconv(.winapi) u32;
pub extern "user32" fn MapVirtualKeyExW(code: u32, map_type: e.MapVirtualKeyType, layout: t.HKL) callconv(.winapi) u32;
/// Returns chars written (negative for a dead key, 0 for none).
pub extern "user32" fn ToUnicode(
    vkey: u32,
    scan_code: u32,
    key_state: ?*const [256]u8,
    buf: [*]u16,
    buf_len: i32,
    flags: u32,
) callconv(.winapi) i32;
pub extern "user32" fn ToUnicodeEx(
    vkey: u32,
    scan_code: u32,
    key_state: ?*const [256]u8,
    buf: [*]u16,
    buf_len: i32,
    flags: u32,
    layout: t.HKL,
) callconv(.winapi) i32;
pub extern "user32" fn ToAscii(vkey: u32, scan_code: u32, key_state: ?*const [256]u8, out: *u16, flags: u32) callconv(.winapi) i32;
pub extern "user32" fn ToAsciiEx(vkey: u32, scan_code: u32, key_state: ?*const [256]u8, out: *u16, flags: u32, layout: t.HKL) callconv(.winapi) i32;
/// Low byte: VK code, high byte: shift state. -1 if no key maps to `ch`.
pub extern "user32" fn VkKeyScanA(ch: u8) callconv(.winapi) i16;
pub extern "user32" fn VkKeyScanW(ch: u16) callconv(.winapi) i16;
pub extern "user32" fn VkKeyScanExA(ch: u8, layout: t.HKL) callconv(.winapi) i16;
pub extern "user32" fn VkKeyScanExW(ch: u16, layout: t.HKL) callconv(.winapi) i16;
pub extern "user32" fn OemKeyScan(oem_char: u16) callconv(.winapi) u32;
/// Obsolete; use SendInput.
pub extern "user32" fn keybd_event(vkey: u8, scan: u8, flags: e.KeyEventFlags, extra_info: usize) callconv(.winapi) void;

/// `klid` is an 8-hex-digit layout id, e.g. "00000409". `flags`: KLF_*.
pub extern "user32" fn LoadKeyboardLayoutA(klid: [*:0]const u8, flags: u32) callconv(.winapi) t.HKL;
pub extern "user32" fn LoadKeyboardLayoutW(klid: [*:0]const u16, flags: u32) callconv(.winapi) t.HKL;
pub extern "user32" fn ActivateKeyboardLayout(layout: t.HKL, flags: u32) callconv(.winapi) t.HKL;
pub extern "user32" fn UnloadKeyboardLayout(layout: t.HKL) callconv(.winapi) t.BOOL;
/// KL_NAMELENGTH = 9 (including the terminator).
pub extern "user32" fn GetKeyboardLayoutNameA(buf: *[9]u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetKeyboardLayoutNameW(buf: *[9]u16) callconv(.winapi) t.BOOL;
/// With `count = 0`, returns the number of layouts.
pub extern "user32" fn GetKeyboardLayoutList(count: i32, list: ?[*]t.HKL) callconv(.winapi) i32;
/// `thread_id` 0 = current thread.
pub extern "user32" fn GetKeyboardLayout(thread_id: u32) callconv(.winapi) t.HKL;
pub extern "user32" fn GetKBCodePage() callconv(.winapi) u32;

/// Posts WM_HOTKEY to `hwnd` (or the thread when `.null`).
pub extern "user32" fn RegisterHotKey(hwnd: t.HWND, id: i32, modifiers: e.HotKeyModifiers, vkey: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn UnregisterHotKey(hwnd: t.HWND, id: i32) callconv(.winapi) t.BOOL;
/// Requires elevation.
pub extern "user32" fn BlockInput(block: t.BOOL) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Mouse input / synthesized input
// ---------------------------------------------------------------------------
pub extern "user32" fn TrackMouseEvent(event: *s.TRACKMOUSEEVENT) callconv(.winapi) t.BOOL;
/// `resolution`: GMMP_USE_DISPLAY_POINTS (1) / GMMP_USE_HIGH_RESOLUTION_POINTS (2).
pub extern "user32" fn GetMouseMovePointsEx(
    size: u32,
    point: *const s.MOUSEMOVEPOINT,
    buf: [*]s.MOUSEMOVEPOINT,
    buf_len: i32,
    resolution: u32,
) callconv(.winapi) i32;
pub extern "user32" fn GetDoubleClickTime() callconv(.winapi) u32;
pub extern "user32" fn SetDoubleClickTime(ms: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SwapMouseButton(swap: t.BOOL) callconv(.winapi) t.BOOL;
/// Obsolete; use SendInput.
pub extern "user32" fn mouse_event(flags: e.MouseEventFlags, dx: u32, dy: u32, data: u32, extra_info: usize) callconv(.winapi) void;
/// `size` = `@sizeOf(STRUCTS.INPUT)`. Returns the number of events inserted.
pub extern "user32" fn SendInput(count: u32, inputs: [*]const s.INPUT, size: i32) callconv(.winapi) u32;
pub extern "user32" fn GetLastInputInfo(info: *s.LASTINPUTINFO) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Raw input
// ---------------------------------------------------------------------------
/// `header_size` = `@sizeOf(STRUCTS.RAWINPUTHEADER)`. Call with `data = null` first to get the size.
pub extern "user32" fn GetRawInputData(
    raw: t.HRAWINPUT,
    command: e.RawInputCommand,
    data: ?*anyopaque,
    size: *u32,
    header_size: u32,
) callconv(.winapi) u32;
pub extern "user32" fn GetRawInputDeviceInfoA(device: t.HANDLE, command: e.RawInputDeviceInfoCommand, data: ?*anyopaque, size: *u32) callconv(.winapi) u32;
/// For `.device_name`, `size` is in characters.
pub extern "user32" fn GetRawInputDeviceInfoW(device: t.HANDLE, command: e.RawInputDeviceInfoCommand, data: ?*anyopaque, size: *u32) callconv(.winapi) u32;
/// Buffered read; entries are 8-byte aligned (NEXTRAWINPUTBLOCK).
pub extern "user32" fn GetRawInputBuffer(data: ?*s.RAWINPUT, size: *u32, header_size: u32) callconv(.winapi) u32;
pub extern "user32" fn RegisterRawInputDevices(devices: [*]const s.RAWINPUTDEVICE, count: u32, size: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetRegisteredRawInputDevices(devices: ?[*]s.RAWINPUTDEVICE, count: *u32, size: u32) callconv(.winapi) u32;
pub extern "user32" fn GetRawInputDeviceList(list: ?[*]s.RAWINPUTDEVICELIST, count: *u32, size: u32) callconv(.winapi) u32;
pub extern "user32" fn DefRawInputProc(raw: [*]const *s.RAWINPUT, count: i32, header_size: u32) callconv(.winapi) t.LRESULT;

// ---------------------------------------------------------------------------
// Touch / gestures (WM_TOUCH / WM_GESTURE)
// ---------------------------------------------------------------------------
/// `size` = `@sizeOf(STRUCTS.TOUCHINPUT)`.
pub extern "user32" fn GetTouchInputInfo(touch: t.HTOUCHINPUT, count: u32, inputs: [*]s.TOUCHINPUT, size: i32) callconv(.winapi) t.BOOL;
pub extern "user32" fn CloseTouchInputHandle(touch: t.HTOUCHINPUT) callconv(.winapi) t.BOOL;
/// `flags`: TWF_FINETOUCH (1) | TWF_WANTPALM (2).
pub extern "user32" fn RegisterTouchWindow(hwnd: t.HWND, flags: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn UnregisterTouchWindow(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsTouchWindow(hwnd: t.HWND, flags: ?*u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetGestureInfo(gesture: t.HGESTUREINFO, info: *s.GESTUREINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetGestureExtraArgs(gesture: t.HGESTUREINFO, size: u32, args: [*]u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn CloseGestureInfoHandle(gesture: t.HGESTUREINFO) callconv(.winapi) t.BOOL;
/// `size` = `@sizeOf(STRUCTS.GESTURECONFIG)`.
pub extern "user32" fn SetGestureConfig(hwnd: t.HWND, reserved: u32, count: u32, configs: [*]const s.GESTURECONFIG, size: u32) callconv(.winapi) t.BOOL;
/// `flags`: GCF_INCLUDE_ANCESTORS (1).
pub extern "user32" fn GetGestureConfig(hwnd: t.HWND, reserved: u32, flags: u32, count: *u32, configs: [*]s.GESTURECONFIG, size: u32) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Pointer input (WM_POINTER*)
// ---------------------------------------------------------------------------
pub extern "user32" fn GetPointerType(pointer_id: u32, kind: *e.PointerInputType) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerCursorId(pointer_id: u32, cursor_id: *u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerInfo(pointer_id: u32, info: *s.POINTER_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerInfoHistory(pointer_id: u32, entries: *u32, info: ?[*]s.POINTER_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerFrameInfo(pointer_id: u32, count: *u32, info: ?[*]s.POINTER_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerFrameInfoHistory(pointer_id: u32, entries: *u32, count: *u32, info: ?[*]s.POINTER_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerTouchInfo(pointer_id: u32, info: *s.POINTER_TOUCH_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerTouchInfoHistory(pointer_id: u32, entries: *u32, info: ?[*]s.POINTER_TOUCH_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerFrameTouchInfo(pointer_id: u32, count: *u32, info: ?[*]s.POINTER_TOUCH_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerFrameTouchInfoHistory(pointer_id: u32, entries: *u32, count: *u32, info: ?[*]s.POINTER_TOUCH_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerPenInfo(pointer_id: u32, info: *s.POINTER_PEN_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerPenInfoHistory(pointer_id: u32, entries: *u32, info: ?[*]s.POINTER_PEN_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerFramePenInfo(pointer_id: u32, count: *u32, info: ?[*]s.POINTER_PEN_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerFramePenInfoHistory(pointer_id: u32, entries: *u32, count: *u32, info: ?[*]s.POINTER_PEN_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerInputTransform(pointer_id: u32, history_count: u32, transform: [*]s.INPUT_TRANSFORM) callconv(.winapi) t.BOOL;
pub extern "user32" fn SkipPointerFrameMessages(pointer_id: u32) callconv(.winapi) t.BOOL;

pub extern "user32" fn RegisterPointerInputTarget(hwnd: t.HWND, kind: e.PointerInputType) callconv(.winapi) t.BOOL;
pub extern "user32" fn RegisterPointerInputTargetEx(hwnd: t.HWND, kind: e.PointerInputType, observe: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn UnregisterPointerInputTarget(hwnd: t.HWND, kind: e.PointerInputType) callconv(.winapi) t.BOOL;
pub extern "user32" fn UnregisterPointerInputTargetEx(hwnd: t.HWND, kind: e.PointerInputType) callconv(.winapi) t.BOOL;
/// Route mouse through WM_POINTER*. Can only be called once per process, before any window exists.
pub extern "user32" fn EnableMouseInPointer(enable: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsMouseInPointerEnabled() callconv(.winapi) t.BOOL;

pub extern "user32" fn GetPointerDevices(count: *u32, devices: ?[*]s.POINTER_DEVICE_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerDevice(device: t.HANDLE, info: *s.POINTER_DEVICE_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerDeviceProperties(device: t.HANDLE, count: *u32, properties: ?[*]s.POINTER_DEVICE_PROPERTY) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerDeviceRects(device: t.HANDLE, device_rect: *s.RECT, display_rect: *s.RECT) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetPointerDeviceCursors(device: t.HANDLE, count: *u32, cursors: ?[*]s.POINTER_DEVICE_CURSOR_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn RegisterPointerDeviceNotifications(hwnd: t.HWND, notify_range: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetRawPointerDeviceData(
    pointer_id: u32,
    history_count: u32,
    properties_count: u32,
    properties: [*]s.POINTER_DEVICE_PROPERTY,
    values: [*]i32,
) callconv(.winapi) t.BOOL;

/// `mode`: TOUCH_FEEDBACK_DEFAULT (1) / INDIRECT (2) / NONE (3).
pub extern "user32" fn InitializeTouchInjection(max_count: u32, mode: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn InjectTouchInput(count: u32, contacts: [*]const s.POINTER_TOUCH_INFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn CreateSyntheticPointerDevice(kind: e.PointerInputType, max_count: u32, mode: e.PointerFeedbackMode) callconv(.winapi) t.HSYNTHETICPOINTERDEVICE;
pub extern "user32" fn InjectSyntheticPointerInput(device: t.HSYNTHETICPOINTERDEVICE, info: [*]const s.POINTER_TYPE_INFO, count: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn DestroySyntheticPointerDevice(device: t.HSYNTHETICPOINTERDEVICE) callconv(.winapi) void;

/// `value`: TOUCH_HIT_TESTING_DEFAULT (0) / CLIENT (1) / NONE (2).
pub extern "user32" fn RegisterTouchHitTestingWindow(hwnd: t.HWND, value: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn EvaluateProximityToRect(
    bounding_box: *const s.RECT,
    input: *const s.TOUCH_HIT_TESTING_INPUT,
    eval: *s.TOUCH_HIT_TESTING_PROXIMITY_EVALUATION,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn EvaluateProximityToPolygon(
    num_vertices: u32,
    polygon: [*]const s.POINT,
    input: *const s.TOUCH_HIT_TESTING_INPUT,
    eval: *s.TOUCH_HIT_TESTING_PROXIMITY_EVALUATION,
) callconv(.winapi) t.BOOL;
/// Return value for WM_TOUCHHITTESTING.
pub extern "user32" fn PackTouchHitTestingProximityEvaluation(
    input: *const s.TOUCH_HIT_TESTING_INPUT,
    eval: *const s.TOUCH_HIT_TESTING_PROXIMITY_EVALUATION,
) callconv(.winapi) t.LRESULT;
/// `config` is a BOOL for every FEEDBACK_TYPE. `flags`: GWFS_INCLUDE_ANCESTORS (1).
pub extern "user32" fn GetWindowFeedbackSetting(hwnd: t.HWND, feedback: e.FeedbackType, flags: u32, size: *u32, config: ?*anyopaque) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetWindowFeedbackSetting(hwnd: t.HWND, feedback: e.FeedbackType, flags: u32, size: u32, config: ?*const anyopaque) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Clipboard
// ---------------------------------------------------------------------------
pub extern "user32" fn OpenClipboard(new_owner: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn CloseClipboard() callconv(.winapi) t.BOOL;
pub extern "user32" fn EmptyClipboard() callconv(.winapi) t.BOOL;
/// `mem` is an HGLOBAL (GMEM_MOVEABLE); the system owns it after success.
pub extern "user32" fn SetClipboardData(format: u32, mem: t.HANDLE) callconv(.winapi) t.HANDLE;
/// The handle is owned by the clipboard; GlobalLock it, copy, unlock.
pub extern "user32" fn GetClipboardData(format: u32) callconv(.winapi) t.HANDLE;
pub extern "user32" fn IsClipboardFormatAvailable(format: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn CountClipboardFormats() callconv(.winapi) i32;
/// Pass 0 to start; returns 0 when done.
pub extern "user32" fn EnumClipboardFormats(format: u32) callconv(.winapi) u32;
/// Returns the first available format in `priority`, 0 if the clipboard is empty, -1 if none match.
pub extern "user32" fn GetPriorityClipboardFormat(priority: [*]const u32, count: i32) callconv(.winapi) i32;
pub extern "user32" fn GetUpdatedClipboardFormats(formats: [*]u32, count: u32, count_out: *u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn RegisterClipboardFormatA(name: [*:0]const u8) callconv(.winapi) u32;
pub extern "user32" fn RegisterClipboardFormatW(name: [*:0]const u16) callconv(.winapi) u32;
pub extern "user32" fn GetClipboardFormatNameA(format: u32, buf: [*]u8, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetClipboardFormatNameW(format: u32, buf: [*]u16, buf_len: i32) callconv(.winapi) i32;
pub extern "user32" fn GetClipboardSequenceNumber() callconv(.winapi) u32;
pub extern "user32" fn GetClipboardOwner() callconv(.winapi) t.HWND;
pub extern "user32" fn GetOpenClipboardWindow() callconv(.winapi) t.HWND;
/// Delivers WM_CLIPBOARDUPDATE. Preferred over the viewer chain below.
pub extern "user32" fn AddClipboardFormatListener(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn RemoveClipboardFormatListener(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetClipboardViewer(new_viewer: t.HWND) callconv(.winapi) t.HWND;
pub extern "user32" fn GetClipboardViewer() callconv(.winapi) t.HWND;
pub extern "user32" fn ChangeClipboardChain(remove: t.HWND, new_next: t.HWND) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Desktops / window stations / user objects
// ---------------------------------------------------------------------------
/// `device` and `dev_mode` are reserved (null). `flags`: DF_ALLOWOTHERACCOUNTHOOK (1).
pub extern "user32" fn CreateDesktopA(
    desktop: [*:0]const u8,
    device: ?[*:0]const u8,
    dev_mode: ?*s.DEVMODEA,
    flags: u32,
    desired_access: t.ACCESS_MASK,
    attributes: ?*const s.SECURITY_ATTRIBUTES,
) callconv(.winapi) t.HDESK;
pub extern "user32" fn CreateDesktopW(
    desktop: [*:0]const u16,
    device: ?[*:0]const u16,
    dev_mode: ?*s.DEVMODEW,
    flags: u32,
    desired_access: t.ACCESS_MASK,
    attributes: ?*const s.SECURITY_ATTRIBUTES,
) callconv(.winapi) t.HDESK;
/// `heap_size_kb` is the desktop heap size in KB.
pub extern "user32" fn CreateDesktopExA(
    desktop: [*:0]const u8,
    device: ?[*:0]const u8,
    dev_mode: ?*s.DEVMODEA,
    flags: u32,
    desired_access: t.ACCESS_MASK,
    attributes: ?*const s.SECURITY_ATTRIBUTES,
    heap_size_kb: u32,
    reserved: ?*anyopaque,
) callconv(.winapi) t.HDESK;
pub extern "user32" fn CreateDesktopExW(
    desktop: [*:0]const u16,
    device: ?[*:0]const u16,
    dev_mode: ?*s.DEVMODEW,
    flags: u32,
    desired_access: t.ACCESS_MASK,
    attributes: ?*const s.SECURITY_ATTRIBUTES,
    heap_size_kb: u32,
    reserved: ?*anyopaque,
) callconv(.winapi) t.HDESK;
pub extern "user32" fn OpenDesktopA(desktop: [*:0]const u8, flags: u32, inherit: t.BOOL, desired_access: t.ACCESS_MASK) callconv(.winapi) t.HDESK;
pub extern "user32" fn OpenDesktopW(desktop: [*:0]const u16, flags: u32, inherit: t.BOOL, desired_access: t.ACCESS_MASK) callconv(.winapi) t.HDESK;
pub extern "user32" fn OpenInputDesktop(flags: u32, inherit: t.BOOL, desired_access: t.ACCESS_MASK) callconv(.winapi) t.HDESK;
/// `winsta` `.null` = the current process window station.
pub extern "user32" fn EnumDesktopsA(winsta: t.HWINSTA, func: t.DesktopEnumProcA, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumDesktopsW(winsta: t.HWINSTA, func: t.DesktopEnumProcW, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumDesktopWindows(desktop: t.HDESK, func: t.WndEnumProc, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn SwitchDesktop(desktop: t.HDESK) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetThreadDesktop(desktop: t.HDESK) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetThreadDesktop(thread_id: u32) callconv(.winapi) t.HDESK;
pub extern "user32" fn CloseDesktop(desktop: t.HDESK) callconv(.winapi) t.BOOL;

/// `flags`: CWF_CREATE_ONLY (1).
pub extern "user32" fn CreateWindowStationA(name: ?[*:0]const u8, flags: u32, desired_access: t.ACCESS_MASK, attributes: ?*const s.SECURITY_ATTRIBUTES) callconv(.winapi) t.HWINSTA;
pub extern "user32" fn CreateWindowStationW(name: ?[*:0]const u16, flags: u32, desired_access: t.ACCESS_MASK, attributes: ?*const s.SECURITY_ATTRIBUTES) callconv(.winapi) t.HWINSTA;
pub extern "user32" fn OpenWindowStationA(name: [*:0]const u8, inherit: t.BOOL, desired_access: t.ACCESS_MASK) callconv(.winapi) t.HWINSTA;
pub extern "user32" fn OpenWindowStationW(name: [*:0]const u16, inherit: t.BOOL, desired_access: t.ACCESS_MASK) callconv(.winapi) t.HWINSTA;
pub extern "user32" fn EnumWindowStationsA(func: t.WinStaEnumProcA, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumWindowStationsW(func: t.WinStaEnumProcW, l_param: t.LPARAM) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetProcessWindowStation() callconv(.winapi) t.HWINSTA;
pub extern "user32" fn SetProcessWindowStation(winsta: t.HWINSTA) callconv(.winapi) t.BOOL;
pub extern "user32" fn CloseWindowStation(winsta: t.HWINSTA) callconv(.winapi) t.BOOL;

/// `object` is an HDESK / HWINSTA as a HANDLE. `index`: UOI_FLAGS (1) / UOI_NAME (2) / UOI_TYPE (3) / ...
pub extern "user32" fn GetUserObjectInformationA(object: t.HANDLE, index: i32, info: ?*anyopaque, len: u32, len_needed: ?*u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetUserObjectInformationW(object: t.HANDLE, index: i32, info: ?*anyopaque, len: u32, len_needed: ?*u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetUserObjectInformationA(object: t.HANDLE, index: i32, info: *anyopaque, len: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetUserObjectInformationW(object: t.HANDLE, index: i32, info: *anyopaque, len: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetUserObjectSecurity(
    object: t.HANDLE,
    requested: *const t.SECURITY_INFORMATION,
    descriptor: t.PSECURITY_DESCRIPTOR,
    len: u32,
    len_needed: *u32,
) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetUserObjectSecurity(object: t.HANDLE, requested: *const t.SECURITY_INFORMATION, descriptor: t.PSECURITY_DESCRIPTOR) callconv(.winapi) t.BOOL;
/// Grants a job object access to a USER handle.
pub extern "user32" fn UserHandleGrantAccess(user_handle: t.HANDLE, job: t.HANDLE, grant: t.BOOL) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// DPI
// ---------------------------------------------------------------------------
pub extern "user32" fn SetProcessDpiAwarenessContext(context: e.DpiAwarenessContext) callconv(.winapi) t.BOOL;
/// Returns the previous context.
pub extern "user32" fn SetThreadDpiAwarenessContext(context: e.DpiAwarenessContext) callconv(.winapi) e.DpiAwarenessContext;
pub extern "user32" fn GetThreadDpiAwarenessContext() callconv(.winapi) e.DpiAwarenessContext;
pub extern "user32" fn GetWindowDpiAwarenessContext(hwnd: t.HWND) callconv(.winapi) e.DpiAwarenessContext;
pub extern "user32" fn GetDpiAwarenessContextForProcess(process: t.HANDLE) callconv(.winapi) e.DpiAwarenessContext;
pub extern "user32" fn GetAwarenessFromDpiAwarenessContext(context: e.DpiAwarenessContext) callconv(.winapi) e.DpiAwareness;
pub extern "user32" fn GetDpiFromDpiAwarenessContext(context: e.DpiAwarenessContext) callconv(.winapi) u32;
pub extern "user32" fn AreDpiAwarenessContextsEqual(a: e.DpiAwarenessContext, b: e.DpiAwarenessContext) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsValidDpiAwarenessContext(context: e.DpiAwarenessContext) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetThreadDpiHostingBehavior(value: e.DpiHostingBehavior) callconv(.winapi) e.DpiHostingBehavior;
pub extern "user32" fn GetThreadDpiHostingBehavior() callconv(.winapi) e.DpiHostingBehavior;
pub extern "user32" fn GetWindowDpiHostingBehavior(hwnd: t.HWND) callconv(.winapi) e.DpiHostingBehavior;
pub extern "user32" fn GetDpiForWindow(hwnd: t.HWND) callconv(.winapi) u32;
pub extern "user32" fn GetDpiForSystem() callconv(.winapi) u32;
pub extern "user32" fn GetSystemDpiForProcess(process: t.HANDLE) callconv(.winapi) u32;
/// Call from WM_NCCREATE (per-monitor v1 only; v2 does this automatically).
pub extern "user32" fn EnableNonClientDpiScaling(hwnd: t.HWND) callconv(.winapi) t.BOOL;
pub extern "user32" fn InheritWindowMonitor(hwnd: t.HWND, inherit: t.HWND) callconv(.winapi) t.BOOL;
/// Legacy (Vista) system-DPI awareness; prefer SetProcessDpiAwarenessContext.
pub extern "user32" fn SetProcessDPIAware() callconv(.winapi) t.BOOL;
pub extern "user32" fn IsProcessDPIAware() callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Monitors / display settings
// ---------------------------------------------------------------------------
pub extern "user32" fn MonitorFromWindow(hwnd: t.HWND, flags: e.MonitorDefault) callconv(.winapi) t.HMONITOR;
pub extern "user32" fn MonitorFromPoint(point: s.POINT, flags: e.MonitorDefault) callconv(.winapi) t.HMONITOR;
pub extern "user32" fn MonitorFromRect(rect: *const s.RECT, flags: e.MonitorDefault) callconv(.winapi) t.HMONITOR;
/// `info` may also be a MONITORINFOEX (`@ptrCast`); its `size` field selects which.
pub extern "user32" fn GetMonitorInfoA(monitor: t.HMONITOR, info: *s.MONITORINFO) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetMonitorInfoW(monitor: t.HMONITOR, info: *s.MONITORINFO) callconv(.winapi) t.BOOL;
/// `hdc` `.null` + `clip` null = every monitor on the virtual screen.
pub extern "user32" fn EnumDisplayMonitors(hdc: t.HDC, clip: ?*const s.RECT, func: t.MonitorEnumProc, data: t.LPARAM) callconv(.winapi) t.BOOL;

/// `device` null = primary display. `dev_num` counts up from 0 until it returns `.false`.
pub extern "user32" fn EnumDisplayDevicesA(device: ?[*:0]const u8, dev_num: u32, info: *s.DISPLAY_DEVICEA, flags: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumDisplayDevicesW(device: ?[*:0]const u16, dev_num: u32, info: *s.DISPLAY_DEVICEW, flags: u32) callconv(.winapi) t.BOOL;
/// `mode_num` counts up from 0, or ENUM_CURRENT_SETTINGS / ENUM_REGISTRY_SETTINGS.
pub extern "user32" fn EnumDisplaySettingsA(device: ?[*:0]const u8, mode_num: u32, mode: *s.DEVMODEA) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumDisplaySettingsW(device: ?[*:0]const u16, mode_num: u32, mode: *s.DEVMODEW) callconv(.winapi) t.BOOL;
/// `flags`: EDS_RAWMODE (2) | EDS_ROTATEDMODE (4).
pub extern "user32" fn EnumDisplaySettingsExA(device: ?[*:0]const u8, mode_num: u32, mode: *s.DEVMODEA, flags: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn EnumDisplaySettingsExW(device: ?[*:0]const u16, mode_num: u32, mode: *s.DEVMODEW, flags: u32) callconv(.winapi) t.BOOL;
/// `flags`: CDS_*. Returns DISP_CHANGE_* (0 = success).
pub extern "user32" fn ChangeDisplaySettingsA(mode: ?*s.DEVMODEA, flags: u32) callconv(.winapi) i32;
pub extern "user32" fn ChangeDisplaySettingsW(mode: ?*s.DEVMODEW, flags: u32) callconv(.winapi) i32;
pub extern "user32" fn ChangeDisplaySettingsExA(device: ?[*:0]const u8, mode: ?*s.DEVMODEA, reserved: t.HWND, flags: u32, param: ?*anyopaque) callconv(.winapi) i32;
pub extern "user32" fn ChangeDisplaySettingsExW(device: ?[*:0]const u16, mode: ?*s.DEVMODEW, reserved: t.HWND, flags: u32, param: ?*anyopaque) callconv(.winapi) i32;

/// `flags`: QDC_ALL_PATHS (1) / QDC_ONLY_ACTIVE_PATHS (2) / QDC_DATABASE_CURRENT (4). Returns a Win32 error code.
pub extern "user32" fn GetDisplayConfigBufferSizes(flags: u32, num_paths: *u32, num_modes: *u32) callconv(.winapi) i32;
pub extern "user32" fn QueryDisplayConfig(
    flags: u32,
    num_paths: *u32,
    paths: [*]s.DISPLAYCONFIG_PATH_INFO,
    num_modes: *u32,
    modes: [*]s.DISPLAYCONFIG_MODE_INFO,
    /// Only with QDC_DATABASE_CURRENT; DISPLAYCONFIG_TOPOLOGY_ID.
    current_topology_id: ?*u32,
) callconv(.winapi) i32;
/// `flags`: SDC_*.
pub extern "user32" fn SetDisplayConfig(
    num_paths: u32,
    paths: ?[*]s.DISPLAYCONFIG_PATH_INFO,
    num_modes: u32,
    modes: ?[*]s.DISPLAYCONFIG_MODE_INFO,
    flags: u32,
) callconv(.winapi) i32;
/// `packet` is the header of a DISPLAYCONFIG_* request struct.
pub extern "user32" fn DisplayConfigGetDeviceInfo(packet: *s.DISPLAYCONFIG_DEVICE_INFO_HEADER) callconv(.winapi) i32;
pub extern "user32" fn DisplayConfigSetDeviceInfo(packet: *s.DISPLAYCONFIG_DEVICE_INFO_HEADER) callconv(.winapi) i32;

pub extern "user32" fn GetAutoRotationState(state: *e.AutoRotationState) callconv(.winapi) t.BOOL;
pub extern "user32" fn GetDisplayAutoRotationPreferences(orientation: *e.OrientationPreference) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetDisplayAutoRotationPreferences(orientation: e.OrientationPreference) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// System metrics / parameters / session
// ---------------------------------------------------------------------------
pub extern "user32" fn GetSystemMetrics(index: e.SystemMetric) callconv(.winapi) i32;
pub extern "user32" fn GetSystemMetricsForDpi(index: e.SystemMetric, dpi: u32) callconv(.winapi) i32;
/// `action`: SPI_*. `win_ini`: SPIF_UPDATEINIFILE (1) | SPIF_SENDCHANGE (2).
pub extern "user32" fn SystemParametersInfoA(action: u32, param: u32, pv_param: ?*anyopaque, win_ini: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SystemParametersInfoW(action: u32, param: u32, pv_param: ?*anyopaque, win_ini: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn SystemParametersInfoForDpi(action: u32, param: u32, pv_param: ?*anyopaque, win_ini: u32, dpi: u32) callconv(.winapi) t.BOOL;

/// `flags`: EWX_*. `reason`: SHTDN_REASON_*.
pub extern "user32" fn ExitWindowsEx(flags: u32, reason: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn LockWorkStation() callconv(.winapi) t.BOOL;
pub extern "user32" fn CancelShutdown() callconv(.winapi) t.BOOL;
pub extern "user32" fn ShutdownBlockReasonCreate(hwnd: t.HWND, reason: [*:0]const u16) callconv(.winapi) t.BOOL;
/// With `buf = null`, `buf_len` receives the required length.
pub extern "user32" fn ShutdownBlockReasonQuery(hwnd: t.HWND, buf: ?[*]u16, buf_len: *u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn ShutdownBlockReasonDestroy(hwnd: t.HWND) callconv(.winapi) t.BOOL;

/// `flags`: GR_GDIOBJECTS (0) / GR_USEROBJECTS (1) / *_PEAK (2 / 4).
pub extern "user32" fn GetGuiResources(process: t.HANDLE, flags: u32) callconv(.winapi) u32;
pub extern "user32" fn IsImmersiveProcess(process: t.HANDLE) callconv(.winapi) t.BOOL;
pub extern "user32" fn SetProcessRestrictionExemption(enable: t.BOOL) callconv(.winapi) t.BOOL;
pub extern "user32" fn SoundSentry() callconv(.winapi) t.BOOL;
pub extern "user32" fn SetDebugErrorLevel(level: u32) callconv(.winapi) void;
pub extern "user32" fn SetLastErrorEx(code: u32, kind: u32) callconv(.winapi) void;
/// Legacy WinHelp (.hlp); `command`: HELP_*.
pub extern "user32" fn WinHelpA(hwnd: t.HWND, help_file: ?[*:0]const u8, command: u32, data: usize) callconv(.winapi) t.BOOL;
pub extern "user32" fn WinHelpW(hwnd: t.HWND, help_file: ?[*:0]const u16, command: u32, data: usize) callconv(.winapi) t.BOOL;

// ---------------------------------------------------------------------------
// Strings / characters
// ---------------------------------------------------------------------------
/// Converts in place. A pointer value <= 0xFFFF is treated as a single character.
pub extern "user32" fn CharUpperA(str: [*:0]u8) callconv(.winapi) [*:0]u8;
pub extern "user32" fn CharUpperW(str: [*:0]u16) callconv(.winapi) [*:0]u16;
pub extern "user32" fn CharLowerA(str: [*:0]u8) callconv(.winapi) [*:0]u8;
pub extern "user32" fn CharLowerW(str: [*:0]u16) callconv(.winapi) [*:0]u16;
pub extern "user32" fn CharUpperBuffA(buf: [*]u8, len: u32) callconv(.winapi) u32;
pub extern "user32" fn CharUpperBuffW(buf: [*]u16, len: u32) callconv(.winapi) u32;
pub extern "user32" fn CharLowerBuffA(buf: [*]u8, len: u32) callconv(.winapi) u32;
pub extern "user32" fn CharLowerBuffW(buf: [*]u16, len: u32) callconv(.winapi) u32;
pub extern "user32" fn CharNextA(str: [*:0]const u8) callconv(.winapi) [*:0]u8;
pub extern "user32" fn CharNextW(str: [*:0]const u16) callconv(.winapi) [*:0]u16;
pub extern "user32" fn CharPrevA(start: [*:0]const u8, current: [*:0]const u8) callconv(.winapi) [*:0]u8;
pub extern "user32" fn CharPrevW(start: [*:0]const u16, current: [*:0]const u16) callconv(.winapi) [*:0]u16;
pub extern "user32" fn CharNextExA(code_page: u16, current: [*:0]const u8, flags: u32) callconv(.winapi) [*:0]u8;
pub extern "user32" fn CharPrevExA(code_page: u16, start: [*:0]const u8, current: [*:0]const u8, flags: u32) callconv(.winapi) [*:0]u8;
pub extern "user32" fn IsCharAlphaA(ch: u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharAlphaW(ch: u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharAlphaNumericA(ch: u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharAlphaNumericW(ch: u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharUpperA(ch: u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharUpperW(ch: u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharLowerA(ch: u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn IsCharLowerW(ch: u16) callconv(.winapi) t.BOOL;

/// `dst` may equal `src` (in-place conversion).
pub extern "user32" fn CharToOemA(src: [*:0]const u8, dst: [*]u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn CharToOemW(src: [*:0]const u16, dst: [*]u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn OemToCharA(src: [*:0]const u8, dst: [*]u8) callconv(.winapi) t.BOOL;
pub extern "user32" fn OemToCharW(src: [*:0]const u8, dst: [*]u16) callconv(.winapi) t.BOOL;
pub extern "user32" fn CharToOemBuffA(src: [*]const u8, dst: [*]u8, len: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn CharToOemBuffW(src: [*]const u16, dst: [*]u8, len: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn OemToCharBuffA(src: [*]const u8, dst: [*]u8, len: u32) callconv(.winapi) t.BOOL;
pub extern "user32" fn OemToCharBuffW(src: [*]const u8, dst: [*]u16, len: u32) callconv(.winapi) t.BOOL;

/// printf-style formatting into `buf` (max 1024 chars). Prefer std.fmt.
pub extern "user32" fn wsprintfA(buf: [*]u8, format: [*:0]const u8, ...) callconv(.c) i32;
pub extern "user32" fn wsprintfW(buf: [*]u16, format: [*:0]const u16, ...) callconv(.c) i32;
pub extern "user32" fn wvsprintfA(buf: [*]u8, format: [*:0]const u8, args: t.va_list) callconv(.winapi) i32;
pub extern "user32" fn wvsprintfW(buf: [*]u16, format: [*:0]const u16, args: t.va_list) callconv(.winapi) i32;

// ---------------------------------------------------------------------------
// Optional (runtime) access to every function above
//
// The externs above are imported at link time: a program that calls one fails to start on a
// Windows without that export. `load` instead resolves the function when it is first asked for,
// and gives null if the running user32.dll lacks it:
//
//     if (USER.load("EnableMouseInPointerForThread")) |f| _ = f();
//     const create = USER.load("CreateWindowExW") orelse return error.MissingExport;
//
// The name is checked at compile time and the signature is taken from the binding above,
// so `load` never pulls in a link-time import.
// ---------------------------------------------------------------------------

/// Signatures for winuser.h functions that some user32 builds (and the mingw import
/// library) don't export. They have no extern above; reach them only through `load`.
pub const optional_exports = struct {
    pub const EnableMouseInPointerForThread = fn () callconv(.winapi) t.BOOL;
    pub const IsMousePointerEnabled = fn () callconv(.winapi) t.BOOL;
    /// Undocumented. This is the mingw header signature; calling it crashes on 32-bit Windows.
    pub const GetDisplayAutoRotationPreferencesByProcessId = fn (
        process_id: u32,
        orientation: *e.OrientationPreference,
        rotate_screen: *t.BOOL,
    ) callconv(.winapi) t.BOOL;
};

/// The function type `load(name)` returns a pointer to.
pub fn LoadFn(comptime name: []const u8) type {
    if (@hasDecl(optional_exports, name)) return @field(optional_exports, name);
    if (!@hasDecl(@This(), name)) @compileError("no user32 binding named '" ++ name ++ "'");
    const F = @TypeOf(@field(@This(), name));
    const info = @typeInfo(F);
    if (info != .@"fn") @compileError("USER." ++ name ++ " is not a function");
    switch (info.@"fn".attrs.@"callconv") {
        .auto, .@"inline" => @compileError("USER." ++ name ++ " is a Zig helper, not a user32 export"),
        else => {},
    }
    return F;
}

/// Resolves the user32 export `name` at runtime (cached after the first call).
/// Null if the running Windows does not export it.
pub fn load(comptime name: [:0]const u8) ?*const LoadFn(name) {
    const Cache = struct {
        /// 0 = not looked up yet, 1 = missing, else the function address.
        var addr: @import("std").atomic.Value(usize) = .init(0);
    };
    const missing: usize = 1;
    var addr = Cache.addr.load(.acquire);
    if (addr == 0) {
        // Racing threads all resolve the same address, so a plain store is fine.
        addr = if (loadOptional(LoadFn(name), name)) |f| @intFromPtr(f) else missing;
        Cache.addr.store(addr, .release);
    }
    return if (addr == missing) null else @ptrFromInt(addr);
}

/// Uncached lookup of any user32 export, with a caller-supplied signature.
/// Prefer `load`, which checks the name and signature against the bindings.
pub fn loadOptional(comptime Fn: type, comptime name: [:0]const u8) ?*const Fn {
    const module = kernel.LoadLibraryW(L("user32.dll"));
    if (module == .null) return null;
    const proc = kernel.GetProcAddress(module, name.ptr) orelse return null;
    return @ptrCast(proc);
}
