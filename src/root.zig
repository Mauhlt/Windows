//! Zig bindings for the Win32 APIs used by this project.
//!
//!     const W = @import("Windows");
//!     const hinst = W.KERNEL.GetModuleHandleW(null);
//!     const hwnd = W.USER.CreateWindowExW(.{}, class, title, .overlapped_window, ...);

pub const ENUMS = @import("windows_enums.zig");
pub const TYPES = @import("windows_types.zig");
pub const STRUCTS = @import("windows_structs.zig");
pub const GUIDS = @import("windows_guids.zig");
pub const COM = @import("windows_com.zig");

pub const KERNEL = @import("windows_fns/kernel.zig");
pub const USER = @import("windows_fns/user.zig");
pub const OLE = @import("windows_fns/ole.zig");
pub const MF = @import("windows_fns/mf.zig");
pub const MFPLAT = @import("windows_fns/mfplat.zig");
pub const MFREADWRITE = @import("windows_fns/mfreadwrite.zig");

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

/// Force semantic analysis of every public declaration in every namespace,
/// including methods on nested types.
fn refAllDeclsRecursive(comptime T: type, comptime depth: u32) void {
    if (depth == 0) return;
    inline for (comptime std.meta.declarations(T)) |name| {
        const field = @field(T, name);
        if (@TypeOf(field) == type) {
            switch (@typeInfo(field)) {
                .@"struct", .@"enum", .@"union", .@"opaque" => refAllDeclsRecursive(field, depth - 1),
                else => {},
            }
        }
        _ = &field;
    }
}

test "analyze all declarations" {
    refAllDeclsRecursive(@This(), 4);
}

