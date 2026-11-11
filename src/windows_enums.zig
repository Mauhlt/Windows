//! Win32 enums and bit-flag sets.
//!
//! Flag sets are `packed struct(u32)` so they can be combined, e.g.
//! `WindowStyle{ .caption = true, .sys_menu = true }`, and are ABI-identical to the
//! underlying `DWORD` when passed to extern functions.
const t = @import("windows_types.zig");

/// GetSysColor / GetSysColorBrush index.
pub const Color = enum(i32) {
    scrollbar = 0,
    background = 1,
    active_caption = 2,
    inactive_caption = 3,
    menu = 4,
    window = 5,
    window_frame = 6,
    menu_text = 7,
    window_text = 8,
    caption_text = 9,
    active_border = 10,
    inactive_border = 11,
    app_workspace = 12,
    highlight = 13,
    highlight_text = 14,
    btn_face = 15,
    btn_shadow = 16,
    gray_text = 17,
    btn_text = 18,
    inactive_caption_text = 19,
    btn_highlight = 20,
    dk_shadow_3d = 21,
    light_3d = 22,
    info_text = 23,
    info_bk = 24,
    hot_light = 26,
    gradient_active_caption = 27,
    gradient_inactive_caption = 28,
    menu_hilight = 29,
    menu_bar = 30,
    _,
};

/// CS_* window class styles.
pub const ClassStyle = packed struct(u32) {
    v_redraw: bool = false, // 0x0001
    h_redraw: bool = false, // 0x0002
    _r2: u1 = 0,
    dbl_clks: bool = false, // 0x0008
    _r4: u1 = 0,
    own_dc: bool = false, // 0x0020
    class_dc: bool = false, // 0x0040
    parent_dc: bool = false, // 0x0080
    _r8: u1 = 0,
    no_close: bool = false, // 0x0200
    _r10: u1 = 0,
    save_bits: bool = false, // 0x0800
    byte_align_client: bool = false, // 0x1000
    byte_align_window: bool = false, // 0x2000
    global_class: bool = false, // 0x4000
    _r15: u2 = 0,
    drop_shadow: bool = false, // 0x20000
    _r18: u14 = 0,

    pub const redraw: ClassStyle = .{ .v_redraw = true, .h_redraw = true };
};

/// WS_* window styles. The low 16 bits are control-specific (BS_*, ES_*, ...).
pub const WindowStyle = packed struct(u32) {
    control: u16 = 0,
    maximize_box: bool = false, // 0x00010000 (WS_TABSTOP for controls)
    minimize_box: bool = false, // 0x00020000 (WS_GROUP for controls)
    thick_frame: bool = false, // 0x00040000
    sys_menu: bool = false, // 0x00080000
    h_scroll: bool = false, // 0x00100000
    v_scroll: bool = false, // 0x00200000
    dlg_frame: bool = false, // 0x00400000
    border: bool = false, // 0x00800000
    maximize: bool = false, // 0x01000000
    clip_children: bool = false, // 0x02000000
    clip_siblings: bool = false, // 0x04000000
    disabled: bool = false, // 0x08000000
    visible: bool = false, // 0x10000000
    minimize: bool = false, // 0x20000000
    child: bool = false, // 0x40000000
    popup: bool = false, // 0x80000000

    pub const overlapped: WindowStyle = .{};
    /// WS_CAPTION = WS_BORDER | WS_DLGFRAME
    pub const caption: WindowStyle = .{ .border = true, .dlg_frame = true };
    pub const overlapped_window: WindowStyle = .{
        .border = true,
        .dlg_frame = true,
        .sys_menu = true,
        .thick_frame = true,
        .minimize_box = true,
        .maximize_box = true,
    };
    pub const tiled_window = overlapped_window;
    pub const popup_window: WindowStyle = .{ .popup = true, .border = true, .sys_menu = true };

    pub fn merge(a: WindowStyle, b: WindowStyle) WindowStyle {
        return @bitCast(@as(u32, @bitCast(a)) | @as(u32, @bitCast(b)));
    }
};

