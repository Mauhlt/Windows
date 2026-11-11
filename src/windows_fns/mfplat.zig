//! mfplat.dll (Media Foundation platform)
const t = @import("../windows_types.zig");
const com = @import("../windows_com.zig");

pub const MF_SDK_VERSION: u32 = 0x0002;
pub const MF_API_VERSION: u32 = 0x0070;
pub const MF_VERSION: u32 = MF_SDK_VERSION << 16 | MF_API_VERSION;

pub const MFSTARTUP_FULL: u32 = 0;
pub const MFSTARTUP_NOSOCKET: u32 = 1;
pub const MFSTARTUP_LITE: u32 = MFSTARTUP_NOSOCKET;

/// Common MF_E_* failures.
pub const MF_E_NO_MORE_TYPES: t.HRESULT = @fromBackingInt(@intCast(@as(i32, @bitCast(@as(u32, 0xC00D36B9)))));
pub const MF_E_INVALIDMEDIATYPE: t.HRESULT = @fromBackingInt(@intCast(@as(i32, @bitCast(@as(u32, 0xC00D36B4)))));
pub const MF_E_ATTRIBUTENOTFOUND: t.HRESULT = @fromBackingInt(@intCast(@as(i32, @bitCast(@as(u32, 0xC00D36E6)))));

/// Pass `MF_VERSION` and `MFSTARTUP_FULL`.
pub extern "mfplat" fn MFStartup(version: u32, flags: u32) callconv(.winapi) t.HRESULT;
pub extern "mfplat" fn MFShutdown() callconv(.winapi) t.HRESULT;

pub extern "mfplat" fn MFCreateAttributes(attrs: *?*com.IMFAttributes, initial_size: u32) callconv(.winapi) t.HRESULT;
pub extern "mfplat" fn MFCreateMediaType(media_type: *?*com.IMFMediaType) callconv(.winapi) t.HRESULT;
pub extern "mfplat" fn MFCreateSample(sample: *?*com.IMFSample) callconv(.winapi) t.HRESULT;
pub extern "mfplat" fn MFCreateMemoryBuffer(max_length: u32, buffer: *?*com.IMFMediaBuffer) callconv(.winapi) t.HRESULT;
