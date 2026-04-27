const std = @import("std");

// Color
pub const Color = enum(i32) {
    window = 5,
    window_frame = 6,
    window_text = 8,
};

const ClassStyle = enum(u32) {
    v_redraw = 1,
    h_redraw = 2,
};
pub const ClassStyles = std.EnumSet(ClassStyle);
pub const REDRAW: ClassStyles = .initMany(&.{ .h_redraw, .v_redraw });

pub const Messages = enum(u32) {
    null = 0x0000,
    create = 0x0001,
    destroy = 0x0002,
    move = 0x0003,
    size = 0x0005,
    sizing = 0x0214,
    enable = 0x000A,
    close = 0x0010,
    quit = 0x0012,
    query_open = 0x0013,
    show_window = 0x0018,
    activate_app = 0x001C,
    cancel_mode = 0x001F,
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
    nc_create = 0x0081,
    nc_destroy = 0x0082,
    nc_calc_size = 0x0083,
    nc_activate = 0x0086,
    get_icon = 0x007F,
    moving = 0x0216,
    enter_size_move = 0x0231,
    exit_size_move = 0x0232,
    theme_changed = 0x031A,
    _,
};

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
};

const WindowStyle = enum(u32) {
    overlapped = 0,
    maximize_box = 0x00_010_000,
    minimize_box = 0x00_020_000,
    thick_frame = 0x00_040_000,
    sys_menu = 0x00_080_000,
    h_scroll = 0x00_100_000,
    v_scroll = 0x00_200_000,
    dlg_frame = 0x00_400_000,
    border = 0x00_800_000,
    caption = 0x00_c00_000,
    max = 0x01_000_000,
    clip_children = 0x02_000_000,
    clip_siblings = 0x04_000_000,
    disabled = 0x08_000_000,
    visible = 0x10_000_000,
    min = 0x20_000_000,
    child = 0x40_000_000,
    pop_up = 0x80_000_000,
};
pub const WindowStyles = std.EnumSet(WindowStyle);
pub const OVERLAPPED_WINDOW: WindowStyles = .initMany(&.{
    .overlapped,
    .caption,
    .sys_menu,
    .thick_frame,
    .minimize_box,
    .maximize_box,
});
pub const POPUP_WINDOW: WindowStyles = .initMany(&.{ .popup, .border, .sysmenu });
pub const TILED_WINDOW: WindowStyles = .initMany(&.{
    .overlapped,
    .caption,
    .sys_menu,
    .thick_frame,
    .minimize_box,
    .maximize_box,
});