test "struct layouts match the Windows SDK (x64)" {
    if (builtin.cpu.arch != .x86_64) return error.SkipZigTest;
    const S = STRUCTS;
    try testing.expectEqual(16, @sizeOf(S.GUID));
    try testing.expectEqual(16, @sizeOf(S.RECT));
    try testing.expectEqual(48, @sizeOf(S.MSG));
    try testing.expectEqual(72, @sizeOf(S.PAINTSTRUCT));
    try testing.expectEqual(80, @sizeOf(S.CREATESTRUCTW));
    try testing.expectEqual(40, @sizeOf(S.MINMAXINFO));
    try testing.expectEqual(24, @sizeOf(S.SECURITY_ATTRIBUTES));
    try testing.expectEqual(72, @sizeOf(S.WNDCLASSW));
    try testing.expectEqual(80, @sizeOf(S.WNDCLASSEXW));
    try testing.expectEqual(80, @sizeOf(S.WNDCLASSEXA));

    // user32
    try testing.expectEqual(4, @sizeOf(S.POINTS));
    try testing.expectEqual(8, @sizeOf(S.LUID));
    try testing.expectEqual(44, @sizeOf(S.WINDOWPLACEMENT));
    try testing.expectEqual(60, @sizeOf(S.WINDOWINFO));
    try testing.expectEqual(44, @sizeOf(S.TITLEBARINFO));
    try testing.expectEqual(72, @sizeOf(S.GUITHREADINFO));
    try testing.expectEqual(40, @sizeOf(S.ALTTABINFO));
    try testing.expectEqual(32, @sizeOf(S.FLASHWINFO));
    try testing.expectEqual(40, @sizeOf(S.WINDOWPOS));
    try testing.expectEqual(80, @sizeOf(S.CREATESTRUCTA));
    try testing.expectEqual(4, @sizeOf(S.BLENDFUNCTION));
    try testing.expectEqual(80, @sizeOf(S.UPDATELAYEREDWINDOWINFO));
    try testing.expectEqual(8, @sizeOf(S.CHANGEFILTERSTRUCT));
    try testing.expectEqual(32, @sizeOf(S.BSMINFO));
    try testing.expectEqual(80, @sizeOf(S.MSGBOXPARAMSA));
    try testing.expectEqual(80, @sizeOf(S.MSGBOXPARAMSW));
    try testing.expectEqual(6, @sizeOf(S.ACCEL));
    try testing.expectEqual(40, @sizeOf(S.MENUINFO));
    try testing.expectEqual(80, @sizeOf(S.MENUITEMINFOA));
    try testing.expectEqual(80, @sizeOf(S.MENUITEMINFOW));
    try testing.expectEqual(48, @sizeOf(S.MENUBARINFO));
    try testing.expectEqual(20, @sizeOf(S.TPMPARAMS));
    try testing.expectEqual(20, @sizeOf(S.DRAWTEXTPARAMS));
    try testing.expectEqual(32, @sizeOf(S.ICONINFO));
    try testing.expectEqual(560, @sizeOf(S.ICONINFOEXA));
    try testing.expectEqual(1080, @sizeOf(S.ICONINFOEXW));
    try testing.expectEqual(24, @sizeOf(S.CURSORINFO));
    try testing.expectEqual(28, @sizeOf(S.SCROLLINFO));
    try testing.expectEqual(60, @sizeOf(S.SCROLLBARINFO));
    try testing.expectEqual(64, @sizeOf(S.COMBOBOXINFO));
    try testing.expectEqual(24, @sizeOf(S.TRACKMOUSEEVENT));
    try testing.expectEqual(24, @sizeOf(S.MOUSEMOVEPOINT));
    try testing.expectEqual(8, @sizeOf(S.LASTINPUTINFO));
    try testing.expectEqual(32, @sizeOf(S.MOUSEINPUT));
    try testing.expectEqual(24, @sizeOf(S.KEYBDINPUT));
    try testing.expectEqual(8, @sizeOf(S.HARDWAREINPUT));
    try testing.expectEqual(40, @sizeOf(S.INPUT));
    try testing.expectEqual(48, @sizeOf(S.TOUCHINPUT));
    try testing.expectEqual(56, @sizeOf(S.GESTUREINFO));
    try testing.expectEqual(12, @sizeOf(S.GESTURECONFIG));
    try testing.expectEqual(16, @sizeOf(S.RAWINPUTDEVICE));
    try testing.expectEqual(16, @sizeOf(S.RAWINPUTDEVICELIST));
    try testing.expectEqual(24, @sizeOf(S.RAWINPUTHEADER));
    try testing.expectEqual(24, @sizeOf(S.RAWMOUSE));
    try testing.expectEqual(16, @sizeOf(S.RAWKEYBOARD));
    try testing.expectEqual(12, @sizeOf(S.RAWHID));
    try testing.expectEqual(48, @sizeOf(S.RAWINPUT));
    try testing.expectEqual(32, @sizeOf(S.RID_DEVICE_INFO));
    try testing.expectEqual(96, @sizeOf(S.POINTER_INFO));
    try testing.expectEqual(144, @sizeOf(S.POINTER_TOUCH_INFO));
    try testing.expectEqual(120, @sizeOf(S.POINTER_PEN_INFO));
    try testing.expectEqual(152, @sizeOf(S.POINTER_TYPE_INFO));
    try testing.expectEqual(1080, @sizeOf(S.POINTER_DEVICE_INFO));
    try testing.expectEqual(28, @sizeOf(S.POINTER_DEVICE_PROPERTY));
    try testing.expectEqual(8, @sizeOf(S.POINTER_DEVICE_CURSOR_INFO));
    try testing.expectEqual(48, @sizeOf(S.TOUCH_HIT_TESTING_INPUT));
    try testing.expectEqual(12, @sizeOf(S.TOUCH_HIT_TESTING_PROXIMITY_EVALUATION));
    try testing.expectEqual(64, @sizeOf(S.INPUT_TRANSFORM));
    try testing.expectEqual(8, @sizeOf(S.INPUT_MESSAGE_SOURCE));
    try testing.expectEqual(40, @sizeOf(S.MONITORINFO));
    try testing.expectEqual(72, @sizeOf(S.MONITORINFOEXA));
    try testing.expectEqual(104, @sizeOf(S.MONITORINFOEXW));
    try testing.expectEqual(424, @sizeOf(S.DISPLAY_DEVICEA));
    try testing.expectEqual(840, @sizeOf(S.DISPLAY_DEVICEW));
    try testing.expectEqual(156, @sizeOf(S.DEVMODEA));
    try testing.expectEqual(220, @sizeOf(S.DEVMODEW));
    try testing.expectEqual(20, @sizeOf(S.DISPLAYCONFIG_PATH_SOURCE_INFO));
    try testing.expectEqual(48, @sizeOf(S.DISPLAYCONFIG_PATH_TARGET_INFO));
    try testing.expectEqual(72, @sizeOf(S.DISPLAYCONFIG_PATH_INFO));
    try testing.expectEqual(48, @sizeOf(S.DISPLAYCONFIG_VIDEO_SIGNAL_INFO));
    try testing.expectEqual(64, @sizeOf(S.DISPLAYCONFIG_MODE_INFO));
    try testing.expectEqual(20, @sizeOf(S.DISPLAYCONFIG_DEVICE_INFO_HEADER));

    // Offsets that depend on padding / unions.
    try testing.expectEqual(4, @offsetOf(S.RAWMOUSE, "button_flags"));
    try testing.expectEqual(8, @offsetOf(S.INPUT, "data"));
    try testing.expectEqual(24, @offsetOf(S.GESTUREINFO, "location"));
    try testing.expectEqual(40, @offsetOf(S.GESTUREINFO, "arguments"));
    try testing.expectEqual(80, @offsetOf(S.POINTER_INFO, "performance_count"));
    try testing.expectEqual(76, @offsetOf(S.DEVMODEW, "position"));
    try testing.expectEqual(102, @offsetOf(S.DEVMODEW, "form_name"));
    try testing.expectEqual(168, @offsetOf(S.DEVMODEW, "bits_per_pel"));
    try testing.expectEqual(184, @offsetOf(S.DEVMODEW, "display_frequency"));
    try testing.expectEqual(104, @offsetOf(S.DEVMODEA, "bits_per_pel"));
    try testing.expectEqual(16, @offsetOf(S.DISPLAYCONFIG_MODE_INFO, "mode"));
    try testing.expectEqual(40, @offsetOf(S.MENUBARINFO, "focus"));
    try testing.expectEqual(72, @offsetOf(S.MENUITEMINFOW, "bmp_item"));
    try testing.expectEqual(34, @offsetOf(S.ICONINFOEXW, "mod_name"));
}

