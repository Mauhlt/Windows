//! Primitive Win32 types, handles, and callback signatures.

// ---------------------------------------------------------------------------
// Integers
// ---------------------------------------------------------------------------
pub const BYTE = u8;
pub const WORD = u16;
pub const DWORD = u32;
pub const UINT = u32;
pub const INT = i32;
pub const LONG = i32;
pub const ULONG = u32;
pub const LONGLONG = i64;
pub const ULONGLONG = u64;
pub const WCHAR = u16;
pub const UINT_PTR = usize;
pub const ULONG_PTR = usize;
pub const LONG_PTR = isize;
pub const SIZE_T = usize;
pub const DWORD_PTR = usize;
pub const INT_PTR = isize;
pub const SHORT = i16;
pub const USHORT = u16;

/// 0x00BBGGRR. Build one with `rgb`.
pub const COLORREF = u32;
pub fn rgb(r: u8, g: u8, b: u8) COLORREF {
    return @as(u32, r) | (@as(u32, g) << 8) | (@as(u32, b) << 16);
}

/// Desktop / window-station access rights (DESKTOP_*, WINSTA_*, GENERIC_*).
pub const ACCESS_MASK = u32;
/// OWNER_/GROUP_/DACL_/SACL_SECURITY_INFORMATION bits.
pub const SECURITY_INFORMATION = u32;
pub const PSECURITY_DESCRIPTOR = ?*anyopaque;

/// Generic function pointer (FARPROC).
pub const FARPROC = *const fn () callconv(.winapi) isize;

/// C `va_list` for wvsprintf. On Windows (x86 and x64) it is a plain `char*` into the argument area.
pub const va_list = [*]u8;

// ---------------------------------------------------------------------------
// Pointers / strings
// ---------------------------------------------------------------------------
pub const LPVOID = ?*anyopaque;
pub const LPCVOID = ?*const anyopaque;
pub const LPSTR = [*:0]u8;
pub const LPCSTR = [*:0]const u8;
pub const LPWSTR = [*:0]u16;
pub const LPCWSTR = [*:0]const u16;

/// A string argument that may also be an integer resource id (`MAKEINTRESOURCE`).
/// Integer ids are not real pointers, hence `align(1)`.
pub const ResourceNameA = [*:0]align(1) const u8;
pub const ResourceNameW = [*:0]align(1) const u16;

pub fn makeIntResourceA(id: u16) ResourceNameA {
    return @ptrFromInt(id);
}
pub fn makeIntResourceW(id: u16) ResourceNameW {
    return @ptrFromInt(id);
}

// ---------------------------------------------------------------------------
// Value enums
// ---------------------------------------------------------------------------
pub const ATOM = enum(u16) {
    null = 0,
    _,
};

/// Win32 `BOOL` is an `int`; any nonzero value means true, so this is non-exhaustive.
pub const BOOL = enum(i32) {
    false = 0,
    true = 1,
    _,

    pub fn from(b: bool) BOOL {
        return if (b) .true else .false;
    }
    pub fn toBool(self: BOOL) bool {
        return self != .false;
    }
};

/// 32-bit COM/Win32 status code. Negative = failure.
pub const HRESULT = enum(i32) {
    ok = 0,
    false = 1,
    not_impl = @bitCast(@as(u32, 0x80004001)),
    no_interface = @bitCast(@as(u32, 0x80004002)),
    pointer = @bitCast(@as(u32, 0x80004003)),
    abort = @bitCast(@as(u32, 0x80004004)),
    fail = @bitCast(@as(u32, 0x80004005)),
    unexpected = @bitCast(@as(u32, 0x8000FFFF)),
    /// RPC_E_CHANGED_MODE: CoInitializeEx was already called with a different model.
    rpc_changed_mode = @bitCast(@as(u32, 0x80010106)),
    access_denied = @bitCast(@as(u32, 0x80070005)),
    handle = @bitCast(@as(u32, 0x80070006)),
    out_of_memory = @bitCast(@as(u32, 0x8007000E)),
    invalid_arg = @bitCast(@as(u32, 0x80070057)),
    _,

    pub fn succeeded(self: HRESULT) bool {
        return @backingInt(self) >= 0;
    }
    pub fn failed(self: HRESULT) bool {
        return @backingInt(self) < 0;
    }
    /// Converts a failing HRESULT into a Zig error.
    pub fn check(self: HRESULT) error{HResultFailed}!void {
        if (self.failed()) return error.HResultFailed;
    }
    pub fn code(self: HRESULT) u32 {
        return @bitCast(@backingInt(self));
    }
};

