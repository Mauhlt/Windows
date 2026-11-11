# Windows

Zig bindings for the Win32 / COM / Media Foundation APIs I use, grouped by file.

| Namespace     | Contents                                                     |
|---------------|--------------------------------------------------------------|
| `TYPES`       | Integers, handles (`HWND`, `HHOOK`, `HKL`, ...), `HRESULT`, `BOOL`, callbacks |
| `ENUMS`       | Messages, `SW`, and flag sets (`WindowStyle`, `ClassStyle`, ...) as `packed struct`s |
| `STRUCTS`     | `GUID`, `RECT`, `MSG`, `WNDCLASSEXW`, `PAINTSTRUCT`, ...     |
| `GUIDS`       | Media Foundation attribute keys, media types, IIDs           |
| `COM`         | `IUnknown`, `IMFAttributes`, `IMFMediaType`, `IMFActivate`, `IMFSourceReader`, ... |
| `KERNEL`      | kernel32.dll                                                 |
| `USER`        | user32.dll: every function in winuser.h (A and W), plus LOWORD/HIWORD-style helpers |
| `OLE`         | ole32.dll (COM runtime)                                      |
| `MF`, `MFPLAT`, `MFREADWRITE` | Media Foundation DLLs                        |

## Install

```sh
zig fetch --save git+https://github.com/Mauhlt/Windows.git
```

```zig
const windows = b.dependency("Windows", .{});
exe.root_module.addImport("Windows", windows.module("Windows"));
```

## Example: window

```zig
const W = @import("Windows");
const L = std.unicode.utf8ToUtf16LeStringLiteral;

const instance = W.KERNEL.GetModuleHandleW(null);
const wc: W.STRUCTS.WNDCLASSEXW = .{
    .style = .redraw,
    .wnd_proc = wndProc,
    .instance = instance,
    .cursor = W.USER.LoadCursorW(.null, W.ENUMS.SystemCursor.arrow.nameW()),
    .brush = W.USER.GetSysColorBrush(.window),
    .class_name = L("MyClass"),
};
_ = W.USER.RegisterClassExW(&wc);
const hwnd = W.USER.CreateWindowExW(.{}, L("MyClass"), L("Title"), .overlapped_window,
    W.USER.CW_USEDEFAULT, W.USER.CW_USEDEFAULT, 800, 600, .null, .null, instance, null);
W.USER.setUserData(hwnd, app); // read back in wndProc with W.USER.getUserData(App, hwnd)
```

## Running on different Windows versions

Every `USER` function can be called two ways:

```zig
// Static import: fastest, but a program that calls it won't start on a
// Windows whose user32.dll lacks the export.
_ = W.USER.SetProcessDpiAwarenessContext(.per_monitor_aware_v2);

// Optional: resolved at runtime (and cached), null if this Windows lacks it.
// The name is checked at compile time; the signature comes from the binding.
if (W.USER.load("SetProcessDpiAwarenessContext")) |f| {
    _ = f(.per_monitor_aware_v2);
} else {
    _ = W.USER.SetProcessDPIAware(); // older fallback
}
```

Only the functions a program actually calls are imported, so call the APIs that
every supported Windows has directly, and use `load` for anything newer than your
minimum version. A few winuser.h functions (`EnableMouseInPointerForThread`,
`IsMousePointerEnabled`, `GetDisplayAutoRotationPreferencesByProcessId`) are not in
every user32 build and are only reachable through `load`.

## Example: webcam (Media Foundation)

```zig
try W.OLE.CoInitializeEx(null, .multithreaded).check();
defer W.OLE.CoUninitialize();
try W.MFPLAT.MFStartup(W.MFPLAT.MF_VERSION, W.MFPLAT.MFSTARTUP_FULL).check();
defer _ = W.MFPLAT.MFShutdown();

var attrs: ?*W.COM.IMFAttributes = null;
try W.MFPLAT.MFCreateAttributes(&attrs, 1).check();
defer _ = attrs.?.release();
try attrs.?.setGUID(&W.GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE,
    &W.GUIDS.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID).check();

var devices: ?[*]*W.COM.IMFActivate = null;
var count: u32 = 0;
try W.MF.MFEnumDeviceSources(attrs.?, &devices, &count).check();
// devices is null when count == 0; release each entry, then CoTaskMemFree(devices)

const source = try devices.?[0].activateAs(W.COM.IMFMediaSource);
defer { _ = source.shutdown(); _ = source.release(); }

var reader: ?*W.COM.IMFSourceReader = null;
try W.MFREADWRITE.MFCreateSourceReaderFromMediaSource(source, null, &reader).check();

const stream = W.MFREADWRITE.MF_SOURCE_READER_FIRST_VIDEO_STREAM;
var flags: u32 = 0;
var sample: ?*W.COM.IMFSample = null;
try reader.?.readSample(stream, 0, null, &flags, null, &sample).check();
if (sample) |smp| {
    var buf: ?*W.COM.IMFMediaBuffer = null;
    try smp.convertToContiguousBuffer(&buf).check();
    const bytes = try buf.?.lockSlice();
    defer _ = buf.?.unlock();
    _ = bytes;
}
```

## Tests

`zig build test` checks struct sizes, COM vtable slot counts, and flag bit values
against the Windows SDK, links every user32 binding, and does live round-trips through
user32 (windows, messages, menus, monitors, strings) and Media Foundation.