test "every USER function links against user32" {
    // Taking each function's address at runtime forces the linker to resolve the import,
    // so a misspelled or nonexistent export fails here instead of in a consumer.
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var count: usize = 0;
    inline for (comptime std.meta.declarations(USER)) |name| {
        const field = @field(USER, name);
        const info = @typeInfo(@TypeOf(field));
        if (info == .@"fn" and !info.@"fn".is_generic and info.@"fn".attrs.@"callconv" != .@"inline") {
            const addr: *const volatile anyopaque = @ptrCast(&field);
            try testing.expect(@intFromPtr(addr) != 0);
            count += 1;
        }
    }
    try testing.expect(count > 600);
}

test "COM vtables have the header's method count" {
    const P = @sizeOf(usize);
    try testing.expectEqual(3 * P, @sizeOf(COM.IUnknown.Vtbl));
    try testing.expectEqual(33 * P, @sizeOf(COM.IMFAttributes.Vtbl));
    try testing.expectEqual(38 * P, @sizeOf(COM.IMFMediaType.Vtbl));
    try testing.expectEqual(36 * P, @sizeOf(COM.IMFActivate.Vtbl));
    try testing.expectEqual(47 * P, @sizeOf(COM.IMFSample.Vtbl));
    try testing.expectEqual(8 * P, @sizeOf(COM.IMFMediaBuffer.Vtbl));
    try testing.expectEqual(13 * P, @sizeOf(COM.IMFMediaSource.Vtbl));
    try testing.expectEqual(13 * P, @sizeOf(COM.IMFSourceReader.Vtbl));
}

test "flag sets have the SDK bit values" {
    const E = ENUMS;
    const u = struct {
        fn v(x: anytype) u32 {
            return @bitCast(x);
        }
    }.v;
    try testing.expectEqual(0x00CF0000, u(E.WindowStyle.overlapped_window));
    try testing.expectEqual(0x80880000, u(E.WindowStyle.popup_window));
    try testing.expectEqual(0x00C00000, u(E.WindowStyle.caption));
    try testing.expectEqual(0x10000000, u(E.WindowStyle{ .visible = true }));
    try testing.expectEqual(0x40000000, u(E.WindowStyle{ .child = true }));
    try testing.expectEqual(0x00000003, u(E.ClassStyle.redraw));
    try testing.expectEqual(0x00000020, u(E.ClassStyle{ .own_dc = true }));
    try testing.expectEqual(0x00020000, u(E.ClassStyle{ .drop_shadow = true }));
    try testing.expectEqual(0x00000008, u(E.WindowStyleEx{ .topmost = true }));
    try testing.expectEqual(0x00040000, u(E.WindowStyleEx{ .app_window = true }));
    try testing.expectEqual(0x00080000, u(E.WindowStyleEx{ .layered = true }));
    try testing.expectEqual(0x00200000, u(E.WindowStyleEx{ .no_redirection_bitmap = true }));
    try testing.expectEqual(0x02000000, u(E.WindowStyleEx{ .composited = true }));
    try testing.expectEqual(0x08000000, u(E.WindowStyleEx{ .no_activate = true }));
    try testing.expectEqual(0x00000020, u(E.SetWindowPosFlags{ .frame_changed = true }));
    try testing.expectEqual(0x00002000, u(E.SetWindowPosFlags{ .defer_erase = true }));
    try testing.expectEqual(0x00004000, u(E.SetWindowPosFlags{ .async_window_pos = true }));
    try testing.expectEqual(0x00000002, u(E.CoInit.apartment));
    try testing.expectEqual(0x00000200, u(MFREADWRITE.SourceReaderFlags{ .all_effects_removed = true }));
    try testing.expectEqual(0x00000100, u(MFREADWRITE.SourceReaderFlags{ .stream_tick = true }));

    // user32
    try testing.expectEqual(0x00080000, u(E.AnimateWindowFlags{ .blend = true }));
    try testing.expectEqual(0x00010010, u(E.AnimateWindowFlags{ .hide = true, .center = true }));
    try testing.expectEqual(0x00000004, u(E.UpdateLayeredWindowFlags{ .@"opaque" = true }));
    try testing.expectEqual(0x00000003, u(E.FlashWindowFlags.all));
    try testing.expectEqual(0x0000000C, u(E.FlashWindowFlags.timer_no_fg));
    try testing.expectEqual(0x00000006, u(E.QueueStatus.mouse));
    try testing.expectEqual(0x00001C07, u(E.QueueStatus.input));
    try testing.expectEqual(0x00001CBF, u(E.QueueStatus.all_events));
    try testing.expectEqual(0x00001CFF, u(E.QueueStatus.all_input));
    try testing.expectEqual(0x00000400, u(E.QueueStatus{ .raw_input = true }));
    try testing.expectEqual(0x00000020, u(E.SendMessageTimeoutFlags{ .error_on_exit = true }));
    try testing.expectEqual(0x00000008, u(E.SendMessageTimeoutFlags{ .no_timeout_if_not_hung = true }));
    try testing.expectEqual(0x00004000, u(E.HotKeyModifiers{ .no_repeat = true }));
    try testing.expectEqual(0x00000585, u(E.RedrawWindowFlags{ .invalidate = true, .erase = true, .all_children = true, .update_now = true, .frame = true }));
    try testing.expectEqual(0x00200000, u(E.GetDCExFlags{ .validate = true }));
    try testing.expectEqual(0x00000400, u(E.GetDCExFlags{ .lock_window_update = true }));
    try testing.expectEqual(0x00000425, u(E.DrawTextFormat{ .center = true, .v_center = true, .single_line = true, .calc_rect = true }));
    try testing.expectEqual(0x00200000, u(E.DrawTextFormat{ .prefix_only = true }));
    try testing.expectEqual(0x00000017, u(E.ScrollInfoMask.all));
    try testing.expectEqual(0x00008000, u(E.LoadImageFlags{ .shared = true }));
    try testing.expectEqual(0x00001000, u(E.LoadImageFlags{ .load_map_3d_colors = true }));
    try testing.expectEqual(0x00000050, u(E.LoadImageFlags{ .load_from_file = true, .default_size = true }));
    try testing.expectEqual(0x00000400, u(E.MenuFlags.by_pos));
    try testing.expectEqual(0x00000800, u(E.MenuFlags{ .separator = true }));
    try testing.expectEqual(0x00000010, u(E.MenuFlags{ .popup = true }));
    try testing.expectEqual(0x00008000, u(E.MenuFlags{ .mouse_select = true }));
    try testing.expectEqual(0x00000100, u(E.TrackPopupMenuFlags{ .return_cmd = true }));
    try testing.expectEqual(0x00010000, u(E.TrackPopupMenuFlags{ .work_area = true }));
    try testing.expectEqual(0x00004000, u(E.TrackPopupMenuFlags{ .no_animation = true }));
    try testing.expectEqual(0x00000100, u(E.MenuItemInfoMask{ .ftype = true }));
    try testing.expectEqual(0x40000000, u(E.TrackMouseEventFlags{ .query = true }));
    try testing.expectEqual(0x80000000, u(E.TrackMouseEventFlags{ .cancel = true }));
    try testing.expectEqual(0x00000010, u(E.TrackMouseEventFlags{ .non_client = true }));
    try testing.expectEqual(0x00000800, u(E.MouseEventFlags{ .wheel = true }));
    try testing.expectEqual(0x00008000, u(E.MouseEventFlags{ .absolute = true }));
    try testing.expectEqual(0x00000100, u(E.MouseEventFlags{ .x_up = true }));
    try testing.expectEqual(0x00000008, u(E.KeyEventFlags{ .scan_code = true }));
    try testing.expectEqual(0x00000030, u(E.RawInputDeviceFlags.no_legacy));
    try testing.expectEqual(0x00000200, u(E.RawInputDeviceFlags.no_hotkeys));
    try testing.expectEqual(0x00000100, u(E.RawInputDeviceFlags{ .input_sink = true }));
    try testing.expectEqual(0x00002000, u(E.RawInputDeviceFlags{ .dev_notify = true }));
    try testing.expectEqual(0x00002000, u(E.PointerFlags{ .primary = true }));
    try testing.expectEqual(0x00400000, u(E.PointerFlags{ .has_transform = true }));
    try testing.expectEqual(0x00000100, u(E.PointerFlags{ .fifth_button = true }));
    try testing.expectEqual(0x00000080, u(E.AutoRotationState{ .laptop = true }));
    try testing.expectEqual(0x00000008, u(E.OrientationPreference{ .portrait_flipped = true }));
}

