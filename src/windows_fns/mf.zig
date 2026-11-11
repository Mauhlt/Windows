//! mf.dll (Media Foundation devices). GUID keys live in `GUIDS`.
const t = @import("../windows_types.zig");
const com = @import("../windows_com.zig");

/// `sources` is a CoTaskMemAlloc'd array: release each entry, then `CoTaskMemFree` the array.
pub extern "mf" fn MFEnumDeviceSources(
    attrs: *com.IMFAttributes,
    sources: *?[*]*com.IMFActivate,
    count: *u32,
) callconv(.winapi) t.HRESULT;

/// Create a device source directly from attributes (e.g. source type + symbolic link).
pub extern "mf" fn MFCreateDeviceSource(
    attrs: *com.IMFAttributes,
    source: *?*com.IMFMediaSource,
) callconv(.winapi) t.HRESULT;
