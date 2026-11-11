//! GUID constants (attribute keys, media types, interface ids).
//! Values verified against mingw-w64 mfapi.h / mfidl.h / mfreadwrite.h.
const s = @import("windows_structs.zig");
const GUID = s.GUID;

/// Builds an MF media subtype GUID from a FOURCC / D3DFORMAT: {XXXXXXXX-0000-0010-8000-00AA00389B71}.
pub fn mediaTypeGuid(format: u32) GUID {
    return .{
        .data1 = format,
        .data2 = 0x0000,
        .data3 = 0x0010,
        .data4 = .{ 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 },
    };
}
pub fn fourcc(comptime code: *const [4]u8) u32 {
    return @as(u32, code[0]) | @as(u32, code[1]) << 8 | @as(u32, code[2]) << 16 | @as(u32, code[3]) << 24;
}

// --- Interface ids ---------------------------------------------------------
pub const IID_IUnknown = GUID.parse("00000000-0000-0000-c000-000000000046");
pub const IID_IMFAttributes = GUID.parse("2cd2d921-c447-44a7-a13c-4adabfc247e3");
pub const IID_IMFMediaType = GUID.parse("44ae0fa8-ea31-4109-8d2e-4cae4997c555");
pub const IID_IMFMediaSource = GUID.parse("279a808d-aec7-40c8-9c6b-a6b492c78a66");
pub const IID_IMFSourceReader = GUID.parse("70ae66f2-c809-4e4f-8915-bdcb406b7993");

// --- Device source attributes ---------------------------------------------
pub const MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME = GUID.parse("60d0e559-52f8-4fa2-bbce-acdb34a8ec01");
pub const MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE = GUID.parse("c60ac5fe-252a-478f-a0ef-bc8fa5f7cad3");
pub const MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID = GUID.parse("8ac3587a-4ae7-42d8-99e0-0a6013eef90f");
pub const MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_SYMBOLIC_LINK = GUID.parse("58f0aad8-22bf-4f8a-bb3d-d2c4978c6e2f");
pub const MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID = GUID.parse("14dd9a1c-7cff-41be-b1b9-ba1ac6ecb571");

// --- Media type attributes ------------------------------------------------
pub const MF_MT_MAJOR_TYPE = GUID.parse("48eba18e-f8c9-4687-bf11-0a74c9f96a8f");
pub const MF_MT_SUBTYPE = GUID.parse("f7e34c9a-42e8-4714-b74b-cb29d72c35e5");
/// UINT64: width << 32 | height. Use IMFAttributes.getSize / setSize.
pub const MF_MT_FRAME_SIZE = GUID.parse("1652c33d-d6b2-4012-b834-72030849a37d");
/// UINT64: numerator << 32 | denominator. Use IMFAttributes.getRatio / setRatio.
pub const MF_MT_FRAME_RATE = GUID.parse("c459a2e8-3d2c-4e44-b132-fee5156c7bb0");
/// UINT32 (bit-cast to i32; negative = bottom-up).
pub const MF_MT_DEFAULT_STRIDE = GUID.parse("644b4e48-1e02-4516-b0eb-c01ca9d49ac6");
pub const MF_LOW_LATENCY = GUID.parse("9c27891a-ed7a-40e1-88e8-b22727a024ee");

// --- Source reader attributes ---------------------------------------------
pub const MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS = GUID.parse("a634a91c-822b-41b9-a494-4de4643612b0");
pub const MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING = GUID.parse("fb394f3d-ccf1-42ee-bbb3-f9b845d5681d");
pub const MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING = GUID.parse("0f81da2c-b537-4672-a8b2-a681b17307a3");

// --- Major types ----------------------------------------------------------
pub const MFMediaType_Video = GUID.parse("73646976-0000-0010-8000-00aa00389b71");
pub const MFMediaType_Audio = GUID.parse("73647561-0000-0010-8000-00aa00389b71");

// --- Video subtypes -------------------------------------------------------
pub const MFVideoFormat_RGB24 = mediaTypeGuid(20); // D3DFMT_R8G8B8
pub const MFVideoFormat_ARGB32 = mediaTypeGuid(21); // D3DFMT_A8R8G8B8
pub const MFVideoFormat_RGB32 = mediaTypeGuid(22); // D3DFMT_X8R8G8B8
pub const MFVideoFormat_NV12 = mediaTypeGuid(fourcc("NV12"));
pub const MFVideoFormat_YUY2 = mediaTypeGuid(fourcc("YUY2"));
pub const MFVideoFormat_I420 = mediaTypeGuid(fourcc("I420"));
pub const MFVideoFormat_MJPG = mediaTypeGuid(fourcc("MJPG"));