/// WS_EX_* extended window styles.
pub const WindowStyleEx = packed struct(u32) {
    dlg_modal_frame: bool = false, // 0x00000001
    _r1: u1 = 0,
    no_parent_notify: bool = false, // 0x00000004
    topmost: bool = false, // 0x00000008
    accept_files: bool = false, // 0x00000010
    transparent: bool = false, // 0x00000020
    mdi_child: bool = false, // 0x00000040
    tool_window: bool = false, // 0x00000080
    window_edge: bool = false, // 0x00000100
    client_edge: bool = false, // 0x00000200
    context_help: bool = false, // 0x00000400
    _r11: u1 = 0,
    right: bool = false, // 0x00001000
    rtl_reading: bool = false, // 0x00002000
    left_scrollbar: bool = false, // 0x00004000
    _r15: u1 = 0,
    control_parent: bool = false, // 0x00010000
    static_edge: bool = false, // 0x00020000
    app_window: bool = false, // 0x00040000
    layered: bool = false, // 0x00080000
    no_inherit_layout: bool = false, // 0x00100000
    no_redirection_bitmap: bool = false, // 0x00200000
    layout_rtl: bool = false, // 0x00400000
    _r23: u2 = 0,
    composited: bool = false, // 0x02000000
    _r26: u1 = 0,
    no_activate: bool = false, // 0x08000000
    _r28: u4 = 0,

    pub const overlapped_window: WindowStyleEx = .{ .window_edge = true, .client_edge = true };
};

/// SWP_* flags for SetWindowPos.
pub const SetWindowPosFlags = packed struct(u32) {
    no_size: bool = false, // 0x0001
    no_move: bool = false, // 0x0002
    no_z_order: bool = false, // 0x0004
    no_redraw: bool = false, // 0x0008
    no_activate: bool = false, // 0x0010
    frame_changed: bool = false, // 0x0020
    show_window: bool = false, // 0x0040
    hide_window: bool = false, // 0x0080
    no_copy_bits: bool = false, // 0x0100
    no_owner_z_order: bool = false, // 0x0200
    no_send_changing: bool = false, // 0x0400
    _r11: u2 = 0,
    defer_erase: bool = false, // 0x2000
    async_window_pos: bool = false, // 0x4000
    _r15: u17 = 0,
};

pub const DpiAwarenessContext = enum(usize) {
    null = 0,
    unaware = @bitCast(@as(isize, -1)),
    system_aware = @bitCast(@as(isize, -2)),
    per_monitor_aware = @bitCast(@as(isize, -3)),
    /// App handles DPI; Windows sends WM_DPICHANGED and does not blur content.
    per_monitor_aware_v2 = @bitCast(@as(isize, -4)),
    unaware_gdiscaled = @bitCast(@as(isize, -5)),
    _,
};

/// WM_* window messages.
pub const Messages = enum(u32) {
    null = 0x0000,
    create = 0x0001,
    destroy = 0x0002,
    move = 0x0003,
    size = 0x0005,
    activate = 0x0006,
    set_focus = 0x0007,
    kill_focus = 0x0008,
    enable = 0x000A,
    set_text = 0x000C,
    get_text = 0x000D,
    paint = 0x000F,
    close = 0x0010,
    quit = 0x0012,
    query_open = 0x0013,
    erase_bkgnd = 0x0014,
    show_window = 0x0018,
    activate_app = 0x001C,
    cancel_mode = 0x001F,
    set_cursor = 0x0020,
    mouse_activate = 0x0021,
    child_activate = 0x0022,
    get_min_max_info = 0x0024,
    query_drag_icon = 0x0037,
    compacting = 0x0041,
    window_pos_changing = 0x0046,
    window_pos_changed = 0x0047,
    input_lang_request_change = 0x0050,
    input_lang_change = 0x0051,
    user_changed = 0x0054,
    style_changing = 0x007C,
    style_changed = 0x007D,
    display_change = 0x007E,
    get_icon = 0x007F,
    nc_create = 0x0081,
    nc_destroy = 0x0082,
    nc_calc_size = 0x0083,
    nc_hit_test = 0x0084,
    nc_paint = 0x0085,
    nc_activate = 0x0086,
    input = 0x00FF,
    key_down = 0x0100,
    key_up = 0x0101,
    char = 0x0102,
    dead_char = 0x0103,
    sys_key_down = 0x0104,
    sys_key_up = 0x0105,
    sys_char = 0x0106,
    unichar = 0x0109,
    command = 0x0111,
    sys_command = 0x0112,
    timer = 0x0113,
    mouse_move = 0x0200,
    l_button_down = 0x0201,
    l_button_up = 0x0202,
    l_button_dbl_clk = 0x0203,
    r_button_down = 0x0204,
    r_button_up = 0x0205,
    r_button_dbl_clk = 0x0206,
    m_button_down = 0x0207,
    m_button_up = 0x0208,
    m_button_dbl_clk = 0x0209,
    mouse_wheel = 0x020A,
    x_button_down = 0x020B,
    x_button_up = 0x020C,
    x_button_dbl_clk = 0x020D,
    mouse_h_wheel = 0x020E,
    sizing = 0x0214,
    capture_changed = 0x0215,
    moving = 0x0216,
    enter_size_move = 0x0231,
    exit_size_move = 0x0232,
    drop_files = 0x0233,
    mouse_hover = 0x02A1,
    mouse_leave = 0x02A3,
    dpi_changed = 0x02E0,
    theme_changed = 0x031A,
    user = 0x0400,
    app = 0x8000,
    _,
};

