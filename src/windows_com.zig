//! COM interfaces (IUnknown + Media Foundation).
//!
//! Every vtable lists one field per COM method, in header order, so the layout
//! can be checked by size (see tests in root.zig). Methods you rarely need are
//! typed as `Unused`; the rest have typed signatures plus camelCase wrappers:
//!
//!     var reader: ?*IMFSourceReader = null;
//!     ...
//!     defer _ = reader.?.release();
//!     try reader.?.readSample(...).check();
const t = @import("windows_types.zig");
const s = @import("windows_structs.zig");
const guids = @import("windows_guids.zig");

const HRESULT = t.HRESULT;
const BOOL = t.BOOL;
const GUID = s.GUID;
const REFGUID = s.REFGUID;
const REFIID = s.REFIID;

/// Placeholder for vtable slots without a typed binding.
pub const Unused = *const anyopaque;

/// queryInterface / addRef / release for any interface `Self` deriving from IUnknown.
fn UnknownMethods(comptime Self: type) type {
    return struct {
        inline fn unk(self: *Self) *IUnknown {
            return @ptrCast(self);
        }
        pub fn queryInterface(self: *Self, iid: REFIID, out: *?*anyopaque) HRESULT {
            return unk(self).vtbl.query_interface(unk(self), iid, out);
        }
        pub fn addRef(self: *Self) u32 {
            return unk(self).vtbl.add_ref(unk(self));
        }
        pub fn release(self: *Self) u32 {
            return unk(self).vtbl.release(unk(self));
        }
        /// Typed QueryInterface: `const src = try unk.queryAs(IMFMediaSource);`
        pub fn queryAs(self: *Self, comptime T: type) error{HResultFailed}!*T {
            var out: ?*anyopaque = null;
            try self.queryInterface(&T.iid, &out).check();
            return @ptrCast(@alignCast(out.?));
        }
    };
}

