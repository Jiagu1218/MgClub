## 项目简介

MgClub 是一个基于 **HarmonyOS / ArkTS（ArkUI V2）** 的应用工程，当前包含一个 `entry` 模块，入口页面为 `Index.ets`，通过 `MainTabPage` 组织应用的主要功能页面（如首页、发现、消息、我的等）。

本仓库已经按 ArkTS 规范进行了类型约束与代码风格配置，适合继续基于 ArkUI V2 + MVVM 模式进行功能扩展与性能优化。

## 开发环境

- **操作系统**: Windows / macOS / Linux（已安装 HarmonyOS SDK 所需依赖）
- **IDE**: DevEco Studio（推荐最新稳定版）
- **运行环境**: HarmonyOS 模拟器或真机（推荐与 `build-profile.json5` 中的 `targetSdkVersion` 保持一致，如 `6.0.2(22)`）

## 工程结构（简要）

- `entry/`
  - `src/main/ets/pages/`
    - `Index.ets`：应用入口页面，挂载 `MainTabPage`
    - `HomePage.ets` / `DiscoverPage.ets` / `MessagePage.ets` / `ProfilePage.ets` 等业务页面
  - `src/main/ets/common/network/`：网络访问与连接池封装（如 `HttpConnectionPool.ets`、`RcpClient.ets`、`SessionPool.ets`）
  - `src/main/ets/viewmodel/`：视图模型层（ViewModel），负责业务逻辑与状态管理
  - `src/main/resources/`：多语言字符串、颜色、媒体资源与页面路由配置
- `build-profile.json5`：应用及模块构建配置（产品、构建模式、SDK 版本等）
- `hvigor/` / `hvigorfile.ts`：HarmonyOS 构建脚本与配置

## 快速开始

1. **导入工程**
   - 打开 DevEco Studio，选择 `Open Project`，指向本仓库根目录 `MgClub`。

2. **同步与构建**
   - IDE 会自动解析 `build-profile.json5` 与 `hvigor` 配置。
   - 首次导入后，等待依赖下载与索引完成，确保工程能正常 `Make Project`。

3. **运行应用**
   - 在 DevEco Studio 顶部工具栏选择目标设备（HarmonyOS 模拟器或真机）。
   - 选择运行配置为 `entry` 模块的默认 Ability。
   - 点击 **Run** 按钮，编译完成后应用将自动安装并启动。

## 开发规范与注意事项

本项目已经在 `.cursor/rules/` 中配置了 ArkTS 相关规则，建议在开发时遵循以下约定：

- **ArkUI V2 组件**
  - 新增页面/组件统一使用 `@ComponentV2`，并遵循 ArkUI V2 状态管理规范。
  - 避免继续使用 V1 的 `@State` / `@Prop` / `@Link` / `@Watch` 等装饰器。

- **类型与语法**
  - 禁止使用 `any` / `unknown` 等宽泛类型，所有参数与返回值必须显式标注类型。
  - 避免解构赋值、展开运算符 `...`、`for..in` 等 ArkTS 不兼容语法。

- **网络访问**
  - 统一通过 `common/network` 模块中已封装的客户端（如 `HttpConnectionPool`、`ApiClient` 等）发起请求。
  - 每次请求创建的 `http` 实例需在完成后 `destroy()`，并设置合理的超时。

- **架构风格**
  - 页面（View）仅负责渲染与简单交互，将业务逻辑下沉到 ViewModel。
  - ViewModel 使用 `@ObservedV2` + `@Trace` 管理状态，使用 `@Computed` 表达派生状态。

## 后续可扩展方向

- 补充接口文档与接口 Mock，完善 `common/network/api` 目录。
- 为主要页面与 ViewModel 添加单元测试（`entry/src/test`、`entry/src/ohosTest`）。
- 根据业务需求完善 README，增加功能截图、接口说明以及版本变更记录等。

## AI IDE 相关资源推荐

- **open-deveco GitHub 组织**：[`open-deveco`](https://github.com/open-deveco)  
  提供 HarmonyOS 相关的 AI IDE 工具与示例（如 `deveco-toolbox`），有助于在 DevEco Studio / Cursor 中提升自动补全与智能提示效果。

- **HarmonyOS 开发规则生成器**：[`harmony-cursor-rules`](https://github.com/skindhu/harmony-cursor-rules)  
  基于官方文档自动生成 HarmonyOS / ArkTS 的 Cursor 规则文件，可显著提升 AI IDE 对 HarmonyOS 项目的理解和代码生成质量。