/// ShowWindow SW_* commands.
pub const SW = enum(i32) {
    hide = 0,
    normal = 1,
    show_min = 2,
    max = 3,
    show_no_activate = 4,
    show = 5,
    min = 6,
    show_min_no_active = 7,
    show_na = 8,
    restore = 9,
    show_default = 10,
    force_minimize = 11,
};

/// PeekMessage PM_* options (combine with `@enumFromInt` if needed).
pub const RemoveMessage = enum(u32) {
    no_remove = 0,
    remove = 1,
    no_yield = 2,
    _,
};

/// Get/SetWindowLongPtr GWL(P)_* index.
pub const WindowLongIndex = enum(i32) {
    wnd_proc = -4,
    instance = -6,
    hwnd_parent = -8,
    id = -12,
    style = -16,
    ex_style = -20,
    user_data = -21,
    _,
};

/// GetSystemMetrics SM_* index.
pub const SystemMetric = enum(i32) {
    cx_screen = 0,
    cy_screen = 1,
    cx_vscroll = 2,
    cy_hscroll = 3,
    cy_caption = 4,
    cx_border = 5,
    cy_border = 6,
    cx_icon = 11,
    cy_icon = 12,
    cx_cursor = 13,
    cy_cursor = 14,
    cy_menu = 15,
    cx_full_screen = 16,
    cy_full_screen = 17,
    cx_min = 28,
    cy_min = 29,
    cx_frame = 32,
    cy_frame = 33,
    cx_small_icon = 49,
    cy_small_icon = 50,
    x_virtual_screen = 76,
    y_virtual_screen = 77,
    cx_virtual_screen = 78,
    cy_virtual_screen = 79,
    c_monitors = 80,
    _,
};

/// MonitorFromWindow / MonitorFromPoint MONITOR_DEFAULTTO*.
pub const MonitorDefault = enum(u32) {
    to_null = 0,
    to_primary = 1,
    to_nearest = 2,
};

/// Predefined cursors for LoadCursor (IDC_*).
pub const SystemCursor = enum(u16) {
    arrow = 32512,
    ibeam = 32513,
    wait = 32514,
    cross = 32515,
    up_arrow = 32516,
    size_nwse = 32642,
    size_nesw = 32643,
    size_we = 32644,
    size_ns = 32645,
    size_all = 32646,
    no = 32648,
    hand = 32649,
    app_starting = 32650,

    pub fn nameW(self: SystemCursor) t.ResourceNameW {
        return t.makeIntResourceW(@backingInt(self));
    }
    pub fn nameA(self: SystemCursor) t.ResourceNameA {
        return t.makeIntResourceA(@backingInt(self));
    }
};

/// Predefined icons for LoadIcon (IDI_*).
pub const SystemIcon = enum(u16) {
    application = 32512,
    @"error" = 32513,
    question = 32514,
    warning = 32515,
    information = 32516,
    win_logo = 32517,
    shield = 32518,

    pub fn nameW(self: SystemIcon) t.ResourceNameW {
        return t.makeIntResourceW(@backingInt(self));
    }
    pub fn nameA(self: SystemIcon) t.ResourceNameA {
        return t.makeIntResourceA(@backingInt(self));
    }
};

/// CoInitializeEx COINIT_* flags. `.{}` is COINIT_MULTITHREADED.
pub const CoInit = packed struct(u32) {
    _r0: u1 = 0,
    apartment_threaded: bool = false, // 0x2
    disable_ole1dde: bool = false, // 0x4
    speed_over_memory: bool = false, // 0x8
    _r4: u28 = 0,

    pub const multithreaded: CoInit = .{};
    pub const apartment: CoInit = .{ .apartment_threaded = true };
};

/// CoCreateInstance CLSCTX_* context.
pub const ClsCtx = enum(u32) {
    inproc_server = 0x1,
    inproc_handler = 0x2,
    local_server = 0x4,
    remote_server = 0x10,
    all = 0x17,
    _,
};

