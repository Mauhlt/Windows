// Imports
const WINDOW_ENUMS = @import("windows_enums.zig");
const WINDOW_TYPES = @import("windows_types.zig");
const USER_FNS = @import("./window_fns/user.zig");
const OLE_FNS = @import("./windows_fns/ole.zig");
const WINDOW_STRUCTS = @import("windows_structs.zig");
// Windows Enums + EnumSets
pub const Color = WINDOW_ENUMS.Color;
pub const ClassStyle = WINDOW_ENUMS.ClassStyle;
pub const DpiAwarenessContext = WINDOW_ENUMS.DpiAwarenessContext;
pub const Messages = WINDOW_ENUMS.Messages;
pub const SW = WINDOW_ENUMS.SW;
pub const RemoveMessage = WINDOW_ENUMS.RemoveMessage;
pub const WindowStyle = WINDOW_ENUMS.WindowStyle;
// Types
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
pub const CreateWindowA = USER_FNS.CreateWindowA;
pub const CreateWindowW = USER_FNS.CreateWindowW;
pub const CreateWindowExA = USER_FNS.CreateWindowExA;
pub const CreateWindowExW = USER_FNS.CreateWindowExW;
pub const DefWindowProcA = USER_FNS.DefWindowProcA;
pub const DefWindowProcW = USER_FNS.DefWindowProcW;
pub const DestroyWindow = USER_FNS.DestroyWindow;
pub const DispatchMessageA = USER_FNS.DispatchMessageA;
pub const DispatchMessageW = USER_FNS.DispatchMessageW;
pub const GetClientRect = USER_FNS.GetClientRect;
pub const GetDpiForWindow = USER_FNS.GetDpiForWindow;
pub const GetMessageA = USER_FNS.GetMessageA;
pub const GetMessageW = USER_FNS.GetMessageW;
pub const GetModuleHandleA = USER_FNS.GetModuleHandleA;
pub const GetModuleHandleW = USER_FNS.GetModuleHandleW;
pub const GetSysColorBrush = USER_FNS.GetSysColorBrush;
pub const KillTimer = USER_FNS.KillTimer;
pub const LoadCursorA = USER_FNS.LoadCursorA;
pub const LoadCursorW = USER_FNS.LoadCursorW;
pub const LoadIconA = USER_FNS.LoadIconA;
pub const LoadIconW = USER_FNS.LoadIconW;
pub const PeekMessageA = USER_FNS.PeekMessageA;
pub const PeekMessageW = USER_FNS.PeekMessageW;
pub const PostQuitMessage = USER_FNS.PostQuitMessage;
pub const SetProcessDpiAwarenessContext = USER_FNS.SetProcessDpiAwarenessContext;
pub const SetTimer = USER_FNS.SetTimer;
pub const ShowWindow = USER_FNS.ShowWindow;
pub const RegisterClassA = USER_FNS.RegisterClassA;
pub const RegisterClassW = USER_FNS.RegisterClassW;
pub const RegisterClassExA = USER_FNS.RegisterClassExA;
pub const RegisterClassExW = USER_FNS.RegisterClassExW;
pub const TranslateMessage = USER_FNS.TranslateMessage;
pub const UpdateWindow = USER_FNS.UpdateWindow;
pub const UnregisterClassA = USER_FNS.UnregisterClassA;
pub const UnregisterClassW = USER_FNS.UnregisterClassW;
pub const 
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
