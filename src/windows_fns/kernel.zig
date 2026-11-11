//! kernel32.dll
const t = @import("../windows_types.zig");
const s = @import("../windows_structs.zig");

pub extern "kernel32" fn GetModuleHandleA(module_name: ?[*:0]const u8) callconv(.winapi) t.HINSTANCE;
pub extern "kernel32" fn GetModuleHandleW(module_name: ?[*:0]const u16) callconv(.winapi) t.HINSTANCE;

pub extern "kernel32" fn LoadLibraryA(file_name: [*:0]const u8) callconv(.winapi) t.HMODULE;
pub extern "kernel32" fn LoadLibraryW(file_name: [*:0]const u16) callconv(.winapi) t.HMODULE;
pub extern "kernel32" fn FreeLibrary(module: t.HMODULE) callconv(.winapi) t.BOOL;
/// Returns null if `module` has no export named `proc_name` (an ordinal also works via `@ptrFromInt`).
pub extern "kernel32" fn GetProcAddress(module: t.HMODULE, proc_name: [*:0]const u8) callconv(.winapi) ?t.FARPROC;

pub extern "kernel32" fn GetLastError() callconv(.winapi) t.DWORD;
pub extern "kernel32" fn SetLastError(code: t.DWORD) callconv(.winapi) void;

pub extern "kernel32" fn CloseHandle(handle: t.HANDLE) callconv(.winapi) t.BOOL;

pub const INFINITE: t.DWORD = 0xFFFFFFFF;
pub const WAIT_OBJECT_0: t.DWORD = 0x00000000;
pub const WAIT_TIMEOUT: t.DWORD = 0x00000102;
pub const WAIT_FAILED: t.DWORD = 0xFFFFFFFF;

pub extern "kernel32" fn CreateEventW(
    attributes: ?*const s.SECURITY_ATTRIBUTES,
    manual_reset: t.BOOL,
    initial_state: t.BOOL,
    name: ?[*:0]const u16,
) callconv(.winapi) t.HANDLE;
pub extern "kernel32" fn SetEvent(event: t.HANDLE) callconv(.winapi) t.BOOL;
pub extern "kernel32" fn ResetEvent(event: t.HANDLE) callconv(.winapi) t.BOOL;
pub extern "kernel32" fn WaitForSingleObject(handle: t.HANDLE, timeout_ms: t.DWORD) callconv(.winapi) t.DWORD;

pub extern "kernel32" fn Sleep(ms: t.DWORD) callconv(.winapi) void;
pub extern "kernel32" fn GetTickCount64() callconv(.winapi) u64;
pub extern "kernel32" fn QueryPerformanceCounter(count: *s.LARGE_INTEGER) callconv(.winapi) t.BOOL;
pub extern "kernel32" fn QueryPerformanceFrequency(freq: *s.LARGE_INTEGER) callconv(.winapi) t.BOOL;

pub extern "kernel32" fn GetCurrentThreadId() callconv(.winapi) t.DWORD;
pub extern "kernel32" fn GetCurrentProcessId() callconv(.winapi) t.DWORD;