// ---------------------------------------------------------------------------
// user32: window queries
// ---------------------------------------------------------------------------

/// Get/SetClassLongPtr GCL(P)_* index.
pub const ClassLongIndex = enum(i32) {
    menu_name = -8,
    background = -10,
    cursor = -12,
    icon = -14,
    module = -16,
    wnd_extra = -18,
    cls_extra = -20,
    wnd_proc = -24,
    style = -26,
    atom = -32,
    small_icon = -34,
    _,
};

/// GetWindow GW_* relationship.
pub const GetWindowCmd = enum(u32) {
    first = 0,
    last = 1,
    next = 2,
    prev = 3,
    owner = 4,
    child = 5,
    enabled_popup = 6,
};

/// GetAncestor GA_* flags.
pub const Ancestor = enum(u32) {
    parent = 1,
    root = 2,
    root_owner = 3,
};

/// ChildWindowFromPointEx CWP_* flags. `.{}` is CWP_ALL.
pub const ChildFromPoint = packed struct(u32) {
    skip_invisible: bool = false, // 0x1
    skip_disabled: bool = false, // 0x2
    skip_transparent: bool = false, // 0x4
    _r3: u29 = 0,
};

/// AnimateWindow AW_* flags.
pub const AnimateWindowFlags = packed struct(u32) {
    hor_positive: bool = false, // 0x00001
    hor_negative: bool = false, // 0x00002
    ver_positive: bool = false, // 0x00004
    ver_negative: bool = false, // 0x00008
    center: bool = false, // 0x00010
    _r5: u11 = 0,
    hide: bool = false, // 0x10000
    activate: bool = false, // 0x20000
    slide: bool = false, // 0x40000
    blend: bool = false, // 0x80000
    _r20: u12 = 0,
};

/// Get/SetWindowDisplayAffinity WDA_* value.
pub const WindowDisplayAffinity = enum(u32) {
    none = 0x00,
    monitor = 0x01,
    exclude_from_capture = 0x11,
    _,
};

/// SetLayeredWindowAttributes LWA_* flags.
pub const LayeredWindowFlags = packed struct(u32) {
    color_key: bool = false, // 0x1
    alpha: bool = false, // 0x2
    _r2: u30 = 0,
};

/// UpdateLayeredWindow ULW_* flags.
pub const UpdateLayeredWindowFlags = packed struct(u32) {
    color_key: bool = false, // 0x1
    alpha: bool = false, // 0x2
    @"opaque": bool = false, // 0x4
    ex_no_resize: bool = false, // 0x8
    _r4: u28 = 0,
};

/// FLASHWINFO FLASHW_* flags. `.{}` is FLASHW_STOP.
pub const FlashWindowFlags = packed struct(u32) {
    caption: bool = false, // 0x1
    tray: bool = false, // 0x2
    timer: bool = false, // 0x4
    /// With `.timer`, makes FLASHW_TIMERNOFG (0xC): flash until the window comes to the foreground.
    no_fg: bool = false, // 0x8
    _r4: u28 = 0,

    pub const all: FlashWindowFlags = .{ .caption = true, .tray = true };
    pub const timer_no_fg: FlashWindowFlags = .{ .timer = true, .no_fg = true };
};

// ---------------------------------------------------------------------------
// user32: messages / hooks
// ---------------------------------------------------------------------------

/// GetQueueStatus / MsgWaitForMultipleObjects QS_* wake mask.
pub const QueueStatus = packed struct(u32) {
    key: bool = false, // 0x0001
    mouse_move: bool = false, // 0x0002
    mouse_button: bool = false, // 0x0004
    post_message: bool = false, // 0x0008
    timer: bool = false, // 0x0010
    paint: bool = false, // 0x0020
    send_message: bool = false, // 0x0040
    hotkey: bool = false, // 0x0080
    all_post_message: bool = false, // 0x0100
    _r9: u1 = 0,
    raw_input: bool = false, // 0x0400
    touch: bool = false, // 0x0800
    pointer: bool = false, // 0x1000
    _r13: u19 = 0,

    pub const mouse: QueueStatus = .{ .mouse_move = true, .mouse_button = true };
    pub const input: QueueStatus = .{
        .mouse_move = true,
        .mouse_button = true,
        .key = true,
        .raw_input = true,
        .touch = true,
        .pointer = true,
    };
    pub const all_events: QueueStatus = input.merge(.{ .post_message = true, .timer = true, .paint = true, .hotkey = true });
    pub const all_input: QueueStatus = all_events.merge(.{ .send_message = true });

    pub fn merge(a: QueueStatus, b: QueueStatus) QueueStatus {
        return @bitCast(@as(u32, @bitCast(a)) | @as(u32, @bitCast(b)));
    }
};

