//! Plain Win32 data structures (extern layout).
const std = @import("std");
const t = @import("windows_types.zig");
const e = @import("windows_enums.zig");

pub const GUID = extern struct {
    data1: u32,
    data2: u16,
    data3: u16,
    data4: [8]u8,

    /// Parses "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" at compile time.
    pub fn parse(comptime s: *const [36]u8) GUID {
        comptime {
            for ([_]usize{ 8, 13, 18, 23 }) |i| {
                if (s[i] != '-') @compileError("malformed GUID: " ++ s);
            }
            var d4: [8]u8 = undefined;
            const offs = [_]usize{ 19, 21, 24, 26, 28, 30, 32, 34 };
            for (offs, 0..) |o, i| d4[i] = hex(u8, s[o..][0..2]);
            return .{
                .data1 = hex(u32, s[0..8]),
                .data2 = hex(u16, s[9..13]),
                .data3 = hex(u16, s[14..18]),
                .data4 = d4,
            };
        }
    }

    fn hex(comptime T: type, comptime digits: []const u8) T {
        return std.fmt.parseInt(T, digits, 16) catch @compileError("bad hex in GUID: " ++ digits);
    }

    pub fn eql(a: *const GUID, b: *const GUID) bool {
        return std.mem.eql(u8, std.mem.asBytes(a), std.mem.asBytes(b));
    }
};
pub const REFGUID = *const GUID;
pub const REFIID = *const GUID;
pub const REFCLSID = *const GUID;

pub const POINT = extern struct {
    x: i32,
    y: i32,
};

pub const SIZE = extern struct {
    cx: i32,
    cy: i32,
};

