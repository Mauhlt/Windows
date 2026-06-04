// Imports
const WINDOW_ENUMS = @import("windows_enums.zig");
const WINDOW_TYPES = @import("windows_types.zig");
const WINDOW_FNS = @import("windows_fns.zig");
const WINDOW_STRUCTS = @import("windows_structs.zig");
// Windows Enums + EnumSets
pub const ClassStyle = WINDOW_ENUMS.ClassStyle;
pub const Messages = WINDOW_ENUMS.Messages;
pub const SW = WINDOW_ENUMS.SW;
pub const RemoveMessage = WINDOW_ENUMS.RemoveMessage;
pub const WindowStyle = WINDOW_ENUMS.WindowStyle;
pub const TILED_WINDOW = WINDOW_ENUMS.TILED_WINDOW;
// Enum Types
pub const ATOM = WINDOW_TYPES.ATOM;
pub const BOOL = WINDOW_TYPES.BOOL;
pub const DWORD = WINDOW_TYPES.DWORD;
pub const HBRUSH = WINDOW_TYPES.HBRUSH;
pub const HCURSOR = WINDOW_TYPES.HCURSOR;
pub const HICON = WINDOW_TYPES.HICON;
pub const HINSTANCE = WINDOW_TYPES.HINSTANCE;
pub const HMENU = WINDOW_TYPES.HMENU;
pub const HWND = WINDOW_TYPES.HWND;
pub const LRESULT = WINDOW_TYPES.LRESULT;
pub const LPARAM = WINDOW_TYPES.LPARAM;
pub const WPARAM = WINDOW_TYPES.WPARAM;
// Fns
pub const CreateWindowA = WINDOW_FNS.CreateWindowA;
pub const CreateWindowW = WINDOW_FNS.CreateWindowW;
pub const CreateWindowExA = WINDOW_FNS.CreateWindowExA;
pub const CreateWindowExW = WINDOW_FNS.CreateWindowExW;
pub const DefWindowProcA = WINDOW_FNS.DefWindowProcA;
pub const DefWindowProcW = WINDOW_FNS.DefWindowProcW;
pub const DestroyWindow = WINDOW_FNS.DestroyWindow;
pub const DispatchMessageA = WINDOW_FNS.DispatchMessageA;
pub const DispatchMessageW = WINDOW_FNS.DispatchMessageW;
pub const GetClientRect = WINDOW_FNS.GetClientRect;
pub const GetMessageA = WINDOW_FNS.GetMessageA;
pub const GetMessageW = WINDOW_FNS.GetMessageW;
pub const GetModuleHandleA = WINDOW_FNS.GetModuleHandleA;
pub const GetModuleHandleW = WINDOW_FNS.GetModuleHandleW;
pub const GetSysColorBrush = WINDOW_FNS.GetSysColorBrush;
pub const KillTimer = WINDOW_FNS.KillTimer;
pub const LoadCursorA = WINDOW_FNS.LoadCursorA;
pub const LoadCursorW = WINDOW_FNS.LoadCursorW;
pub const LoadIconA = WINDOW_FNS.LoadIconA;
pub const LoadIconW = WINDOW_FNS.LoadIconW;
pub const PeekMessageA = WINDOW_FNS.PeekMessageA;
pub const PeekMessageW = WINDOW_FNS.PeekMessageW;
pub const PostQuitMessage = WINDOW_FNS.PostQuitMessage;
pub const SetTimer = WINDOW_FNS.SetTimer;
pub const ShowWindow = WINDOW_FNS.ShowWindow;
pub const RegisterClassA = WINDOW_FNS.RegisterClassA;
pub const RegisterClassW = WINDOW_FNS.RegisterClassW;
pub const RegisterClassExA = WINDOW_FNS.RegisterClassExA;
pub const RegisterClassExW = WINDOW_FNS.RegisterClassExW;
pub const TranslateMessage = WINDOW_FNS.TranslateMessage;
pub const Timerproc = WINDOW_FNS.Timerproc;
pub const UpdateWindow = WINDOW_FNS.UpdateWindow;
pub const UnregisterClassA = WINDOW_FNS.UnregisterClassA;
pub const UnregisterClassW = WINDOW_FNS.UnregisterClassW;
// Structs
pub const WNDCLASSA = WINDOW_STRUCTS.WNDCLASSA;
pub const WNDCLASSW = WINDOW_STRUCTS.WNDCLASSW;
pub const WNDCLASSEXA = WINDOW_STRUCTS.WNDCLASSEXA;
pub const WNDCLASSEXW = WINDOW_STRUCTS.WNDCLASSEXW;
pub const MSG = WINDOW_STRUCTS.MSG;
pub const POINT = WINDOW_STRUCTS.POINT;
pub const RECT = WINDOW_STRUCTS.RECT;
// Tests
test {
    _ = @import("windows_enums.zig");
    _ = @import("windows_types.zig");
    _ = @import("windows_fns.zig");
    _ = @import("windows_structs.zig");
}
