# Mini Task Manager V2

Windows 控制台系统监控工具，纯 C 语言实现。

**V2 新特性：** 彩色多视图 UI · GPU 监控 · 键盘交互 · 可调节刷新率

## 功能

- **Dashboard 总览** — CPU / 内存 / GPU 使用率一目了然
- **进程列表** — PID、进程名、Working Set Size，按内存降序排序
- **CPU 详情** — 使用率 + 负载分级 + 逻辑处理器数 + 架构信息
- **内存详情** — 总量 / 已用 / 可用明细
- **GPU 详情** — 适配器名称、专用显存、共享内存、核心使用率、VRAM 使用率
- **可调节刷新率** — 按 `+` 加速 / `-` 减速（200ms ~ 5000ms）
- **24-bit 真彩色** — Box-drawing 面板 + 渐变色标题 + 进度条可视化
- **键盘快捷键** — 数字键切换视图，H 帮助，Q 退出

## 目录结构

```
monitor/
├── include/
│   ├── types.h        # 共享数据类型和常量定义
│   ├── cpu.h          # CPU 模块接口声明
│   ├── memory.h       # 内存模块接口声明
│   ├── process.h      # 进程模块接口声明
│   ├── gpu.h          # GPU 模块接口声明
│   └── ui.h           # 控制台 UI 模块接口声明
├── src/
│   ├── main.c         # 主程序入口，协调各模块
│   ├── cpu.c          # CPU 使用率计算实现
│   ├── memory.c       # 内存信息获取实现
│   ├── process.c      # 进程枚举和排序实现
│   ├── gpu.c          # GPU 信息采集实现 (DXGI + NVML + nvidia-smi)
│   └── ui.c           # 控制台彩色 UI 渲染实现
├── Makefile           # MinGW-w64 编译配置
└── README.md          # 本文件
```

## 模块说明

| 模块 | 职责 |
|------|------|
| `types.h` | 定义共享结构体 `ProcessInfo`、`CpuSample`、`MemoryInfo`、`GpuInfo`、`ViewType` |
| `cpu` | `GetSystemTimes` 差值计算 CPU 使用率 |
| `memory` | `GlobalMemoryStatusEx` 获取物理内存状态 |
| `process` | `CreateToolhelp32Snapshot` + `OpenProcess` + `GetProcessMemoryInfo` 进程枚举 |
| `gpu` | DXGI 获取适配器信息，NVML / nvidia-smi 后备方案获取显存和使用率 |
| `ui` | 双缓冲渲染、ANSI 24-bit 真彩色、Box-drawing 面板、进度条、键盘输入 |
| `main` | 主循环：采集 → 排序 → 渲染 → 休眠 → 响应输入 |

## 键盘控制

| 按键 | 功能 |
|------|------|
| `1` | Dashboard 总览 |
| `2` | 进程列表 |
| `3` | CPU 详情 |
| `4` | 内存详情 |
| `5` | GPU 详情 |
| `H` | 帮助页面 |
| `+` / `-` | 加快 / 减慢刷新率 |
| `Q` | 退出程序 |
| `Ctrl+C` | 强制退出 |

## 编译

### 方式一：使用 MinGW-w64 + Makefile（推荐）

```bash
mingw32-make
```

### 方式二：直接调用 MinGW-w64 gcc

```bash
gcc -O2 -Wall -Wextra -Iinclude -DCOBJMACROS -DINITGUID ^
    -o build\mini_task_manager.exe ^
    src/main.c src/cpu.c src/memory.c src/process.c src/gpu.c src/ui.c ^
    -lpsapi -ldxgi -lole32
```

### 方式三：使用 Visual Studio（MSVC）

在 **x64 Native Tools Command Prompt** 中执行：

```cmd
cl /O2 /W4 /utf-8 /Iinclude ^
   src\main.c src\cpu.c src\memory.c src\process.c src\gpu.c src\ui.c ^
   /link psapi.lib dxgi.lib ole32.lib /Fe:build\mini_task_manager.exe
```

## 运行

```bash
# 通过 Makefile
mingw32-make run

# 或直接运行
.\build\mini_task_manager.exe
```

按 `Q` 或 `Ctrl+C` 退出程序。

## GPU 监控说明

GPU 信息采集按优先级依次尝试：

1. **DXGI** — 获取适配器名称、显存总量
2. **DXGI 1.4 `QueryVideoMemoryInfo`** — 查询实时显存使用（需要 Windows 10+）
3. **NVML**（nvidia-ml.dll）— 精确显存使用 + GPU 核心使用率（NVIDIA 显卡）
4. **nvidia-smi** 命令行 — 最后的后备方案

非 NVIDIA 显卡或集成显卡可能无法获取使用率数据。

## 使用的 WinAPI / 库

| API | 用途 |
|-----|------|
| `GetSystemTimes` | 获取系统 CPU 时间统计 |
| `GlobalMemoryStatusEx` | 获取物理内存状态信息 |
| `GetTickCount64` | 获取系统自启动以来的毫秒数 |
| `CreateToolhelp32Snapshot` | 创建系统进程快照 |
| `Process32First` / `Process32Next` | 遍历进程快照中的进程 |
| `OpenProcess` | 打开进程句柄以查询内存信息 |
| `GetProcessMemoryInfo` | 获取指定进程的内存使用详情 |
| `CreateDXGIFactory1` / `EnumAdapters1` | DXGI GPU 适配器枚举 |
| `GetSystemInfo` | 获取系统处理器信息 |
| `WriteConsoleA` | 双缓冲控制台输出 |
| `_kbhit` / `_getch` | 非阻塞键盘输入检测 |

## 注意事项

1. **管理员权限**：部分系统进程需要管理员权限才能获取 Working Set，非管理员运行时这些进程的 Working Set 将显示为 0。
2. **受保护进程**：OpenProcess 对受保护的进程可能失败，属于正常现象，程序会继续处理其他进程。
3. **终端要求**：需要支持 ANSI 转义和 24-bit 真彩色的终端（Windows Terminal 推荐，传统 conhost 需要 Win10 1703+）。
4. **最小权限原则**：使用 `PROCESS_QUERY_LIMITED_INFORMATION` 而非 `PROCESS_ALL_ACCESS`，降低权限需求。
5. **GPU 依赖**：GPU 核心使用率查询需要 NVIDIA 显卡 + NVML 或 nvidia-smi 可用。