pub const LRESULT = enum(isize) {
    null = 0,
    _,
};
pub const LPARAM = enum(isize) {
    null = 0,
    _,

    /// Passes a pointer through an LPARAM (EnumWindows, CreateWindowEx's WM_CREATE, ...).
    pub fn fromPtr(ptr: anytype) LPARAM {
        return @enumFromInt(@as(isize, @bitCast(@intFromPtr(ptr))));
    }
    /// Reads back a pointer passed with `fromPtr`, or a struct pointer the system sent.
    pub fn toPtr(self: LPARAM, comptime T: type) *T {
        return @ptrFromInt(@as(usize, @bitCast(@backingInt(self))));
    }
};
pub const WPARAM = enum(usize) {
    null = 0,
    _,
};

// ---------------------------------------------------------------------------
// Handles (distinct types so they cannot be mixed up)
// ---------------------------------------------------------------------------
pub const HANDLE = enum(isize) {
    null = 0,
    invalid = -1, // INVALID_HANDLE_VALUE
    _,
};
pub const INVALID_HANDLE_VALUE: HANDLE = .invalid;

pub const HBRUSH = enum(isize) {
    null = 0,
    _,
};
pub const HCURSOR = enum(isize) {
    null = 0,
    _,
};
pub const HDC = enum(isize) {
    null = 0,
    _,
};
pub const HGDIOBJ = enum(isize) {
    null = 0,
    _,
};
pub const HICON = enum(isize) {
    null = 0,
    _,
};
pub const HINSTANCE = enum(isize) {
    null = 0,
    _,
};
pub const HMODULE = HINSTANCE;
pub const HMENU = enum(isize) {
    null = 0,
    _,
};
pub const HMONITOR = enum(isize) {
    null = 0,
    _,
};
pub const HWND = enum(isize) {
    null = 0,
    _,

    // Special `hWndInsertAfter` values for SetWindowPos.
    pub const top: HWND = .null;
    pub const bottom: HWND = @fromBackingInt(@intCast(1));
    pub const topmost: HWND = @fromBackingInt(@intCast(-1));
    pub const not_topmost: HWND = @fromBackingInt(@intCast(-2));
    /// Parent for message-only windows.
    pub const message: HWND = @fromBackingInt(@intCast(-3));
    /// Target for PostMessage / SendMessage to every top-level window.
    pub const broadcast: HWND = @fromBackingInt(@intCast(0xFFFF));
};

pub const HACCEL = enum(isize) {
    null = 0,
    _,
};
pub const HBITMAP = enum(isize) {
    null = 0,
    _,
};
pub const HDESK = enum(isize) {
    null = 0,
    _,
};
pub const HDEVNOTIFY = enum(isize) {
    null = 0,
    _,
};
/// BeginDeferWindowPos / DeferWindowPos / EndDeferWindowPos.
pub const HDWP = enum(isize) {
    null = 0,
    _,
};
pub const HGESTUREINFO = enum(isize) {
    null = 0,
    _,
};
pub const HHOOK = enum(isize) {
    null = 0,
    _,
};
/// Keyboard layout.
pub const HKL = enum(isize) {
    null = 0,
    _,

    // Special values for ActivateKeyboardLayout.
    pub const prev: HKL = @fromBackingInt(@intCast(0));
    pub const next: HKL = @fromBackingInt(@intCast(1));
};
pub const HPOWERNOTIFY = enum(isize) {
    null = 0,
    _,
};
pub const HRAWINPUT = enum(isize) {
    null = 0,
    _,
};
pub const HRGN = enum(isize) {
    null = 0,
    _,
};
pub const HSYNTHETICPOINTERDEVICE = enum(isize) {
    null = 0,
    _,
};
pub const HTOUCHINPUT = enum(isize) {
    null = 0,
    _,
};
pub const HWINEVENTHOOK = enum(isize) {
    null = 0,
    _,
};
pub const HWINSTA = enum(isize) {
    null = 0,
    _,
};

