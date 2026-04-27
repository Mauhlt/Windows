// Windows Types As Enums:
// Atom, HWND, HINSTANCE, HBRUSH, HCURSOR, HICON, HINSTANCE, HMENU, HWND, LRESULT, LPARAM, WPARAM
pub const ATOM = enum(u16) {
    null = 0,
    _,
};
pub const BOOL = enum(u32) {
    false = 0,
    true = 1,
};
pub const DWORD = enum(u32) {
    _,
};
pub const HBRUSH = enum(isize) {
    null = 0,
    _,
};
pub const HCURSOR = enum(isize) {
    null = 0,
    _,
};
pub const HICON = enum(isize) {
    null = 0,
    _,
};
pub const HINSTANCE = enum(isize) {
    null = 0,
    _,
};
pub const HMENU = enum(isize) {
    null = 0,
    _,
};
pub const HWND = enum(isize) {
    null = 0,
    _,
};
pub const LRESULT = enum(isize) {
    null = 0,
    _,
};
pub const LPARAM = enum(isize) {
    null = 0,
    _,
};
pub const LPVOID = enum(isize) {
    null = 0,
    _,
};
pub const WPARAM = enum(usize) {
    null = 0,
    _,
};