/// SendMessageTimeout SMTO_* flags. `.{}` is SMTO_NORMAL.
pub const SendMessageTimeoutFlags = packed struct(u32) {
    block: bool = false, // 0x01
    abort_if_hung: bool = false, // 0x02
    _r2: u1 = 0,
    no_timeout_if_not_hung: bool = false, // 0x08
    _r4: u1 = 0,
    error_on_exit: bool = false, // 0x20
    _r6: u26 = 0,
};

/// SetWindowsHookEx WH_* hook type.
pub const HookId = enum(i32) {
    msg_filter = -1,
    journal_record = 0,
    journal_playback = 1,
    keyboard = 2,
    get_message = 3,
    call_wnd_proc = 4,
    cbt = 5,
    sys_msg_filter = 6,
    mouse = 7,
    debug = 9,
    shell = 10,
    foreground_idle = 11,
    call_wnd_proc_ret = 12,
    keyboard_ll = 13,
    mouse_ll = 14,
    _,
};

/// SetWinEventHook WINEVENT_* flags. `.{}` is WINEVENT_OUTOFCONTEXT.
pub const WinEventHookFlags = packed struct(u32) {
    skip_own_thread: bool = false, // 0x1
    skip_own_process: bool = false, // 0x2
    in_context: bool = false, // 0x4
    _r3: u29 = 0,
};

/// RegisterHotKey MOD_* modifiers.
pub const HotKeyModifiers = packed struct(u32) {
    alt: bool = false, // 0x0001
    control: bool = false, // 0x0002
    shift: bool = false, // 0x0004
    win: bool = false, // 0x0008
    _r4: u10 = 0,
    no_repeat: bool = false, // 0x4000
    _r15: u17 = 0,
};

// ---------------------------------------------------------------------------
// user32: painting
// ---------------------------------------------------------------------------

/// RedrawWindow RDW_* flags.
pub const RedrawWindowFlags = packed struct(u32) {
    invalidate: bool = false, // 0x0001
    internal_paint: bool = false, // 0x0002
    erase: bool = false, // 0x0004
    validate: bool = false, // 0x0008
    no_internal_paint: bool = false, // 0x0010
    no_erase: bool = false, // 0x0020
    no_children: bool = false, // 0x0040
    all_children: bool = false, // 0x0080
    update_now: bool = false, // 0x0100
    erase_now: bool = false, // 0x0200
    frame: bool = false, // 0x0400
    no_frame: bool = false, // 0x0800
    _r12: u20 = 0,
};

/// GetDCEx DCX_* flags.
pub const GetDCExFlags = packed struct(u32) {
    window: bool = false, // 0x000001
    cache: bool = false, // 0x000002
    no_reset_attrs: bool = false, // 0x000004
    clip_children: bool = false, // 0x000008
    clip_siblings: bool = false, // 0x000010
    parent_clip: bool = false, // 0x000020
    exclude_rgn: bool = false, // 0x000040
    intersect_rgn: bool = false, // 0x000080
    exclude_update: bool = false, // 0x000100
    intersect_update: bool = false, // 0x000200
    lock_window_update: bool = false, // 0x000400
    _r11: u10 = 0,
    validate: bool = false, // 0x200000
    _r22: u10 = 0,
};

/// DrawText DT_* format. `.{}` is DT_TOP | DT_LEFT.
pub const DrawTextFormat = packed struct(u32) {
    center: bool = false, // 0x000001
    right: bool = false, // 0x000002
    v_center: bool = false, // 0x000004
    bottom: bool = false, // 0x000008
    word_break: bool = false, // 0x000010
    single_line: bool = false, // 0x000020
    expand_tabs: bool = false, // 0x000040
    tab_stop: bool = false, // 0x000080
    no_clip: bool = false, // 0x000100
    external_leading: bool = false, // 0x000200
    calc_rect: bool = false, // 0x000400
    no_prefix: bool = false, // 0x000800
    internal: bool = false, // 0x001000
    edit_control: bool = false, // 0x002000
    path_ellipsis: bool = false, // 0x004000
    end_ellipsis: bool = false, // 0x008000
    modify_string: bool = false, // 0x010000
    rtl_reading: bool = false, // 0x020000
    word_ellipsis: bool = false, // 0x040000
    no_full_width_char_break: bool = false, // 0x080000
    hide_prefix: bool = false, // 0x100000
    prefix_only: bool = false, // 0x200000
    _r22: u10 = 0,
};

