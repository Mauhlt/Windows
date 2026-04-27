# Windows
- goal = act as interface to windows fns 
- instead of main - have windows.zig
- import this into other zig files

1. Add repo to project:
```zig
zig fetch --save git+https://github.com/Mauhlt/Windows.git
```

2. Add module to build:
```zig
const Windows = b.dependency("Windows", .{});
exe.root_module.addImport("Windows", Windows.module("Windows"));
```
