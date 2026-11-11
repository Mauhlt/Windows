//! mfreadwrite.dll (Source Reader)
const t = @import("../windows_types.zig");
const com = @import("../windows_com.zig");

// Stream index aliases for IMFSourceReader methods.
pub const MF_SOURCE_READER_INVALID_STREAM_INDEX: u32 = 0xFFFFFFFF;
pub const MF_SOURCE_READER_ALL_STREAMS: u32 = 0xFFFFFFFE;
pub const MF_SOURCE_READER_ANY_STREAM: u32 = 0xFFFFFFFE;
pub const MF_SOURCE_READER_FIRST_AUDIO_STREAM: u32 = 0xFFFFFFFD;
pub const MF_SOURCE_READER_FIRST_VIDEO_STREAM: u32 = 0xFFFFFFFC;
pub const MF_SOURCE_READER_MEDIASOURCE: u32 = 0xFFFFFFFF;

/// ReadSample control flags.
pub const MF_SOURCE_READER_CONTROLF_DRAIN: u32 = 0x1;

/// `stream_flags` returned by IMFSourceReader.readSample.
pub const SourceReaderFlags = packed struct(u32) {
    @"error": bool = false, // 0x1
    end_of_stream: bool = false, // 0x2
    new_stream: bool = false, // 0x4
    _r3: u1 = 0,
    native_media_type_changed: bool = false, // 0x10
    current_media_type_changed: bool = false, // 0x20
    _r6: u2 = 0,
    stream_tick: bool = false, // 0x100
    all_effects_removed: bool = false, // 0x200
    _r10: u22 = 0,
};

pub extern "mfreadwrite" fn MFCreateSourceReaderFromMediaSource(
    source: *com.IMFMediaSource,
    attrs: ?*com.IMFAttributes,
    reader: *?*com.IMFSourceReader,
) callconv(.winapi) t.HRESULT;

pub extern "mfreadwrite" fn MFCreateSourceReaderFromURL(
    url: t.LPCWSTR,
    attrs: ?*com.IMFAttributes,
    reader: *?*com.IMFSourceReader,
) callconv(.winapi) t.HRESULT;