test "message parameter helpers" {
    const lp: TYPES.LPARAM = @enumFromInt(@as(isize, @as(i32, @bitCast(@as(u32, 0xFFF6_0014))))); // y = -10, x = 20
    try testing.expectEqual(20, USER.getXLParam(lp));
    try testing.expectEqual(-10, USER.getYLParam(lp));
    try testing.expectEqual(0x0014, USER.loWord(lp));
    try testing.expectEqual(0xFFF6, USER.hiWord(lp));
    const wp: TYPES.WPARAM = @enumFromInt(@as(usize, @as(u16, @bitCast(@as(i16, -120)))) << 16);
    try testing.expectEqual(-120, USER.getWheelDeltaWParam(wp));
    try testing.expectEqual(0x00FF8040, TYPES.rgb(0x40, 0x80, 0xFF));
    // Plain integers (GetMessagePos) and WPARAMs with the high bit set.
    try testing.expectEqual(0x1234, USER.hiWord(@as(u32, 0x1234_5678)));
    try testing.expectEqual(0xFFFF, USER.loWord(@as(TYPES.WPARAM, @enumFromInt(~@as(usize, 0)))));
    var x: u32 = 5;
    try testing.expectEqual(&x, TYPES.LPARAM.fromPtr(&x).toPtr(u32));
}

test "GUID.parse matches hand-written values" {
    const expected = STRUCTS.GUID{
        .data1 = 0xc60ac5fe,
        .data2 = 0x252a,
        .data3 = 0x478f,
        .data4 = .{ 0xa0, 0xef, 0xbc, 0x8f, 0xa5, 0xf7, 0xca, 0xd3 },
    };
    try testing.expect(expected.eql(&GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE));
    try testing.expectEqual(0x3231564E, GUIDS.MFVideoFormat_NV12.data1);
    try testing.expectEqual(0x00020070, MFPLAT.MF_VERSION);
}