/// GetScrollInfo / SetScrollInfo / ShowScrollBar SB_* bar.
pub const ScrollBar = enum(i32) {
    horz = 0,
    vert = 1,
    ctl = 2,
    both = 3,
};

/// SCROLLINFO SIF_* mask.
pub const ScrollInfoMask = packed struct(u32) {
    range: bool = false, // 0x01
    page: bool = false, // 0x02
    pos: bool = false, // 0x04
    disable_no_scroll: bool = false, // 0x08
    track_pos: bool = false, // 0x10
    _r5: u27 = 0,

    pub const all: ScrollInfoMask = .{ .range = true, .page = true, .pos = true, .track_pos = true };
};

// ---------------------------------------------------------------------------
// user32: resources
// ---------------------------------------------------------------------------

/// LoadImage / CopyImage IMAGE_* type.
pub const ImageType = enum(u32) {
    bitmap = 0,
    icon = 1,
    cursor = 2,
    enh_metafile = 3,
};

/// LoadImage / CopyImage LR_* flags. `.{}` is LR_DEFAULTCOLOR.
pub const LoadImageFlags = packed struct(u32) {
    monochrome: bool = false, // 0x0001
    color: bool = false, // 0x0002
    copy_return_org: bool = false, // 0x0004
    copy_delete_org: bool = false, // 0x0008
    load_from_file: bool = false, // 0x0010
    load_transparent: bool = false, // 0x0020
    default_size: bool = false, // 0x0040
    vga_color: bool = false, // 0x0080
    _r8: u4 = 0,
    load_map_3d_colors: bool = false, // 0x1000
    create_dib_section: bool = false, // 0x2000
    copy_from_resource: bool = false, // 0x4000
    shared: bool = false, // 0x8000
    _r16: u16 = 0,
};

// ---------------------------------------------------------------------------
// user32: menus
// ---------------------------------------------------------------------------

/// MF_* flags for AppendMenu / InsertMenu / ModifyMenu / EnableMenuItem / CheckMenuItem / ...
/// `.{}` is MF_STRING | MF_ENABLED | MF_UNCHECKED | MF_BYCOMMAND.
pub const MenuFlags = packed struct(u32) {
    grayed: bool = false, // 0x0001
    disabled: bool = false, // 0x0002
    bitmap: bool = false, // 0x0004
    checked: bool = false, // 0x0008
    popup: bool = false, // 0x0010
    menu_bar_break: bool = false, // 0x0020
    menu_break: bool = false, // 0x0040
    /// MF_HILITE (also MF_CHANGE for ChangeMenu).
    hilite: bool = false, // 0x0080
    /// MF_OWNERDRAW (also MF_APPEND for ChangeMenu).
    owner_draw: bool = false, // 0x0100
    /// MF_USECHECKBITMAPS (also MF_DELETE for ChangeMenu).
    use_check_bitmaps: bool = false, // 0x0200
    by_position: bool = false, // 0x0400
    separator: bool = false, // 0x0800
    /// MF_DEFAULT (also MF_REMOVE for ChangeMenu).
    default: bool = false, // 0x1000
    sys_menu: bool = false, // 0x2000
    /// MF_RIGHTJUSTIFY / MF_HELP.
    right_justify: bool = false, // 0x4000
    mouse_select: bool = false, // 0x8000
    _r16: u16 = 0,

    pub const by_command: MenuFlags = .{};
    pub const by_pos: MenuFlags = .{ .by_position = true };
};

/// TrackPopupMenu(Ex) TPM_* flags. `.{}` is TPM_LEFTBUTTON | TPM_LEFTALIGN | TPM_TOPALIGN.
pub const TrackPopupMenuFlags = packed struct(u32) {
    recurse: bool = false, // 0x00001
    right_button: bool = false, // 0x00002
    center_align: bool = false, // 0x00004
    right_align: bool = false, // 0x00008
    v_center_align: bool = false, // 0x00010
    bottom_align: bool = false, // 0x00020
    vertical: bool = false, // 0x00040
    no_notify: bool = false, // 0x00080
    /// TrackPopupMenu then returns the chosen command id instead of a BOOL.
    return_cmd: bool = false, // 0x00100
    _r9: u1 = 0,
    hor_pos_animation: bool = false, // 0x00400
    hor_neg_animation: bool = false, // 0x00800
    ver_pos_animation: bool = false, // 0x01000
    ver_neg_animation: bool = false, // 0x02000
    no_animation: bool = false, // 0x04000
    layout_rtl: bool = false, // 0x08000
    work_area: bool = false, // 0x10000
    _r17: u15 = 0,
};