// ---------------------------------------------------------------------------
// Callbacks
// ---------------------------------------------------------------------------
pub const WndProc = *const fn (
    hwnd: HWND,
    msg: UINT,
    w_param: WPARAM,
    l_param: LPARAM,
) callconv(.winapi) LRESULT;

pub const TimerProc = *const fn (
    hwnd: HWND,
    msg: UINT,
    id_event: UINT_PTR,
    time: DWORD,
) callconv(.winapi) void;

/// Return nonzero (TRUE) if the message was handled.
pub const DlgProc = *const fn (
    hwnd: HWND,
    msg: UINT,
    w_param: WPARAM,
    l_param: LPARAM,
) callconv(.winapi) INT_PTR;

/// `code` < 0 means "pass straight to CallNextHookEx".
pub const HookProc = *const fn (
    code: INT,
    w_param: WPARAM,
    l_param: LPARAM,
) callconv(.winapi) LRESULT;

pub const SendAsyncProc = *const fn (
    hwnd: HWND,
    msg: UINT,
    data: ULONG_PTR,
    result: LRESULT,
) callconv(.winapi) void;

/// Return `.true` to keep enumerating.
pub const WndEnumProc = *const fn (hwnd: HWND, l_param: LPARAM) callconv(.winapi) BOOL;
pub const DesktopEnumProcA = *const fn (name: LPSTR, l_param: LPARAM) callconv(.winapi) BOOL;
pub const DesktopEnumProcW = *const fn (name: LPWSTR, l_param: LPARAM) callconv(.winapi) BOOL;
pub const WinStaEnumProcA = DesktopEnumProcA;
pub const WinStaEnumProcW = DesktopEnumProcW;

/// `name` is either a string or an atom (check `@intFromPtr(name) <= 0xFFFF`).
pub const PropEnumProcA = *const fn (hwnd: HWND, name: ResourceNameA, data: HANDLE) callconv(.winapi) BOOL;
pub const PropEnumProcW = *const fn (hwnd: HWND, name: ResourceNameW, data: HANDLE) callconv(.winapi) BOOL;
pub const PropEnumProcExA = *const fn (hwnd: HWND, name: [*:0]align(1) u8, data: HANDLE, l_param: ULONG_PTR) callconv(.winapi) BOOL;
pub const PropEnumProcExW = *const fn (hwnd: HWND, name: [*:0]align(1) u16, data: HANDLE, l_param: ULONG_PTR) callconv(.winapi) BOOL;

pub const MonitorEnumProc = *const fn (
    monitor: HMONITOR,
    hdc: HDC,
    rect: *@import("windows_structs.zig").RECT,
    l_param: LPARAM,
) callconv(.winapi) BOOL;

pub const WinEventProc = *const fn (
    hook: HWINEVENTHOOK,
    event: DWORD,
    hwnd: HWND,
    id_object: LONG,
    id_child: LONG,
    id_event_thread: DWORD,
    event_time_ms: DWORD,
) callconv(.winapi) void;

pub const GrayStringProc = *const fn (hdc: HDC, l_param: LPARAM, len: INT) callconv(.winapi) BOOL;
pub const DrawStateProc = *const fn (hdc: HDC, l_data: LPARAM, w_data: WPARAM, cx: INT, cy: INT) callconv(.winapi) BOOL;

/// MSGBOXPARAMS callback; `help_info` is a HELPINFO*.
pub const MsgBoxCallback = *const fn (help_info: *anyopaque) callconv(.winapi) void;