test "HRESULT is 32-bit and classifies correctly" {
    try testing.expectEqual(4, @sizeOf(TYPES.HRESULT));
    try testing.expect(TYPES.HRESULT.ok.succeeded());
    try testing.expect(TYPES.HRESULT.false.succeeded());
    try testing.expect(TYPES.HRESULT.fail.failed());
    try testing.expectError(error.HResultFailed, MFPLAT.MF_E_NO_MORE_TYPES.check());
}

// --- Live tests: actually call into the DLLs --------------------------------

test "live: register class, create and destroy a hidden window" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const L = std.unicode.utf8ToUtf16LeStringLiteral;
    const Proc = struct {
        fn wndProc(hwnd: TYPES.HWND, msg: u32, wp: TYPES.WPARAM, lp: TYPES.LPARAM) callconv(.winapi) TYPES.LRESULT {
            return USER.DefWindowProcW(hwnd, msg, wp, lp);
        }
    };
    const instance = KERNEL.GetModuleHandleW(null);
    try testing.expect(instance != .null);

    const class_name = L("ZigWindowsBindingsTest");
    const wc: STRUCTS.WNDCLASSEXW = .{
        .style = .redraw,
        .wnd_proc = Proc.wndProc,
        .instance = instance,
        .cursor = USER.LoadCursorW(.null, ENUMS.SystemCursor.arrow.nameW()),
        .icon = USER.LoadIconW(.null, ENUMS.SystemIcon.application.nameW()),
        .brush = USER.GetSysColorBrush(.window),
        .class_name = class_name,
    };
    try testing.expect(wc.cursor != .null);
    try testing.expect(wc.icon != .null);
    try testing.expect(USER.RegisterClassExW(&wc) != .null);
    defer _ = USER.UnregisterClassW(class_name, instance);

    const hwnd = USER.CreateWindowExW(.{}, class_name, L("test"), .overlapped_window, USER.CW_USEDEFAULT, USER.CW_USEDEFAULT, 320, 240, .null, .null, instance, null);
    try testing.expect(hwnd != .null);
    defer _ = USER.DestroyWindow(hwnd);

    var value: u32 = 1234;
    USER.setUserData(hwnd, &value);
    try testing.expectEqual(&value, USER.getUserData(u32, hwnd).?);

    var rect: STRUCTS.RECT = undefined;
    try testing.expect(USER.GetWindowRect(hwnd, &rect).toBool());
    try testing.expectEqual(320, rect.width());
    try testing.expect(USER.GetDpiForWindow(hwnd) > 0);
}

test "live: Media Foundation attributes round-trip and device enumeration" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const hr = OLE.CoInitializeEx(null, .multithreaded);
    try hr.check();
    defer OLE.CoUninitialize();

    try MFPLAT.MFStartup(MFPLAT.MF_VERSION, MFPLAT.MFSTARTUP_FULL).check();
    defer _ = MFPLAT.MFShutdown();

    var attrs_opt: ?*COM.IMFAttributes = null;
    try MFPLAT.MFCreateAttributes(&attrs_opt, 1).check();
    const attrs = attrs_opt.?;
    defer _ = attrs.release();

    // GUID round trip.
    try attrs.setGUID(&GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, &GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID).check();
    var got: STRUCTS.GUID = undefined;
    try attrs.getGUID(&GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, &got).check();
    try testing.expect(got.eql(&GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID));

    // Media type: packed size / ratio helpers, plus the IMFMediaType-specific slot.
    var mt_opt: ?*COM.IMFMediaType = null;
    try MFPLAT.MFCreateMediaType(&mt_opt).check();
    const mt = mt_opt.?;
    defer _ = mt.release();
    try mt.attributes().setGUID(&GUIDS.MF_MT_MAJOR_TYPE, &GUIDS.MFMediaType_Video).check();
    try mt.attributes().setSize(&GUIDS.MF_MT_FRAME_SIZE, 1920, 1080).check();
    const size = try mt.attributes().getSize(&GUIDS.MF_MT_FRAME_SIZE);
    try testing.expectEqual(1920, size.width);
    try testing.expectEqual(1080, size.height);
    var major: STRUCTS.GUID = undefined;
    try mt.getMajorType(&major).check();
    try testing.expect(major.eql(&GUIDS.MFMediaType_Video));
    var stride: u32 = 0;
    try testing.expectEqual(MFPLAT.MF_E_ATTRIBUTENOTFOUND, mt.attributes().getUINT32(&GUIDS.MF_MT_DEFAULT_STRIDE, &stride));

    // Device enumeration (0 cameras is fine).
    var devices: ?[*]*COM.IMFActivate = null;
    var count: u32 = 0;
    try MF.MFEnumDeviceSources(attrs, &devices, &count).check();
    defer OLE.CoTaskMemFree(@ptrCast(devices));
    // `devices` is null when there are no cameras.
    const list: []*COM.IMFActivate = if (devices) |d| d[0..count] else &.{};
    for (list) |dev| {
        defer _ = dev.release();
        var name: ?[*:0]u16 = null;
        var len: u32 = 0;
        try dev.attributes().getAllocatedString(&GUIDS.MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME, &name, &len).check();
        defer OLE.CoTaskMemFree(name);
        try testing.expectEqual(len, std.mem.len(name.?));
    }
}