pub const RECT = extern struct {
    left: i32,
    top: i32,
    right: i32,
    bottom: i32,

    pub fn width(self: RECT) i32 {
        return self.right - self.left;
    }
    pub fn height(self: RECT) i32 {
        return self.bottom - self.top;
    }
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

pub const PAINTSTRUCT = extern struct {
    hdc: t.HDC,
    erase: t.BOOL,
    paint: RECT,
    restore: t.BOOL,
    inc_update: t.BOOL,
    reserved: [32]u8,
};

/// lParam of WM_CREATE / WM_NCCREATE.
pub const CREATESTRUCTW = extern struct {
    create_params: t.LPVOID,
    instance: t.HINSTANCE,
    menu: t.HMENU,
    parent: t.HWND,
    cy: i32,
    cx: i32,
    y: i32,
    x: i32,
    style: e.WindowStyle,
    name: ?t.LPCWSTR,
    class: ?t.LPCWSTR,
    ex_style: e.WindowStyleEx,
};

/// lParam of WM_GETMINMAXINFO.
pub const MINMAXINFO = extern struct {
    reserved: POINT,
    max_size: POINT,
    max_position: POINT,
    min_track_size: POINT,
    max_track_size: POINT,
};

pub const SECURITY_ATTRIBUTES = extern struct {
    length: t.DWORD = @sizeOf(SECURITY_ATTRIBUTES),
    security_descriptor: t.LPVOID = null,
    inherit_handle: t.BOOL = .false,
};

pub const LARGE_INTEGER = i64;

pub const WNDCLASSA = extern struct {
    style: e.ClassStyle = .{},
    wnd_proc: ?t.WndProc,
    cls_extra: i32 = 0,
    wnd_extra: i32 = 0,
    instance: t.HINSTANCE = .null,
    icon: t.HICON = .null,
    cursor: t.HCURSOR = .null,
    brush: t.HBRUSH = .null,
    menu_name: ?[*:0]const u8 = null,
    class_name: ?[*:0]const u8,
};

pub const WNDCLASSW = extern struct {
    style: e.ClassStyle = .{},
    wnd_proc: ?t.WndProc,
    cls_extra: i32 = 0,
    wnd_extra: i32 = 0,
    instance: t.HINSTANCE = .null,
    icon: t.HICON = .null,
    cursor: t.HCURSOR = .null,
    brush: t.HBRUSH = .null,
    menu_name: ?[*:0]const u16 = null,
    class_name: ?[*:0]const u16,
};

pub const WNDCLASSEXA = extern struct {
    size: u32 = @sizeOf(WNDCLASSEXA),
    style: e.ClassStyle = .{},
    wnd_proc: ?t.WndProc,
    cls_extra: i32 = 0,
    wnd_extra: i32 = 0,
    instance: t.HINSTANCE = .null,
    icon: t.HICON = .null,
    cursor: t.HCURSOR = .null,
    brush: t.HBRUSH = .null,
    menu_name: ?[*:0]const u8 = null,
    class_name: ?[*:0]const u8,
    small_icon: t.HICON = .null,
};

pub const WNDCLASSEXW = extern struct {
    size: u32 = @sizeOf(WNDCLASSEXW),
    style: e.ClassStyle = .{},
    wnd_proc: ?t.WndProc,
    cls_extra: i32 = 0,
    wnd_extra: i32 = 0,
    instance: t.HINSTANCE = .null,
    icon: t.HICON = .null,
    cursor: t.HCURSOR = .null,
    brush: t.HBRUSH = .null,
    menu_name: ?[*:0]const u16 = null,
    class_name: ?[*:0]const u16,
    small_icon: t.HICON = .null,
};

/// Packed 16-bit point (lParam of some messages, GESTUREINFO).
pub const POINTS = extern struct {
    x: i16,
    y: i16,
};

pub const LUID = extern struct {
    low_part: u32,
    high_part: i32,
};

// ---------------------------------------------------------------------------
// user32: windows
// ---------------------------------------------------------------------------

pub const WINDOWPLACEMENT = extern struct {
    length: u32 = @sizeOf(WINDOWPLACEMENT),
    /// WPF_* flags.
    flags: u32 = 0,
    show_cmd: e.SW = .normal,
    min_position: POINT = .{ .x = 0, .y = 0 },
    max_position: POINT = .{ .x = 0, .y = 0 },
    normal_position: RECT = .{ .left = 0, .top = 0, .right = 0, .bottom = 0 },
};

pub const WINDOWINFO = extern struct {
    size: u32 = @sizeOf(WINDOWINFO),
    window: RECT = undefined,
    client: RECT = undefined,
    style: e.WindowStyle = .{},
    ex_style: e.WindowStyleEx = .{},
    /// WS_ACTIVECAPTION (1) when active.
    window_status: u32 = 0,
    cx_window_borders: u32 = 0,
    cy_window_borders: u32 = 0,
    atom_window_type: t.ATOM = .null,
    creator_version: u16 = 0,
};

pub const TITLEBARINFO = extern struct {
    size: u32 = @sizeOf(TITLEBARINFO),
    title_bar: RECT = undefined,
    /// STATE_SYSTEM_* per part (title bar, reserved, min, max, help, close).
    state: [6]u32 = @splat(0),
};

pub const GUITHREADINFO = extern struct {
    size: u32 = @sizeOf(GUITHREADINFO),
    /// GUI_* flags.
    flags: u32 = 0,
    active: t.HWND = .null,
    focus: t.HWND = .null,
    capture: t.HWND = .null,
    menu_owner: t.HWND = .null,
    move_size: t.HWND = .null,
    caret: t.HWND = .null,
    caret_rect: RECT = undefined,
};

pub const ALTTABINFO = extern struct {
    size: u32 = @sizeOf(ALTTABINFO),
    items: i32 = 0,
    columns: i32 = 0,
    rows: i32 = 0,
    col_focus: i32 = 0,
    row_focus: i32 = 0,
    cx_item: i32 = 0,
    cy_item: i32 = 0,
    start: POINT = undefined,
};

pub const FLASHWINFO = extern struct {
    size: u32 = @sizeOf(FLASHWINFO),
    hwnd: t.HWND,
    flags: e.FlashWindowFlags,
    count: u32 = 0,
    /// 0 = default cursor blink rate.
    timeout_ms: u32 = 0,
};

/// lParam of WM_WINDOWPOSCHANGING / WM_WINDOWPOSCHANGED.
pub const WINDOWPOS = extern struct {
    hwnd: t.HWND,
    insert_after: t.HWND,
    x: i32,
    y: i32,
    cx: i32,
    cy: i32,
    flags: e.SetWindowPosFlags,
};

/// lParam of WM_CREATE / WM_NCCREATE (ANSI).
pub const CREATESTRUCTA = extern struct {
    create_params: t.LPVOID,
    instance: t.HINSTANCE,
    menu: t.HMENU,
    parent: t.HWND,
    cy: i32,
    cx: i32,
    y: i32,
    x: i32,
    style: e.WindowStyle,
    name: ?t.LPCSTR,
    class: ?t.LPCSTR,
    ex_style: e.WindowStyleEx,
};

/// lParam of WM_STYLECHANGING / WM_STYLECHANGED.
pub const STYLESTRUCT = extern struct {
    old_style: u32,
    new_style: u32,
};

pub const BLENDFUNCTION = extern struct {
    /// AC_SRC_OVER (0).
    blend_op: u8 = 0,
    blend_flags: u8 = 0,
    source_constant_alpha: u8 = 255,
    /// AC_SRC_ALPHA (1) when the source bitmap has per-pixel alpha.
    alpha_format: u8 = 0,
};

pub const UPDATELAYEREDWINDOWINFO = extern struct {
    size: u32 = @sizeOf(UPDATELAYEREDWINDOWINFO),
    hdc_dst: t.HDC = .null,
    dst: ?*const POINT = null,
    psize: ?*const SIZE = null,
    hdc_src: t.HDC = .null,
    src: ?*const POINT = null,
    key: t.COLORREF = 0,
    blend: ?*const BLENDFUNCTION = null,
    flags: e.UpdateLayeredWindowFlags = .{},
    dirty: ?*const RECT = null,
};

/// ChangeWindowMessageFilterEx result.
pub const CHANGEFILTERSTRUCT = extern struct {
    size: u32 = @sizeOf(CHANGEFILTERSTRUCT),
    /// MSGFLTINFO_* result.
    ext_status: u32 = 0,
};

/// BroadcastSystemMessageEx extra info.
pub const BSMINFO = extern struct {
    size: u32 = @sizeOf(BSMINFO),
    desk: t.HDESK = .null,
    hwnd: t.HWND = .null,
    luid: LUID = .{ .low_part = 0, .high_part = 0 },
};

// ---------------------------------------------------------------------------
// user32: dialogs / menus / resources
// ---------------------------------------------------------------------------

/// Variable-length, 2-byte aligned resource data; only ever used by pointer.
pub const DLGTEMPLATE = opaque {};
/// Variable-length MENUITEMTEMPLATEHEADER + items; only ever used by pointer.
pub const MENUTEMPLATE = opaque {};

pub const MSGBOXPARAMSA = extern struct {
    size: u32 = @sizeOf(MSGBOXPARAMSA),
    owner: t.HWND = .null,
    instance: t.HINSTANCE = .null,
    text: ?[*:0]const u8 = null,
    caption: ?[*:0]const u8 = null,
    /// MB_* bitmask.
    style: u32 = 0,
    icon: ?t.ResourceNameA = null,
    context_help_id: usize = 0,
    callback: ?t.MsgBoxCallback = null,
    language_id: u32 = 0,
};

pub const MSGBOXPARAMSW = extern struct {
    size: u32 = @sizeOf(MSGBOXPARAMSW),
    owner: t.HWND = .null,
    instance: t.HINSTANCE = .null,
    text: ?[*:0]const u16 = null,
    caption: ?[*:0]const u16 = null,
    /// MB_* bitmask.
    style: u32 = 0,
    icon: ?t.ResourceNameW = null,
    context_help_id: usize = 0,
    callback: ?t.MsgBoxCallback = null,
    language_id: u32 = 0,
};

/// Accelerator table entry.
pub const ACCEL = extern struct {
    /// FVIRTKEY (1) | FNOINVERT (2) | FSHIFT (4) | FCONTROL (8) | FALT (0x10).
    virt: u8,
    key: u16,
    cmd: u16,
};

pub const MENUINFO = extern struct {
    size: u32 = @sizeOf(MENUINFO),
    /// MIM_* mask.
    mask: u32 = 0,
    /// MNS_* style.
    style: u32 = 0,
    cy_max: u32 = 0,
    back: t.HBRUSH = .null,
    context_help_id: u32 = 0,
    menu_data: usize = 0,
};

pub const MENUITEMINFOA = extern struct {
    size: u32 = @sizeOf(MENUITEMINFOA),
    mask: e.MenuItemInfoMask = .{},
    /// MFT_* type.
    type: u32 = 0,
    /// MFS_* state.
    state: u32 = 0,
    id: u32 = 0,
    submenu: t.HMENU = .null,
    bmp_checked: t.HBITMAP = .null,
    bmp_unchecked: t.HBITMAP = .null,
    item_data: usize = 0,
    type_data: ?[*]u8 = null,
    cch: u32 = 0,
    bmp_item: t.HBITMAP = .null,
};

pub const MENUITEMINFOW = extern struct {
    size: u32 = @sizeOf(MENUITEMINFOW),
    mask: e.MenuItemInfoMask = .{},
    /// MFT_* type.
    type: u32 = 0,
    /// MFS_* state.
    state: u32 = 0,
    id: u32 = 0,
    submenu: t.HMENU = .null,
    bmp_checked: t.HBITMAP = .null,
    bmp_unchecked: t.HBITMAP = .null,
    item_data: usize = 0,
    type_data: ?[*]u16 = null,
    cch: u32 = 0,
    bmp_item: t.HBITMAP = .null,
};

pub const MENUBARINFO = extern struct {
    size: u32 = @sizeOf(MENUBARINFO),
    bar: RECT = undefined,
    menu: t.HMENU = .null,
    hwnd_menu: t.HWND = .null,
    focus: packed struct(u32) {
        bar_focused: bool = false,
        focused: bool = false,
        _r2: u30 = 0,
    } = .{},
};

pub const TPMPARAMS = extern struct {
    size: u32 = @sizeOf(TPMPARAMS),
    exclude: RECT,
};

pub const DRAWTEXTPARAMS = extern struct {
    size: u32 = @sizeOf(DRAWTEXTPARAMS),
    tab_length: i32 = 0,
    left_margin: i32 = 0,
    right_margin: i32 = 0,
    length_drawn: u32 = 0,
};

pub const ICONINFO = extern struct {
    /// `.true` for an icon, `.false` for a cursor.
    icon: t.BOOL,
    x_hotspot: u32 = 0,
    y_hotspot: u32 = 0,
    mask: t.HBITMAP,
    color: t.HBITMAP = .null,
};

pub const ICONINFOEXA = extern struct {
    size: u32 = @sizeOf(ICONINFOEXA),
    icon: t.BOOL = .false,
    x_hotspot: u32 = 0,
    y_hotspot: u32 = 0,
    mask: t.HBITMAP = .null,
    color: t.HBITMAP = .null,
    res_id: u16 = 0,
    mod_name: [260]u8 = @splat(0),
    res_name: [260]u8 = @splat(0),
};

pub const ICONINFOEXW = extern struct {
    size: u32 = @sizeOf(ICONINFOEXW),
    icon: t.BOOL = .false,
    x_hotspot: u32 = 0,
    y_hotspot: u32 = 0,
    mask: t.HBITMAP = .null,
    color: t.HBITMAP = .null,
    res_id: u16 = 0,
    mod_name: [260]u16 = @splat(0),
    res_name: [260]u16 = @splat(0),
};

pub const CURSORINFO = extern struct {
    size: u32 = @sizeOf(CURSORINFO),
    /// CURSOR_SHOWING (1) | CURSOR_SUPPRESSED (2).
    flags: u32 = 0,
    cursor: t.HCURSOR = .null,
    screen_pos: POINT = undefined,
};

// ---------------------------------------------------------------------------
// user32: scrolling / controls
// ---------------------------------------------------------------------------

pub const SCROLLINFO = extern struct {
    size: u32 = @sizeOf(SCROLLINFO),
    mask: e.ScrollInfoMask,
    min: i32 = 0,
    max: i32 = 0,
    page: u32 = 0,
    pos: i32 = 0,
    track_pos: i32 = 0,
};

pub const SCROLLBARINFO = extern struct {
    size: u32 = @sizeOf(SCROLLBARINFO),
    scroll_bar: RECT = undefined,
    dxy_line_button: i32 = 0,
    xy_thumb_top: i32 = 0,
    xy_thumb_bottom: i32 = 0,
    reserved: i32 = 0,
    /// STATE_SYSTEM_* per part.
    state: [6]u32 = @splat(0),
};

pub const COMBOBOXINFO = extern struct {
    size: u32 = @sizeOf(COMBOBOXINFO),
    item: RECT = undefined,
    button: RECT = undefined,
    state_button: u32 = 0,
    combo: t.HWND = .null,
    edit: t.HWND = .null,
    list: t.HWND = .null,
};

// ---------------------------------------------------------------------------
// user32: input
// ---------------------------------------------------------------------------

pub const TRACKMOUSEEVENT = extern struct {
    size: u32 = @sizeOf(TRACKMOUSEEVENT),
    flags: e.TrackMouseEventFlags,
    track: t.HWND,
    /// HOVER_DEFAULT = 0xFFFFFFFF.
    hover_time_ms: u32 = 0xFFFFFFFF,
};

pub const MOUSEMOVEPOINT = extern struct {
    x: i32,
    y: i32,
    time: u32,
    extra_info: usize,
};

pub const LASTINPUTINFO = extern struct {
    size: u32 = @sizeOf(LASTINPUTINFO),
    /// GetTickCount value of the last input event.
    time: u32 = 0,
};

pub const MOUSEINPUT = extern struct {
    dx: i32 = 0,
    dy: i32 = 0,
    /// Wheel delta (WHEEL_DELTA = 120) or XBUTTON1/2.
    mouse_data: u32 = 0,
    flags: e.MouseEventFlags = .{},
    time: u32 = 0,
    extra_info: usize = 0,
};

pub const KEYBDINPUT = extern struct {
    vk: u16 = 0,
    scan: u16 = 0,
    flags: e.KeyEventFlags = .{},
    time: u32 = 0,
    extra_info: usize = 0,
};

pub const HARDWAREINPUT = extern struct {
    msg: u32,
    param_l: u16,
    param_h: u16,
};

/// SendInput element.
pub const INPUT = extern struct {
    type: e.InputType,
    data: extern union {
        mi: MOUSEINPUT,
        ki: KEYBDINPUT,
        hi: HARDWAREINPUT,
    },

    pub fn mouse(mi: MOUSEINPUT) INPUT {
        return .{ .type = .mouse, .data = .{ .mi = mi } };
    }
    pub fn keyboard(ki: KEYBDINPUT) INPUT {
        return .{ .type = .keyboard, .data = .{ .ki = ki } };
    }
};

pub const TOUCHINPUT = extern struct {
    /// Hundredths of a pixel, screen coordinates.
    x: i32,
    y: i32,
    source: t.HANDLE,
    id: u32,
    /// TOUCHEVENTF_* flags.
    flags: u32,
    /// TOUCHINPUTMASKF_* mask.
    mask: u32,
    time: u32,
    extra_info: usize,
    cx_contact: u32,
    cy_contact: u32,
};

pub const GESTUREINFO = extern struct {
    size: u32 = @sizeOf(GESTUREINFO),
    /// GF_* flags.
    flags: u32 = 0,
    /// GID_* gesture id.
    id: u32 = 0,
    target: t.HWND = .null,
    location: POINTS = .{ .x = 0, .y = 0 },
    instance_id: u32 = 0,
    sequence_id: u32 = 0,
    arguments: u64 = 0,
    extra_args_size: u32 = 0,
};

pub const GESTURECONFIG = extern struct {
    /// GID_* gesture id.
    id: u32,
    want: u32,
    block: u32,
};

// --- Raw input ---------------------------------------------------------------

pub const RAWINPUTDEVICE = extern struct {
    /// HID usage page, e.g. 0x01 (generic desktop).
    usage_page: u16,
    /// HID usage, e.g. 0x02 (mouse), 0x06 (keyboard).
    usage: u16,
    flags: e.RawInputDeviceFlags = .{},
    target: t.HWND = .null,
};

pub const RAWINPUTDEVICELIST = extern struct {
    device: t.HANDLE,
    type: e.RawInputType,
};

pub const RAWINPUTHEADER = extern struct {
    type: e.RawInputType,
    size: u32,
    device: t.HANDLE,
    w_param: t.WPARAM,
};

pub const RAWMOUSE = extern struct {
    /// MOUSE_MOVE_RELATIVE (0) / MOUSE_MOVE_ABSOLUTE (1) / MOUSE_VIRTUAL_DESKTOP (2) ...
    flags: u16,
    _pad: u16 = 0,
    /// RI_MOUSE_* bits.
    button_flags: u16,
    /// Wheel delta when button_flags has RI_MOUSE_WHEEL / RI_MOUSE_HWHEEL.
    button_data: u16,
    raw_buttons: u32,
    last_x: i32,
    last_y: i32,
    extra_information: u32,
};

pub const RAWKEYBOARD = extern struct {
    make_code: u16,
    /// RI_KEY_BREAK (1) | RI_KEY_E0 (2) | RI_KEY_E1 (4).
    flags: u16,
    reserved: u16,
    vkey: u16,
    message: u32,
    extra_information: u32,
};

/// Variable-length: `raw_data` really holds `size_hid * count` bytes.
pub const RAWHID = extern struct {
    size_hid: u32,
    count: u32,
    raw_data: [1]u8,

    pub fn reports(self: *const RAWHID) []const u8 {
        const p: [*]const u8 = @ptrCast(&self.raw_data);
        return p[0 .. self.size_hid * self.count];
    }
};

pub const RAWINPUT = extern struct {
    header: RAWINPUTHEADER,
    data: extern union {
        mouse: RAWMOUSE,
        keyboard: RAWKEYBOARD,
        hid: RAWHID,
    },
};

/// GetRawInputDeviceInfo(RIDI_DEVICEINFO) result.
pub const RID_DEVICE_INFO = extern struct {
    size: u32 = @sizeOf(RID_DEVICE_INFO),
    type: e.RawInputType = .mouse,
    info: extern union {
        mouse: extern struct {
            id: u32,
            number_of_buttons: u32,
            sample_rate: u32,
            has_horizontal_wheel: t.BOOL,
        },
        keyboard: extern struct {
            type: u32,
            sub_type: u32,
            keyboard_mode: u32,
            number_of_function_keys: u32,
            number_of_indicators: u32,
            number_of_keys_total: u32,
        },
        hid: extern struct {
            vendor_id: u32,
            product_id: u32,
            version_number: u32,
            usage_page: u16,
            usage: u16,
        },
    } = undefined,
};

// --- Pointer input -------------------------------------------------------------

pub const POINTER_INFO = extern struct {
    pointer_type: e.PointerInputType,
    pointer_id: u32,
    frame_id: u32,
    pointer_flags: e.PointerFlags,
    source_device: t.HANDLE,
    target: t.HWND,
    pixel_location: POINT,
    himetric_location: POINT,
    pixel_location_raw: POINT,
    himetric_location_raw: POINT,
    time: u32,
    history_count: u32,
    input_data: i32,
    /// MK_* key states.
    key_states: u32,
    performance_count: u64,
    button_change_type: e.PointerButtonChangeType,
};

pub const POINTER_TOUCH_INFO = extern struct {
    pointer_info: POINTER_INFO,
    /// TOUCH_FLAG_* bits.
    touch_flags: u32,
    /// TOUCH_MASK_* bits.
    touch_mask: u32,
    contact: RECT,
    contact_raw: RECT,
    orientation: u32,
    pressure: u32,
};

pub const POINTER_PEN_INFO = extern struct {
    pointer_info: POINTER_INFO,
    /// PEN_FLAG_* bits.
    pen_flags: u32,
    /// PEN_MASK_* bits.
    pen_mask: u32,
    pressure: u32,
    rotation: u32,
    tilt_x: i32,
    tilt_y: i32,
};

pub const POINTER_TYPE_INFO = extern struct {
    type: e.PointerInputType,
    info: extern union {
        touch: POINTER_TOUCH_INFO,
        pen: POINTER_PEN_INFO,
    },
};

pub const POINTER_DEVICE_INFO = extern struct {
    /// DISPLAYCONFIG_ROTATION.
    display_orientation: u32,
    device: t.HANDLE,
    pointer_device_type: e.PointerDeviceType,
    monitor: t.HMONITOR,
    starting_cursor_id: u32,
    max_active_contacts: u16,
    product_string: [520]u16,
};

pub const POINTER_DEVICE_PROPERTY = extern struct {
    logical_min: i32,
    logical_max: i32,
    physical_min: i32,
    physical_max: i32,
    unit: u32,
    unit_exponent: u32,
    usage_page_id: u16,
    usage_id: u16,
};

pub const POINTER_DEVICE_CURSOR_INFO = extern struct {
    cursor_id: u32,
    /// POINTER_DEVICE_CURSOR_TYPE: 0 unknown, 1 tip, 2 eraser.
    cursor: u32,
};

pub const TOUCH_HIT_TESTING_INPUT = extern struct {
    pointer_id: u32,
    point: POINT,
    bounding_box: RECT,
    non_occluded_bounding_box: RECT,
    orientation: u32,
};

pub const TOUCH_HIT_TESTING_PROXIMITY_EVALUATION = extern struct {
    score: u16,
    adjusted_point: POINT,
};

/// Row-major 4x4 matrix.
pub const INPUT_TRANSFORM = extern struct {
    m: [4][4]f32,
};

pub const INPUT_MESSAGE_SOURCE = extern struct {
    device_type: e.InputMessageDeviceType,
    origin_id: e.InputMessageOriginId,
};

// ---------------------------------------------------------------------------
// user32: monitors / display settings
// ---------------------------------------------------------------------------

pub const MONITORINFO = extern struct {
    size: u32 = @sizeOf(MONITORINFO),
    monitor: RECT = undefined,
    work: RECT = undefined,
    flags: e.MonitorInfoFlags = .{},
};

/// Pass as `*MONITORINFO` via `@ptrCast(&info)`; `size` tells GetMonitorInfo which one it is.
pub const MONITORINFOEXA = extern struct {
    size: u32 = @sizeOf(MONITORINFOEXA),
    monitor: RECT = undefined,
    work: RECT = undefined,
    flags: e.MonitorInfoFlags = .{},
    device: [32]u8 = @splat(0),
};

/// Pass as `*MONITORINFO` via `@ptrCast(&info)`; `size` tells GetMonitorInfo which one it is.
pub const MONITORINFOEXW = extern struct {
    size: u32 = @sizeOf(MONITORINFOEXW),
    monitor: RECT = undefined,
    work: RECT = undefined,
    flags: e.MonitorInfoFlags = .{},
    device: [32]u16 = @splat(0),
};

pub const DISPLAY_DEVICEA = extern struct {
    size: u32 = @sizeOf(DISPLAY_DEVICEA),
    device_name: [32]u8 = @splat(0),
    device_string: [128]u8 = @splat(0),
    /// DISPLAY_DEVICE_* flags.
    state_flags: u32 = 0,
    device_id: [128]u8 = @splat(0),
    device_key: [128]u8 = @splat(0),
};

pub const DISPLAY_DEVICEW = extern struct {
    size: u32 = @sizeOf(DISPLAY_DEVICEW),
    device_name: [32]u16 = @splat(0),
    device_string: [128]u16 = @splat(0),
    /// DISPLAY_DEVICE_* flags.
    state_flags: u32 = 0,
    device_id: [128]u16 = @splat(0),
    device_key: [128]u16 = @splat(0),
};

/// DEVMODEA with the display variant of the printer/display union.
pub const DEVMODEA = extern struct {
    device_name: [32]u8 = @splat(0),
    spec_version: u16 = 0x0401,
    driver_version: u16 = 0,
    size: u16 = @sizeOf(DEVMODEA),
    driver_extra: u16 = 0,
    /// DM_* mask of the fields that are valid.
    fields: u32 = 0,
    position: POINT = .{ .x = 0, .y = 0 },
    /// DMDO_DEFAULT / 90 / 180 / 270.
    display_orientation: u32 = 0,
    display_fixed_output: u32 = 0,
    color: i16 = 0,
    duplex: i16 = 0,
    y_resolution: i16 = 0,
    tt_option: i16 = 0,
    collate: i16 = 0,
    form_name: [32]u8 = @splat(0),
    log_pixels: u16 = 0,
    bits_per_pel: u32 = 0,
    pels_width: u32 = 0,
    pels_height: u32 = 0,
    display_flags: u32 = 0,
    display_frequency: u32 = 0,
    icm_method: u32 = 0,
    icm_intent: u32 = 0,
    media_type: u32 = 0,
    dither_type: u32 = 0,
    reserved1: u32 = 0,
    reserved2: u32 = 0,
    panning_width: u32 = 0,
    panning_height: u32 = 0,
};

/// DEVMODEW with the display variant of the printer/display union.
pub const DEVMODEW = extern struct {
    device_name: [32]u16 = @splat(0),
    spec_version: u16 = 0x0401,
    driver_version: u16 = 0,
    size: u16 = @sizeOf(DEVMODEW),
    driver_extra: u16 = 0,
    /// DM_* mask of the fields that are valid.
    fields: u32 = 0,
    position: POINT = .{ .x = 0, .y = 0 },
    /// DMDO_DEFAULT / 90 / 180 / 270.
    display_orientation: u32 = 0,
    display_fixed_output: u32 = 0,
    color: i16 = 0,
    duplex: i16 = 0,
    y_resolution: i16 = 0,
    tt_option: i16 = 0,
    collate: i16 = 0,
    form_name: [32]u16 = @splat(0),
    log_pixels: u16 = 0,
    bits_per_pel: u32 = 0,
    pels_width: u32 = 0,
    pels_height: u32 = 0,
    display_flags: u32 = 0,
    display_frequency: u32 = 0,
    icm_method: u32 = 0,
    icm_intent: u32 = 0,
    media_type: u32 = 0,
    dither_type: u32 = 0,
    reserved1: u32 = 0,
    reserved2: u32 = 0,
    panning_width: u32 = 0,
    panning_height: u32 = 0,
};

// --- DisplayConfig (QueryDisplayConfig / SetDisplayConfig) ---------------------

pub const DISPLAYCONFIG_RATIONAL = extern struct {
    numerator: u32,
    denominator: u32,
};

pub const DISPLAYCONFIG_2DREGION = extern struct {
    cx: u32,
    cy: u32,
};

pub const DISPLAYCONFIG_PATH_SOURCE_INFO = extern struct {
    adapter_id: LUID,
    id: u32,
    /// Or (clone_group_id: u16, source_mode_info_idx: u16) with DISPLAYCONFIG_PATH_SUPPORT_VIRTUAL_MODE.
    mode_info_idx: u32,
    status_flags: u32,
};

pub const DISPLAYCONFIG_PATH_TARGET_INFO = extern struct {
    adapter_id: LUID,
    id: u32,
    /// Or (desktop_mode_info_idx: u16, target_mode_info_idx: u16) with DISPLAYCONFIG_PATH_SUPPORT_VIRTUAL_MODE.
    mode_info_idx: u32,
    /// DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY.
    output_technology: u32,
    /// DISPLAYCONFIG_ROTATION.
    rotation: u32,
    /// DISPLAYCONFIG_SCALING.
    scaling: u32,
    refresh_rate: DISPLAYCONFIG_RATIONAL,
    /// DISPLAYCONFIG_SCANLINE_ORDERING.
    scan_line_ordering: u32,
    target_available: t.BOOL,
    status_flags: u32,
};

pub const DISPLAYCONFIG_PATH_INFO = extern struct {
    source_info: DISPLAYCONFIG_PATH_SOURCE_INFO,
    target_info: DISPLAYCONFIG_PATH_TARGET_INFO,
    flags: u32,
};

pub const DISPLAYCONFIG_VIDEO_SIGNAL_INFO = extern struct {
    pixel_rate: u64,
    h_sync_freq: DISPLAYCONFIG_RATIONAL,
    v_sync_freq: DISPLAYCONFIG_RATIONAL,
    active_size: DISPLAYCONFIG_2DREGION,
    total_size: DISPLAYCONFIG_2DREGION,
    /// videoStandard:16, vSyncFreqDivider:6, reserved:10.
    video_standard: u32,
    /// DISPLAYCONFIG_SCANLINE_ORDERING.
    scan_line_ordering: u32,
};

pub const DISPLAYCONFIG_SOURCE_MODE = extern struct {
    width: u32,
    height: u32,
    /// DISPLAYCONFIG_PIXELFORMAT.
    pixel_format: u32,
    position: POINT,
};

pub const DISPLAYCONFIG_DESKTOP_IMAGE_INFO = extern struct {
    path_source_size: POINT,
    desktop_image_region: RECT,
    desktop_image_clip: RECT,
};

pub const DISPLAYCONFIG_MODE_INFO = extern struct {
    /// DISPLAYCONFIG_MODE_INFO_TYPE: 1 source, 2 target, 3 desktop image.
    info_type: u32,
    id: u32,
    adapter_id: LUID,
    mode: extern union {
        target: DISPLAYCONFIG_VIDEO_SIGNAL_INFO,
        source: DISPLAYCONFIG_SOURCE_MODE,
        desktop_image: DISPLAYCONFIG_DESKTOP_IMAGE_INFO,
    },
};

/// Header of every DisplayConfigGet/SetDeviceInfo packet.
pub const DISPLAYCONFIG_DEVICE_INFO_HEADER = extern struct {
    /// DISPLAYCONFIG_DEVICE_INFO_TYPE.
    type: u32,
    size: u32,
    adapter_id: LUID,
    id: u32,
};
