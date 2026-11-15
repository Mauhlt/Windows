# Third-party material

All code in this repository is under the MIT licence in [LICENSE](LICENSE). No
third-party source files are vendored or ported.

The declarations (function signatures, structure layouts, enum and flag values, COM
vtable order and GUID values) are written by hand to match the Windows API as
declared in the Windows SDK headers (winuser.h, mfapi.h, mfidl.h, mfreadwrite.h and
others) and documented by Microsoft. GUID values were cross-checked against the
mingw-w64 headers (mfapi.h, mfidl.h, mfreadwrite.h). No header text is copied; only
the interface facts needed to call the system DLLs.

## Run-time libraries (not distributed)

kernel32, user32, ole32, mf, mfplat and mfreadwrite are Windows system DLLs. They
are imported by name and are not shipped with this package.