/// MENUITEMINFO MIIM_* mask.
pub const MenuItemInfoMask = packed struct(u32) {
    state: bool = false, // 0x001
    id: bool = false, // 0x002
    submenu: bool = false, // 0x004
    checkmarks: bool = false, // 0x008
    type: bool = false, // 0x010
    data: bool = false, // 0x020
    string: bool = false, // 0x040
    bitmap: bool = false, // 0x080
    ftype: bool = false, // 0x100
    _r9: u23 = 0,
};

// ---------------------------------------------------------------------------
// user32: input
// ---------------------------------------------------------------------------

/// TRACKMOUSEEVENT TME_* flags.
pub const TrackMouseEventFlags = packed struct(u32) {
    hover: bool = false, // 0x00000001
    leave: bool = false, // 0x00000002
    _r2: u2 = 0,
    non_client: bool = false, // 0x00000010
    _r5: u25 = 0,
    query: bool = false, // 0x40000000
    cancel: bool = false, // 0x80000000
};

/// MapVirtualKey MAPVK_* translation.
pub const MapVirtualKeyType = enum(u32) {
    vk_to_vsc = 0,
    vsc_to_vk = 1,
    vk_to_char = 2,
    vsc_to_vk_ex = 3,
    vk_to_vsc_ex = 4,
};

/// INPUT.type.
pub const InputType = enum(u32) {
    mouse = 0,
    keyboard = 1,
    hardware = 2,
};

/// MOUSEINPUT / mouse_event MOUSEEVENTF_* flags.
pub const MouseEventFlags = packed struct(u32) {
    move: bool = false, // 0x0001
    left_down: bool = false, // 0x0002
    left_up: bool = false, // 0x0004
    right_down: bool = false, // 0x0008
    right_up: bool = false, // 0x0010
    middle_down: bool = false, // 0x0020
    middle_up: bool = false, // 0x0040
    x_down: bool = false, // 0x0080
    x_up: bool = false, // 0x0100
    _r9: u2 = 0,
    wheel: bool = false, // 0x0800
    h_wheel: bool = false, // 0x1000
    move_no_coalesce: bool = false, // 0x2000
    virtual_desk: bool = false, // 0x4000
    absolute: bool = false, // 0x8000
    _r16: u16 = 0,
};

/// KEYBDINPUT / keybd_event KEYEVENTF_* flags.
pub const KeyEventFlags = packed struct(u32) {
    extended_key: bool = false, // 0x1
    key_up: bool = false, // 0x2
    unicode: bool = false, // 0x4
    scan_code: bool = false, // 0x8
    _r4: u28 = 0,
};

/// RAWINPUTHEADER.type / RAWINPUTDEVICELIST.type (RIM_TYPE*).
pub const RawInputType = enum(u32) {
    mouse = 0,
    keyboard = 1,
    hid = 2,
    _,
};

/// GetRawInputData RID_* command.
pub const RawInputCommand = enum(u32) {
    input = 0x10000003,
    header = 0x10000005,
};

/// GetRawInputDeviceInfo RIDI_* command.
pub const RawInputDeviceInfoCommand = enum(u32) {
    preparsed_data = 0x20000005,
    device_name = 0x20000007,
    device_info = 0x2000000b,
};

/// RAWINPUTDEVICE RIDEV_* flags.
pub const RawInputDeviceFlags = packed struct(u32) {
    remove: bool = false, // 0x0001
    _r1: u3 = 0,
    exclude: bool = false, // 0x0010
    page_only: bool = false, // 0x0020
    _r6: u2 = 0,
    input_sink: bool = false, // 0x0100
    /// RIDEV_CAPTUREMOUSE for mice, RIDEV_NOHOTKEYS for keyboards.
    capture_mouse: bool = false, // 0x0200
    app_keys: bool = false, // 0x0400
    _r11: u1 = 0,
    ex_input_sink: bool = false, // 0x1000
    dev_notify: bool = false, // 0x2000
    _r14: u18 = 0,

    pub const no_legacy: RawInputDeviceFlags = .{ .exclude = true, .page_only = true };
    pub const no_hotkeys: RawInputDeviceFlags = .{ .capture_mouse = true };
};

