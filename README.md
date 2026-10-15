# TL-clean: Typeless 设备标识一键重置工具 (Windows 11 / 10)

> 解除 Typeless Windows 端多账号登录限制，解决 `"The number of users logged into this device has exceeded the limit."` 错误，让服务端将本机识别为全新设备。
> 
> 针对 Windows 系统专属定制，填补社区方案大多仅支持 macOS 的空白。

---

## 💡 背景

Typeless 客户端为了限制单台设备上的账号登录数量（防止多账号轮换试用），会在本地生成一个全局唯一的 **Device ID（设备 UUID）** 并在每次请求服务端时携带。

当你在同一台设备上频繁切换或登录多个账号后，服务端会返回错误：
```text
The number of users logged into this device has exceeded the limit.
(当前设备登录用户数已超出限制)
```

在 macOS 上社区已有重置脚本（通过清理 Keychain 和 macOS 专用目录），但在 **Windows 11 / 10** 下，Typeless 的核心原生库 `UtilHelper.dll` 采用了一套**双重互锁机制**：
1. **Windows 凭据管理器（Credential Manager）**：条目 `Typeless.deviceIdentifier`（用户名 `Typeless.security.auth_key`）；
2. **本地设备缓存文件**：`%APPDATA%\Typeless\Cache\device.cache`。

如果仅仅卸载重装或清理临时文件夹，程序启动时会从凭据管理器中自动恢复旧的 Device ID，导致换号依然被识别为老设备。**本项目通过脚本彻底清除该互锁链条，使客户端启动时自动生成全新的设备 UUID。**

---

## ✨ 特性

- **零依赖，双击即用**：采用 Windows 原生批处理（`.bat`）与内置 PowerShell，不需要安装 Node.js、Python 或任何第三方运行环境。
- **保护历史记录**：**不暴力清空整个数据目录**，精准清除设备指纹与登录会话，完整保留你的本地历史录音文件与转写数据库（`typeless.db`）。
- **编码防乱码优化**：针对 Windows CMD 环境进行了控制台编码与 CRLF 换行适配，双击运行不乱码、不闪退。

---

## 🚀 使用方法

1. 从本仓库下载 [`reset-device-windows.bat`](./reset-device-windows.bat)（或点击右上角 Code -> Download ZIP 解压）；
2. **直接双击运行 `reset-device-windows.bat`**；
3. 按照提示等待脚本执行完毕（约 1~2 秒）；
4. 重新启动 Typeless 客户端，此时客户端已生成全新设备指纹，输入新账号登录即可。

---

## 🔍 底层原理对比 (Windows vs macOS)

| 识别维度 | macOS 机制 | Windows 11 / 10 机制 (本项目解决) |
| :--- | :--- | :--- |
| **持久化凭据** | macOS Keychain (`now.typeless.desktop.deviceIdentifier`) | Windows 凭据管理器 (`Typeless.deviceIdentifier`) |
| **设备缓存文件** | `~/Library/Application Support/now.typeless.desktop/device.cache` | `%APPDATA%\Typeless\Cache\device.cache` |
| **登录会话状态** | `~/Library/Application Support/Typeless/user-data.json` | `%APPDATA%\Typeless.exe\user-data.json` & `app-storage.json` |
| **重置触发逻辑** | 清除 Keychain + cache，下次启动生成新 UUID | 清除 Windows 凭据 + cache，下次启动通过 `CoCreateGuid()` 生成新 UUID |

---

## ⚠️ 注册与使用新账号注意事项

如果您注册新账号仍被识别或无法获得试用，请注意以下官方风控规则：

1. **邮箱类型限制（核心）**：
   - Typeless 官方对注册渠道进行了严格风控，**临时邮箱（10-minute mail 等）和自建域名邮箱（包含 Cloudflare 邮件转发等）已被官方拉黑**，注册后可能无法获得 Pro 试用或直接受限；
   - **强烈建议使用常规主流个人邮箱注册**（如 Gmail、Outlook、Yahoo、iCloud 等）。
2. **浏览器环境隔离**：
   - 网页端注册新账号时，建议使用**浏览器无痕窗口（隐身模式）**，避免旧账号的 Cookie 和浏览器指纹关联。

---

## 🤝 致谢与参考

- 启发与 macOS 实现参考：[estarpro1022/typeless-reset-device](https://github.com/estarpro1022/typeless-reset-device)

---

## 📄 免责声明

本项目仅供个人学习、逆向工程研究与测试交流使用。请尊重软件开发者的知识产权与商业服务条款，严禁用于任何商业牟利或违规滥用行为。