test "live: user32 rect math" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var a: STRUCTS.RECT = undefined;
    var b: STRUCTS.RECT = undefined;
    var out: STRUCTS.RECT = undefined;
    try testing.expect(USER.SetRect(&a, 0, 0, 100, 50).toBool());
    try testing.expect(USER.SetRect(&b, 50, 25, 200, 200).toBool());
    try testing.expect(USER.IntersectRect(&out, &a, &b).toBool());
    try testing.expectEqual(STRUCTS.RECT{ .left = 50, .top = 25, .right = 100, .bottom = 50 }, out);
    try testing.expect(USER.UnionRect(&out, &a, &b).toBool());
    try testing.expectEqual(200, out.width());
    try testing.expect(USER.InflateRect(&a, 10, 10).toBool());
    try testing.expectEqual(-10, a.left);
    try testing.expect(USER.PtInRect(&a, .{ .x = 0, .y = 0 }).toBool());
    try testing.expect(!USER.PtInRect(&a, .{ .x = 500, .y = 0 }).toBool());
    try testing.expect(USER.SetRectEmpty(&a).toBool());
    try testing.expect(USER.IsRectEmpty(&a).toBool());
}

test "live: user32 window text, props, placement, messages, timers" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const L = std.unicode.utf8ToUtf16LeStringLiteral;
    const Proc = struct {
        fn wndProc(hwnd: TYPES.HWND, msg: u32, wp: TYPES.WPARAM, lp: TYPES.LPARAM) callconv(.winapi) TYPES.LRESULT {
            return USER.DefWindowProcW(hwnd, msg, wp, lp);
        }
    };
    const instance = KERNEL.GetModuleHandleW(null);
    const class_name = L("ZigWindowsBindingsTest2");
    const wc: STRUCTS.WNDCLASSEXW = .{ .wnd_proc = Proc.wndProc, .instance = instance, .class_name = class_name };
    const atom = USER.RegisterClassExW(&wc);
    try testing.expect(atom != .null);
    defer _ = USER.UnregisterClassW(class_name, instance);

    // Class lookup by atom and by name.
    var info: STRUCTS.WNDCLASSEXW = .{ .wnd_proc = null, .class_name = null };
    try testing.expect(USER.GetClassInfoExW(instance, TYPES.makeIntResourceW(@backingInt(atom)), &info).toBool());
    try testing.expectEqual(@as(?TYPES.WndProc, Proc.wndProc), info.wnd_proc);

    const hwnd = USER.CreateWindowExW(.{}, class_name, L("hello"), .overlapped_window, 10, 20, 300, 200, .null, .null, instance, null);
    try testing.expect(hwnd != .null);
    defer _ = USER.DestroyWindow(hwnd);
    try testing.expect(USER.IsWindow(hwnd).toBool());
    try testing.expect(USER.IsWindowUnicode(hwnd).toBool());
    try testing.expect(!USER.IsWindowVisible(hwnd).toBool());

    // Window text round trip.
    try testing.expect(USER.SetWindowTextW(hwnd, L("Zig ✓")).toBool());
    try testing.expectEqual(5, USER.GetWindowTextLengthW(hwnd));
    var buf: [64]u16 = undefined;
    const n = USER.GetWindowTextW(hwnd, &buf, buf.len);
    try testing.expectEqualSlices(u16, L("Zig ✓"), buf[0..@intCast(n)]);
    const cn = USER.GetClassNameW(hwnd, &buf, buf.len);
    try testing.expectEqualSlices(u16, class_name, buf[0..@intCast(cn)]);

    // Lookup by class + title.
    try testing.expectEqual(hwnd, USER.FindWindowExW(.null, .null, class_name, L("Zig ✓")));

    // Properties.
    const prop: TYPES.HANDLE = @enumFromInt(0x1234);
    try testing.expect(USER.SetPropW(hwnd, L("zig.prop"), prop).toBool());
    try testing.expectEqual(prop, USER.GetPropW(hwnd, L("zig.prop")));
    try testing.expectEqual(prop, USER.RemovePropW(hwnd, L("zig.prop")));
    try testing.expectEqual(TYPES.HANDLE.null, USER.GetPropW(hwnd, L("zig.prop")));

    // Geometry / info structs (cbSize-style defaults).
    var wp: STRUCTS.WINDOWPLACEMENT = .{};
    try testing.expect(USER.GetWindowPlacement(hwnd, &wp).toBool());
    try testing.expectEqual(10, wp.normal_position.left);
    try testing.expectEqual(300, wp.normal_position.width());
    var wi: STRUCTS.WINDOWINFO = .{};
    try testing.expect(USER.GetWindowInfo(hwnd, &wi).toBool());
    try testing.expect(wi.style.sys_menu);
    try testing.expectEqual(atom, wi.atom_window_type);
    try testing.expectEqual(USER.GetDesktopWindow(), USER.GetAncestor(hwnd, .parent));
    var pid: u32 = 0;
    try testing.expectEqual(KERNEL.GetCurrentThreadId(), USER.GetWindowThreadProcessId(hwnd, &pid));
    try testing.expectEqual(KERNEL.GetCurrentProcessId(), pid);

    // Posted message round trip.
    const msg_id = USER.RegisterWindowMessageW(L("ZigWindowsBindings.Test"));
    try testing.expect(msg_id >= 0xC000);
    try testing.expect(USER.PostMessageW(hwnd, msg_id, @enumFromInt(7), @enumFromInt(-9)).toBool());
    try testing.expect(USER.GetQueueStatus(.{ .post_message = true }) & 0x8 != 0);
    var msg: STRUCTS.MSG = undefined;
    try testing.expect(USER.PeekMessageW(&msg, hwnd, msg_id, msg_id, .remove).toBool());
    try testing.expectEqual(msg_id, msg.msg);
    try testing.expectEqual(@as(TYPES.WPARAM, @enumFromInt(7)), msg.wParam);
    try testing.expectEqual(@as(TYPES.LPARAM, @enumFromInt(-9)), msg.lParam);

    // SendMessageTimeout reaches DefWindowProc (WM_GETTEXTLENGTH = 0x000E).
    var result: usize = 0;
    try testing.expect(USER.SendMessageTimeoutW(hwnd, 0x000E, .null, .null, .{ .abort_if_hung = true }, 1000, &result) != .null);
    try testing.expectEqual(5, result);

    // Timers.
    try testing.expectEqual(42, USER.SetTimer(hwnd, 42, 10_000, null));
    try testing.expect(USER.KillTimer(hwnd, 42).toBool());

    // Enumerate thread windows: ours must be in the list.
    const Finder = struct {
        target: TYPES.HWND,
        found: bool = false,
        fn cb(h: TYPES.HWND, lp: TYPES.LPARAM) callconv(.winapi) TYPES.BOOL {
            const self = lp.toPtr(@This());
            if (h == self.target) self.found = true;
            return .true;
        }
    };
    var finder: Finder = .{ .target = hwnd };
    _ = USER.EnumThreadWindows(KERNEL.GetCurrentThreadId(), Finder.cb, .fromPtr(&finder));
    try testing.expect(finder.found);
}