// ---------------------------------------------------------------------------
// user32: pointer / touch input
// ---------------------------------------------------------------------------

/// POINTER_INPUT_TYPE (PT_*).
pub const PointerInputType = enum(u32) {
    pointer = 1,
    touch = 2,
    pen = 3,
    mouse = 4,
    touchpad = 5,
    _,
};

/// POINTER_FLAG_* bits.
pub const PointerFlags = packed struct(u32) {
    new: bool = false, // 0x000001
    in_range: bool = false, // 0x000002
    in_contact: bool = false, // 0x000004
    _r3: u1 = 0,
    first_button: bool = false, // 0x000010
    second_button: bool = false, // 0x000020
    third_button: bool = false, // 0x000040
    fourth_button: bool = false, // 0x000080
    fifth_button: bool = false, // 0x000100
    _r9: u4 = 0,
    primary: bool = false, // 0x002000
    confidence: bool = false, // 0x004000
    canceled: bool = false, // 0x008000
    down: bool = false, // 0x010000
    update: bool = false, // 0x020000
    up: bool = false, // 0x040000
    wheel: bool = false, // 0x080000
    h_wheel: bool = false, // 0x100000
    capture_changed: bool = false, // 0x200000
    has_transform: bool = false, // 0x400000
    _r23: u9 = 0,
};

pub const PointerButtonChangeType = enum(u32) {
    none = 0,
    first_button_down = 1,
    first_button_up = 2,
    second_button_down = 3,
    second_button_up = 4,
    third_button_down = 5,
    third_button_up = 6,
    fourth_button_down = 7,
    fourth_button_up = 8,
    fifth_button_down = 9,
    fifth_button_up = 10,
    _,
};

pub const PointerFeedbackMode = enum(u32) {
    default = 1,
    indirect = 2,
    none = 3,
};

/// Get/SetWindowFeedbackSetting FEEDBACK_TYPE.
pub const FeedbackType = enum(u32) {
    touch_contact_visualization = 1,
    pen_barrel_visualization = 2,
    pen_tap = 3,
    pen_double_tap = 4,
    pen_press_and_hold = 5,
    pen_right_tap = 6,
    touch_tap = 7,
    touch_double_tap = 8,
    touch_press_and_hold = 9,
    touch_right_tap = 10,
    gesture_press_and_tap = 11,
    _,
};

pub const PointerDeviceType = enum(u32) {
    integrated_pen = 1,
    external_pen = 2,
    touch = 3,
    touch_pad = 5,
    _,
};

pub const InputMessageDeviceType = enum(u32) {
    unavailable = 0x00,
    keyboard = 0x01,
    mouse = 0x02,
    touch = 0x04,
    pen = 0x08,
    touchpad = 0x10,
    _,
};

pub const InputMessageOriginId = enum(u32) {
    unavailable = 0x00,
    hardware = 0x01,
    injected = 0x02,
    system = 0x04,
    _,
};

// ---------------------------------------------------------------------------
// user32: DPI / display
// ---------------------------------------------------------------------------

pub const DpiAwareness = enum(i32) {
    invalid = -1,
    unaware = 0,
    system_aware = 1,
    per_monitor_aware = 2,
    _,
};

pub const DpiHostingBehavior = enum(i32) {
    invalid = -1,
    default = 0,
    mixed = 1,
    _,
};

/// MONITORINFO.flags.
pub const MonitorInfoFlags = packed struct(u32) {
    primary: bool = false, // 0x1
    _r1: u31 = 0,
};

/// GetAutoRotationState AR_* bits. `.{}` is AR_ENABLED.
pub const AutoRotationState = packed struct(u32) {
    disabled: bool = false, // 0x01
    suspended: bool = false, // 0x02
    remote_session: bool = false, // 0x04
    multimon: bool = false, // 0x08
    no_sensor: bool = false, // 0x10
    not_supported: bool = false, // 0x20
    docked: bool = false, // 0x40
    laptop: bool = false, // 0x80
    _r8: u24 = 0,
};

/// ORIENTATION_PREFERENCE bits. `.{}` is ORIENTATION_PREFERENCE_NONE.
pub const OrientationPreference = packed struct(u32) {
    landscape: bool = false, // 0x1
    portrait: bool = false, // 0x2
    landscape_flipped: bool = false, // 0x4
    portrait_flipped: bool = false, // 0x8
    _r4: u28 = 0,
};
