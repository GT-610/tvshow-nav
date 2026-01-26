# 电视直播导航

## 项目简介
餐桌上的 Windows 平板一直都是家人看电视用的，每次都得打开浏览器输入网址看直播，即使添加到收藏夹也很麻烦。于是就做了这样一个导航站。

本项目基于 Flutter + Fluent UI 框架开发，专为 Windows 桌面优化。

## 功能
- 展示所有已添加的电视直播链接
- 添加、查看、编辑或删除已有的电视直播链接
- 集成 SQLite 数据库存储电视直播信息
- 原生 Windows 界面风格

## 技术栈
- **框架**: Flutter 桌面应用
- **UI**: Fluent UI (Windows 原生风格)
- **数据库**: SQLite (sqflite)
- **平台**: Windows 10/11

## 运行方式
```bash
flutter run -d windows
```

## 构建发布版本
```bash
flutter build windows
```
## 注意事项
- 该项目本来为自用用途，**未做足够的安全性考查**，**不建议直接用于生产环境**。本人也**不为该项目负任何责任**。

## 贡献
如果有任何问题或建议，请提交 Issues 或 PR。

## 许可证
源代码：Apache License 2.0。详见 [LICENSE](LICENSE)。