test "live: user32 menus and accelerators" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const L = std.unicode.utf8ToUtf16LeStringLiteral;
    const menu = USER.CreatePopupMenu();
    try testing.expect(menu != .null);
    defer _ = USER.DestroyMenu(menu);
    try testing.expect(USER.IsMenu(menu).toBool());
    try testing.expect(USER.AppendMenuW(menu, .{}, 100, L("&Open")).toBool());
    try testing.expect(USER.AppendMenuW(menu, .{ .separator = true }, 0, null).toBool());
    try testing.expect(USER.AppendMenuW(menu, .{ .grayed = true }, 101, L("Close")).toBool());
    try testing.expectEqual(3, USER.GetMenuItemCount(menu));
    try testing.expectEqual(101, USER.GetMenuItemID(menu, 2));

    var buf: [32]u16 = undefined;
    const n = USER.GetMenuStringW(menu, 100, &buf, buf.len, .by_command);
    try testing.expectEqualSlices(u16, L("&Open"), buf[0..@intCast(n)]);

    _ = USER.CheckMenuItem(menu, 100, .{ .checked = true });
    const state: ENUMS.MenuFlags = @bitCast(USER.GetMenuState(menu, 100, .by_command));
    try testing.expect(state.checked);
    const sep: ENUMS.MenuFlags = @bitCast(USER.GetMenuState(menu, 1, .by_pos));
    try testing.expect(sep.separator);

    var mii: STRUCTS.MENUITEMINFOW = .{ .mask = .{ .state = true, .id = true } };
    try testing.expect(USER.GetMenuItemInfoW(menu, 2, .true, &mii).toBool());
    try testing.expectEqual(101, mii.id);
    try testing.expect(mii.state & 0x3 != 0); // MFS_GRAYED

    const accels = [_]STRUCTS.ACCEL{
        .{ .virt = 0x01 | 0x08, .key = 'O', .cmd = 100 }, // FVIRTKEY | FCONTROL
        .{ .virt = 0x01, .key = 0x1B, .cmd = 101 }, // VK_ESCAPE
    };
    const table = USER.CreateAcceleratorTableW(&accels, accels.len);
    try testing.expect(table != .null);
    defer _ = USER.DestroyAcceleratorTable(table);
    try testing.expectEqual(2, USER.CopyAcceleratorTableW(table, null, 0));
    var copy: [2]STRUCTS.ACCEL = undefined;
    try testing.expectEqual(2, USER.CopyAcceleratorTableW(table, &copy, copy.len));
    try testing.expectEqual(accels[0].cmd, copy[0].cmd);
    try testing.expectEqual(accels[1].key, copy[1].key);
}

