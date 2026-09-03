const t = @import("windows_types.zig");
const WndProc = @import("windows_fns.zig").WndProc;

pub const GUID = extern struct {
    data1: u32,
    data2: u16,
    data3: u16,
    data4: [8]u8,
};
pub const REFGUID = *const GUID;
pub const REFIID = *const GUID;

const IMFAttributesVtbl = extern struct {
    _pad0: [2]*const anyopaque, // QueryInterface, AddRef
    Release: *const fn (*IMFAttributes) callconv(.winapi) u32,
    _pad1: [4]*const anyopaque, // GetItem, GetItemType, CompareItem, Compare
    GetUINT32: *const fn (*IMFAttributes, REFGUID, *u32) callconv(.winapi) t.HRESULT,
    GetUINT64: *const fn (*IMFAttributes, REFGUID, *u64) callconv(.winapi) t.HRESULT,
    _pad2: [1]*const anyopaque, // GetDouble
    GetGUID: *const fn (*IMFAttributes, REFGUID, *GUID) callconv(.winapi) t.HRESULT,
    _pad3: [13]*const anyopaque, // GetStringLength .. SetDouble
    SetGUID: *const fn (*IMFAttributes, REFGUID, REFGUID) callconv(.winapi) t.HRESULT,
    _pad4: [8]*const anyopaque, // SetString .. CopyAllItems
};
pub const IMFAttributes = extern struct {
    vtbl: *const IMFAttributesVtbl,
};

const IMFActivateVtbl = extern struct {
    _pad0: [2]*const anyopaque, // QueryInterface, AddRef
    release: *const fn (*IMFActivate) callconv(.winapi) u32,
    _pad1: [10]*const anyopaque, // GetItem .. GetString
    get_allocated_string: *const fn (*IMFActivate, REFGUID, *?[*:0]u16, *u32) callconv(.winapi) t.HRESULT,
    _pad2: [19]*const anyopaque, // GetBlobSize .. CopyAllItems
    activate_object: *const fn (*IMFActivate, REFIID, *?*anyopaque) callconv(.winapi) t.HRESULT,
    _pad3: [2]*const anyopaque, // ShutdownObject, DetachObject
};
pub const IMFActivate = extern struct {
    vtbl: *const IMFActivateVtbl,
};

const IUnknownVtbl = extern struct {
    _pad0: [2]*const anyopaque, // QueryInterface, Addref,
    release: *const fn (*anyopaque) callconv(.winapi) u32,
};
pub const IMFMediaSource = extern struct {
    vtbl: *const IUnknownVtbl,
};

const IMFSourceReaderVtbl = extern struct {
    _pad0: [2]*const anyopaque, // QueryInterface, AddRef
    release: *const fn (*IMFSourceReader) callconv(.winapi) u32,
    _pad1: [3]*const anyopaque, // GetStreamSelection, SetStreamSelection, GetNativeMediaType
    get_current_media_type: *const fn (
        *IMFSourceReader,
        u32,
        *?*IMFAttributes,
    ) callconv(.winapi) t.HRESULT,
    _pad2: [2]*const anyopaque, // SetCurrentMediaType, SetCurrentPosition
    read_sample: *const fn (
        *IMFSourceReader,
        u32,
        u32,
        ?*u32,
        ?*u32,
        ?*i64,
        *?*IMFSample,
    ) callconv(.winapi) t.HRESULT,
    _pad3: [3]*const anyopaque, // Flush, GetServiceForStream, GetPresentationAttribute
};
pub const IMFSourceReader = extern struct {
    vtbl: *const IMFSourceReaderVtbl,
};

const IMFMediaBufferVtbl = extern struct {
    _pad0: [2]*const anyopaque, // QueryInterface, AddRef
    release: *const fn (*IMFMediaBuffer) callconv(.winapi) u32,
    lock: *const fn (*IMFMediaBuffer, *?[*]u8, ?*u32, ?*u32) callconv(.winapi) t.HRESULT,
    unlock: *const fn (*IMFMediaBuffer) callconv(.winapi) t.HRESULT,
    _pad1: [3]*const anyopaque, // GetCurrentLength, SetCurrentLength, GetMaxLength
};
pub const IMFMediaBuffer = extern struct {
    vtbl: *const IMFMediaBufferVtbl,
};

const IMFSampleVtbl = extern struct {
    _pad0: [2]*const anyopaque, // QueryInterface, AddRef
    release: *const fn (*IMFSample) callconv(.winapi) u32,
    _pad1: [38]*const anyopaque, // GetItem .. GetBufferByIndex
    convert_to_contiguous_buffer: *const fn (*IMFSample, *?*IMFMediaBuffer) callconv(.winapi) t.HRESULT,
    _pad2: [5]*const anyopaque, // AddBuffer .. CopyToBuffer
};
pub const IMFSample = extern struct {
    vtbl: *const IMFSampleVtbl,
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

pub const WNDCLASSA = extern struct {
    style: u32 = 0,
    wnd_proc: ?WndProc,
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
    wnd_proc: ?WndProc,
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
    wnd_proc: ?WndProc,
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
    wnd_proc: ?WndProc,
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