// ---------------------------------------------------------------------------
// IUnknown
// ---------------------------------------------------------------------------
pub const IUnknown = extern struct {
    vtbl: *const Vtbl,

    pub const iid = guids.IID_IUnknown;
    pub const Vtbl = extern struct {
        query_interface: *const fn (*IUnknown, REFIID, *?*anyopaque) callconv(.winapi) HRESULT,
        add_ref: *const fn (*IUnknown) callconv(.winapi) u32,
        release: *const fn (*IUnknown) callconv(.winapi) u32,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;
    pub const queryAs = U.queryAs;
};

// ---------------------------------------------------------------------------
// IMFAttributes
// ---------------------------------------------------------------------------
pub const IMFAttributes = extern struct {
    vtbl: *const Vtbl,

    pub const iid = guids.IID_IMFAttributes;
    const Self = IMFAttributes;
    pub const Vtbl = extern struct {
        unknown: IUnknown.Vtbl,
        get_item: Unused,
        get_item_type: *const fn (*Self, REFGUID, *u32) callconv(.winapi) HRESULT,
        compare_item: Unused,
        compare: Unused,
        get_uint32: *const fn (*Self, REFGUID, *u32) callconv(.winapi) HRESULT,
        get_uint64: *const fn (*Self, REFGUID, *u64) callconv(.winapi) HRESULT,
        get_double: *const fn (*Self, REFGUID, *f64) callconv(.winapi) HRESULT,
        get_guid: *const fn (*Self, REFGUID, *GUID) callconv(.winapi) HRESULT,
        get_string_length: *const fn (*Self, REFGUID, *u32) callconv(.winapi) HRESULT,
        get_string: *const fn (*Self, REFGUID, [*]u16, u32, ?*u32) callconv(.winapi) HRESULT,
        get_allocated_string: *const fn (*Self, REFGUID, *?[*:0]u16, *u32) callconv(.winapi) HRESULT,
        get_blob_size: *const fn (*Self, REFGUID, *u32) callconv(.winapi) HRESULT,
        get_blob: *const fn (*Self, REFGUID, [*]u8, u32, ?*u32) callconv(.winapi) HRESULT,
        get_allocated_blob: *const fn (*Self, REFGUID, *?[*]u8, *u32) callconv(.winapi) HRESULT,
        get_unknown: *const fn (*Self, REFGUID, REFIID, *?*anyopaque) callconv(.winapi) HRESULT,
        set_item: Unused,
        delete_item: *const fn (*Self, REFGUID) callconv(.winapi) HRESULT,
        delete_all_items: *const fn (*Self) callconv(.winapi) HRESULT,
        set_uint32: *const fn (*Self, REFGUID, u32) callconv(.winapi) HRESULT,
        set_uint64: *const fn (*Self, REFGUID, u64) callconv(.winapi) HRESULT,
        set_double: *const fn (*Self, REFGUID, f64) callconv(.winapi) HRESULT,
        set_guid: *const fn (*Self, REFGUID, REFGUID) callconv(.winapi) HRESULT,
        set_string: *const fn (*Self, REFGUID, t.LPCWSTR) callconv(.winapi) HRESULT,
        set_blob: *const fn (*Self, REFGUID, [*]const u8, u32) callconv(.winapi) HRESULT,
        set_unknown: *const fn (*Self, REFGUID, ?*IUnknown) callconv(.winapi) HRESULT,
        lock_store: *const fn (*Self) callconv(.winapi) HRESULT,
        unlock_store: *const fn (*Self) callconv(.winapi) HRESULT,
        get_count: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
        get_item_by_index: Unused,
        copy_all_items: *const fn (*Self, *Self) callconv(.winapi) HRESULT,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;
    pub const queryAs = U.queryAs;

    pub fn getUINT32(self: *Self, key: REFGUID, out: *u32) HRESULT {
        return self.vtbl.get_uint32(self, key, out);
    }
    pub fn getUINT64(self: *Self, key: REFGUID, out: *u64) HRESULT {
        return self.vtbl.get_uint64(self, key, out);
    }
    pub fn getDouble(self: *Self, key: REFGUID, out: *f64) HRESULT {
        return self.vtbl.get_double(self, key, out);
    }
    pub fn getGUID(self: *Self, key: REFGUID, out: *GUID) HRESULT {
        return self.vtbl.get_guid(self, key, out);
    }
    pub fn getStringLength(self: *Self, key: REFGUID, len: *u32) HRESULT {
        return self.vtbl.get_string_length(self, key, len);
    }
    /// Writes a NUL-terminated string into `buf`; `len` (optional) receives chars excluding NUL.
    pub fn getString(self: *Self, key: REFGUID, buf: []u16, len: ?*u32) HRESULT {
        return self.vtbl.get_string(self, key, buf.ptr, @intCast(buf.len), len);
    }
    /// Caller frees `out` with `CoTaskMemFree`.
    pub fn getAllocatedString(self: *Self, key: REFGUID, out: *?[*:0]u16, len: *u32) HRESULT {
        return self.vtbl.get_allocated_string(self, key, out, len);
    }
    pub fn getCount(self: *Self, out: *u32) HRESULT {
        return self.vtbl.get_count(self, out);
    }
    pub fn setUINT32(self: *Self, key: REFGUID, value: u32) HRESULT {
        return self.vtbl.set_uint32(self, key, value);
    }
    pub fn setUINT64(self: *Self, key: REFGUID, value: u64) HRESULT {
        return self.vtbl.set_uint64(self, key, value);
    }
    pub fn setDouble(self: *Self, key: REFGUID, value: f64) HRESULT {
        return self.vtbl.set_double(self, key, value);
    }
    pub fn setGUID(self: *Self, key: REFGUID, value: REFGUID) HRESULT {
        return self.vtbl.set_guid(self, key, value);
    }
    pub fn setString(self: *Self, key: REFGUID, value: t.LPCWSTR) HRESULT {
        return self.vtbl.set_string(self, key, value);
    }
    pub fn deleteItem(self: *Self, key: REFGUID) HRESULT {
        return self.vtbl.delete_item(self, key);
    }
    pub fn deleteAllItems(self: *Self) HRESULT {
        return self.vtbl.delete_all_items(self);
    }
    pub fn copyAllItems(self: *Self, dest: *IMFAttributes) HRESULT {
        return self.vtbl.copy_all_items(self, dest);
    }

    // Equivalents of the inline mfapi.h helpers MFGet/SetAttributeSize / Ratio.
    pub const Pair = struct { hi: u32, lo: u32 };

    /// MFGetAttributeRatio (e.g. MF_MT_FRAME_RATE -> numerator, denominator).
    pub fn getRatio(self: *Self, key: REFGUID) error{HResultFailed}!Pair {
        var v: u64 = 0;
        try self.getUINT64(key, &v).check();
        return .{ .hi = @truncate(v >> 32), .lo = @truncate(v) };
    }
    pub fn setRatio(self: *Self, key: REFGUID, hi: u32, lo: u32) HRESULT {
        return self.setUINT64(key, @as(u64, hi) << 32 | lo);
    }
    /// MFGetAttributeSize (e.g. MF_MT_FRAME_SIZE).
    pub fn getSize(self: *Self, key: REFGUID) error{HResultFailed}!struct { width: u32, height: u32 } {
        const p = try self.getRatio(key);
        return .{ .width = p.hi, .height = p.lo };
    }
    pub fn setSize(self: *Self, key: REFGUID, width: u32, height: u32) HRESULT {
        return self.setRatio(key, width, height);
    }
};

/// Upcast any IMFAttributes-derived interface.
fn AttributesUpcast(comptime Self: type) type {
    return struct {
        pub fn attributes(self: *Self) *IMFAttributes {
            return @ptrCast(self);
        }
    };
}

// ---------------------------------------------------------------------------
// IMFMediaType : IMFAttributes
// ---------------------------------------------------------------------------
pub const IMFMediaType = extern struct {
    vtbl: *const Vtbl,

    pub const iid = guids.IID_IMFMediaType;
    const Self = IMFMediaType;
    pub const Vtbl = extern struct {
        base: IMFAttributes.Vtbl,
        get_major_type: *const fn (*Self, *GUID) callconv(.winapi) HRESULT,
        is_compressed_format: *const fn (*Self, *BOOL) callconv(.winapi) HRESULT,
        is_equal: Unused,
        get_representation: Unused,
        free_representation: Unused,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;
    pub const queryAs = U.queryAs;
    pub const attributes = AttributesUpcast(@This()).attributes;

    pub fn getMajorType(self: *Self, out: *GUID) HRESULT {
        return self.vtbl.get_major_type(self, out);
    }
    pub fn isCompressedFormat(self: *Self, out: *BOOL) HRESULT {
        return self.vtbl.is_compressed_format(self, out);
    }
};

// ---------------------------------------------------------------------------
// IMFActivate : IMFAttributes
// ---------------------------------------------------------------------------
pub const IMFActivate = extern struct {
    vtbl: *const Vtbl,

    const Self = IMFActivate;
    pub const Vtbl = extern struct {
        base: IMFAttributes.Vtbl,
        activate_object: *const fn (*Self, REFIID, *?*anyopaque) callconv(.winapi) HRESULT,
        shutdown_object: *const fn (*Self) callconv(.winapi) HRESULT,
        detach_object: *const fn (*Self) callconv(.winapi) HRESULT,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;
    pub const attributes = AttributesUpcast(@This()).attributes;

    pub fn activateObject(self: *Self, iid: REFIID, out: *?*anyopaque) HRESULT {
        return self.vtbl.activate_object(self, iid, out);
    }
    /// Typed ActivateObject: `const source = try activate.activateAs(IMFMediaSource);`
    pub fn activateAs(self: *Self, comptime T: type) error{HResultFailed}!*T {
        var out: ?*anyopaque = null;
        try self.activateObject(&T.iid, &out).check();
        return @ptrCast(@alignCast(out.?));
    }
    pub fn shutdownObject(self: *Self) HRESULT {
        return self.vtbl.shutdown_object(self);
    }
    pub fn detachObject(self: *Self) HRESULT {
        return self.vtbl.detach_object(self);
    }
};

// ---------------------------------------------------------------------------
// IMFMediaBuffer
// ---------------------------------------------------------------------------
pub const IMFMediaBuffer = extern struct {
    vtbl: *const Vtbl,

    const Self = IMFMediaBuffer;
    pub const Vtbl = extern struct {
        unknown: IUnknown.Vtbl,
        lock: *const fn (*Self, *?[*]u8, ?*u32, ?*u32) callconv(.winapi) HRESULT,
        unlock: *const fn (*Self) callconv(.winapi) HRESULT,
        get_current_length: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
        set_current_length: *const fn (*Self, u32) callconv(.winapi) HRESULT,
        get_max_length: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;

    pub fn lock(self: *Self, data: *?[*]u8, max_len: ?*u32, cur_len: ?*u32) HRESULT {
        return self.vtbl.lock(self, data, max_len, cur_len);
    }
    /// Locks the buffer and returns its current contents. Call `unlock` when done.
    pub fn lockSlice(self: *Self) error{HResultFailed}![]u8 {
        var ptr: ?[*]u8 = null;
        var len: u32 = 0;
        try self.lock(&ptr, null, &len).check();
        return ptr.?[0..len];
    }
    pub fn unlock(self: *Self) HRESULT {
        return self.vtbl.unlock(self);
    }
    pub fn getCurrentLength(self: *Self, out: *u32) HRESULT {
        return self.vtbl.get_current_length(self, out);
    }
    pub fn setCurrentLength(self: *Self, len: u32) HRESULT {
        return self.vtbl.set_current_length(self, len);
    }
    pub fn getMaxLength(self: *Self, out: *u32) HRESULT {
        return self.vtbl.get_max_length(self, out);
    }
};

// ---------------------------------------------------------------------------
// IMFSample : IMFAttributes
// ---------------------------------------------------------------------------
pub const IMFSample = extern struct {
    vtbl: *const Vtbl,

    const Self = IMFSample;
    pub const Vtbl = extern struct {
        base: IMFAttributes.Vtbl,
        get_sample_flags: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
        set_sample_flags: *const fn (*Self, u32) callconv(.winapi) HRESULT,
        get_sample_time: *const fn (*Self, *i64) callconv(.winapi) HRESULT,
        set_sample_time: *const fn (*Self, i64) callconv(.winapi) HRESULT,
        get_sample_duration: *const fn (*Self, *i64) callconv(.winapi) HRESULT,
        set_sample_duration: *const fn (*Self, i64) callconv(.winapi) HRESULT,
        get_buffer_count: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
        get_buffer_by_index: *const fn (*Self, u32, *?*IMFMediaBuffer) callconv(.winapi) HRESULT,
        convert_to_contiguous_buffer: *const fn (*Self, *?*IMFMediaBuffer) callconv(.winapi) HRESULT,
        add_buffer: *const fn (*Self, *IMFMediaBuffer) callconv(.winapi) HRESULT,
        remove_buffer_by_index: *const fn (*Self, u32) callconv(.winapi) HRESULT,
        remove_all_buffers: *const fn (*Self) callconv(.winapi) HRESULT,
        get_total_length: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
        copy_to_buffer: *const fn (*Self, *IMFMediaBuffer) callconv(.winapi) HRESULT,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;
    pub const attributes = AttributesUpcast(@This()).attributes;

    /// Sample time in 100ns units.
    pub fn getSampleTime(self: *Self, out: *i64) HRESULT {
        return self.vtbl.get_sample_time(self, out);
    }
    pub fn getSampleDuration(self: *Self, out: *i64) HRESULT {
        return self.vtbl.get_sample_duration(self, out);
    }
    pub fn getBufferCount(self: *Self, out: *u32) HRESULT {
        return self.vtbl.get_buffer_count(self, out);
    }
    pub fn getBufferByIndex(self: *Self, index: u32, out: *?*IMFMediaBuffer) HRESULT {
        return self.vtbl.get_buffer_by_index(self, index, out);
    }
    pub fn convertToContiguousBuffer(self: *Self, out: *?*IMFMediaBuffer) HRESULT {
        return self.vtbl.convert_to_contiguous_buffer(self, out);
    }
    pub fn getTotalLength(self: *Self, out: *u32) HRESULT {
        return self.vtbl.get_total_length(self, out);
    }
};

// ---------------------------------------------------------------------------
// IMFMediaSource : IMFMediaEventGenerator
// ---------------------------------------------------------------------------
pub const IMFMediaSource = extern struct {
    vtbl: *const Vtbl,

    pub const iid = guids.IID_IMFMediaSource;
    const Self = IMFMediaSource;
    pub const Vtbl = extern struct {
        unknown: IUnknown.Vtbl,
        // IMFMediaEventGenerator
        get_event: Unused,
        begin_get_event: Unused,
        end_get_event: Unused,
        queue_event: Unused,
        // IMFMediaSource
        get_characteristics: *const fn (*Self, *u32) callconv(.winapi) HRESULT,
        create_presentation_descriptor: Unused,
        start: Unused,
        stop: *const fn (*Self) callconv(.winapi) HRESULT,
        pause: *const fn (*Self) callconv(.winapi) HRESULT,
        shutdown: *const fn (*Self) callconv(.winapi) HRESULT,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;

    pub fn getCharacteristics(self: *Self, out: *u32) HRESULT {
        return self.vtbl.get_characteristics(self, out);
    }
    pub fn stop(self: *Self) HRESULT {
        return self.vtbl.stop(self);
    }
    pub fn pause(self: *Self) HRESULT {
        return self.vtbl.pause(self);
    }
    /// Releases the device (e.g. turns the camera off). Call before `release`.
    pub fn shutdown(self: *Self) HRESULT {
        return self.vtbl.shutdown(self);
    }
};

// ---------------------------------------------------------------------------
// IMFSourceReader
// ---------------------------------------------------------------------------
pub const IMFSourceReader = extern struct {
    vtbl: *const Vtbl,

    pub const iid = guids.IID_IMFSourceReader;
    const Self = IMFSourceReader;
    pub const Vtbl = extern struct {
        unknown: IUnknown.Vtbl,
        get_stream_selection: *const fn (*Self, u32, *BOOL) callconv(.winapi) HRESULT,
        set_stream_selection: *const fn (*Self, u32, BOOL) callconv(.winapi) HRESULT,
        get_native_media_type: *const fn (*Self, u32, u32, *?*IMFMediaType) callconv(.winapi) HRESULT,
        get_current_media_type: *const fn (*Self, u32, *?*IMFMediaType) callconv(.winapi) HRESULT,
        set_current_media_type: *const fn (*Self, u32, ?*u32, *IMFMediaType) callconv(.winapi) HRESULT,
        set_current_position: Unused,
        read_sample: *const fn (*Self, u32, u32, ?*u32, ?*u32, ?*i64, ?*?*IMFSample) callconv(.winapi) HRESULT,
        flush: *const fn (*Self, u32) callconv(.winapi) HRESULT,
        get_service_for_stream: *const fn (*Self, u32, REFGUID, REFIID, *?*anyopaque) callconv(.winapi) HRESULT,
        get_presentation_attribute: Unused,
    };

    const U = UnknownMethods(@This());
    pub const queryInterface = U.queryInterface;
    pub const addRef = U.addRef;
    pub const release = U.release;

    pub fn getStreamSelection(self: *Self, stream: u32, out: *BOOL) HRESULT {
        return self.vtbl.get_stream_selection(self, stream, out);
    }
    pub fn setStreamSelection(self: *Self, stream: u32, selected: bool) HRESULT {
        return self.vtbl.set_stream_selection(self, stream, .from(selected));
    }
    /// Enumerate supported formats: index 0, 1, ... until MF_E_NO_MORE_TYPES.
    pub fn getNativeMediaType(self: *Self, stream: u32, index: u32, out: *?*IMFMediaType) HRESULT {
        return self.vtbl.get_native_media_type(self, stream, index, out);
    }
    pub fn getCurrentMediaType(self: *Self, stream: u32, out: *?*IMFMediaType) HRESULT {
        return self.vtbl.get_current_media_type(self, stream, out);
    }
    pub fn setCurrentMediaType(self: *Self, stream: u32, media_type: *IMFMediaType) HRESULT {
        return self.vtbl.set_current_media_type(self, stream, null, media_type);
    }
    /// Synchronous read. `sample` may come back null (e.g. stream tick / end of stream);
    /// check `stream_flags` against `MFREADWRITE.SourceReaderFlags`.
    pub fn readSample(
        self: *Self,
        stream: u32,
        control_flags: u32,
        actual_stream: ?*u32,
        stream_flags: ?*u32,
        timestamp: ?*i64,
        sample: ?*?*IMFSample,
    ) HRESULT {
        return self.vtbl.read_sample(self, stream, control_flags, actual_stream, stream_flags, timestamp, sample);
    }
    pub fn flush(self: *Self, stream: u32) HRESULT {
        return self.vtbl.flush(self, stream);
    }
};