test "live: user32 monitors, display settings, DPI, input state" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const primary = USER.MonitorFromPoint(.{ .x = 0, .y = 0 }, .to_primary);
    try testing.expect(primary != .null);
    var mi: STRUCTS.MONITORINFOEXW = .{};
    try testing.expect(USER.GetMonitorInfoW(primary, @ptrCast(&mi)).toBool());
    try testing.expect(mi.flags.primary);
    try testing.expect(mi.monitor.width() > 0);
    try testing.expect(mi.device[0] == '\\'); // "\\.\DISPLAY1"

    const Counter = struct {
        fn cb(_: TYPES.HMONITOR, _: TYPES.HDC, _: *STRUCTS.RECT, lp: TYPES.LPARAM) callconv(.winapi) TYPES.BOOL {
            const n = lp.toPtr(u32);
            n.* += 1;
            return .true;
        }
    };
    var monitors: u32 = 0;
    try testing.expect(USER.EnumDisplayMonitors(.null, null, Counter.cb, .fromPtr(&monitors)).toBool());
    try testing.expectEqual(@as(u32, @intCast(USER.GetSystemMetrics(.c_monitors))), monitors);

    var dm: STRUCTS.DEVMODEW = .{};
    try testing.expect(USER.EnumDisplaySettingsW(@ptrCast(&mi.device), USER.ENUM_CURRENT_SETTINGS, &dm).toBool());
    try testing.expect(dm.pels_width > 0 and dm.bits_per_pel > 0 and dm.display_frequency > 0);

    var dd: STRUCTS.DISPLAY_DEVICEW = .{};
    try testing.expect(USER.EnumDisplayDevicesW(null, 0, &dd, 0).toBool());
    try testing.expect(dd.device_string[0] != 0);

    var num_paths: u32 = 0;
    var num_modes: u32 = 0;
    try testing.expectEqual(0, USER.GetDisplayConfigBufferSizes(0x2, &num_paths, &num_modes)); // QDC_ONLY_ACTIVE_PATHS
    try testing.expect(num_paths >= 1);

    const ctx = USER.GetThreadDpiAwarenessContext();
    try testing.expect(USER.IsValidDpiAwarenessContext(ctx).toBool());
    try testing.expect(USER.GetAwarenessFromDpiAwarenessContext(ctx) != .invalid);
    try testing.expect(USER.GetDpiForSystem() >= USER.USER_DEFAULT_SCREEN_DPI / 2);

    var last: STRUCTS.LASTINPUTINFO = .{};
    try testing.expect(USER.GetLastInputInfo(&last).toBool());
    var keys: [256]u8 = undefined;
    try testing.expect(USER.GetKeyboardState(&keys).toBool());
    var klid: [9]u16 = undefined;
    try testing.expect(USER.GetKeyboardLayoutNameW(&klid).toBool());
    try testing.expectEqual(0, klid[8]);
    try testing.expect(USER.GetKeyboardLayout(0) != .null);

    var count: u32 = 0;
    try testing.expect(USER.GetRawInputDeviceList(null, &count, @sizeOf(STRUCTS.RAWINPUTDEVICELIST)) == 0);
}

test "live: user32 strings and wsprintf" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const L = std.unicode.utf8ToUtf16LeStringLiteral;
    var buf = L("hello Zig").*;
    try testing.expectEqual(buf.len, USER.CharUpperBuffW(&buf, buf.len));
    try testing.expectEqualSlices(u16, L("HELLO ZIG"), &buf);
    try testing.expect(USER.IsCharAlphaW('z').toBool());
    try testing.expect(!USER.IsCharAlphaW('7').toBool());
    try testing.expect(USER.IsCharUpperW('Q').toBool());

    var out: [64]u16 = undefined;
    const n = USER.wsprintfW(&out, L("%d-%s-%04X"), @as(c_int, -42), L("ok").ptr, @as(c_uint, 0xBEEF));
    try testing.expectEqualSlices(u16, L("-42-ok-BEEF"), out[0..@intCast(n)]);
}

test "live: USER.load resolves optional exports at runtime" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    // Same function through the static import and through `load`.
    const get_dpi = USER.load("GetDpiForSystem") orelse return error.TestUnexpectedResult;
    try testing.expectEqual(USER.GetDpiForSystem(), get_dpi());
    // Cached: the second call returns the same pointer.
    try testing.expectEqual(get_dpi, USER.load("GetDpiForSystem").?);
    // A missing export is just null (uncached escape hatch).
    try testing.expectEqual(null, USER.loadOptional(fn () callconv(.winapi) void, "ZigWindowsNoSuchExport"));

    // Exports that may or may not exist on the running Windows; both outcomes are fine.
    if (USER.load("IsMousePointerEnabled")) |f| _ = f();
    // Resolve only. GetDisplayAutoRotationPreferencesByProcessId is undocumented and its
    // header signature crashes on 32-bit, and EnableMouseInPointerForThread changes this
    // thread's input routing.
    _ = USER.load("GetDisplayAutoRotationPreferencesByProcessId");
    _ = USER.load("EnableMouseInPointerForThread");
}

test "live: every USER binding is loadable at runtime" {
    @setEvalBranchQuota(100_000);
    // Checks that `load` accepts every binding's name and signature, and that each export the
    // import library knows about is really present in this machine's user32.dll.
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    var missing: usize = 0;
    var checked: usize = 0;
    inline for (comptime std.meta.declarations(USER)) |name| {
        const info = @typeInfo(@TypeOf(@field(USER, name)));
        if (info == .@"fn" and !info.@"fn".is_generic) {
            switch (info.@"fn".attrs.@"callconv") {
                .auto, .@"inline" => {},
                else => {
                    checked += 1;
                    if (USER.load(name) == null) {
                        std.debug.print("user32 on this machine lacks {s}\n", .{name});
                        missing += 1;
                    }
                },
            }
        }
    }
    try testing.expect(checked > 600);
    try testing.expectEqual(0, missing);
}
