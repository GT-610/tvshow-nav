# 电视直播导航系统

## 项目简介
餐桌上的 Windows 平板一直都是家人看电视用的，每次都得打开浏览器输入网址看直播，即使添加到收藏夹也很麻烦。于是就做了这样一个导航站。

起初只是给身边的人用，他们觉得都很方便，于是我决定开源，一方面供大家学习研究，零一方面也欢迎大家提出问题或建议，共同学习进步。

本项目基于 Python + Flask 框架，项目分为两个部分：`app-desktop.py` 和 `app-web.py`，分别用于桌面应用和 Web 部署。

## 功能
- 展示所有已添加的电视直播链接
- 添加、查看、编辑或删除已有的电视直播链接
- 集成小型 SQLite 数据库来存储电视节目信息

## 技术栈
- **后端**
  - Flask: 构建 Web 应用
  - SQLite3: 存储电视直播链接数据
  
- **前端**
  - HTML5, CSS3, JavaScript: 网页三大件。
  - Bootstrap 5.1.3: 响应式组件，美观易用的 UI。
  - jQuery 3.6.0: 简化 JavaScript 操作。

## 运行环境
- Python 3.x
- Flask 2.x

本项目在 Python 3.11 开发，但应该在 Python 3.6 及以上版本中均可运行。有任何问题，请提 Issue。

## 安装与运行
1. **安装依赖**

   ```bash
   pip install flask flaskwebgui
   ```
2. **初始化数据库**
    ```bash
    python init_db.py
    ```

3. **启动应用**
    
    - 只启动网页：

        ```bash
        python app-web.py
        ```
        访问 `http://127.0.0.1:5000/` 即可查看网站。如需生产环境正式部署，请使用 `gunicorn` 或其他支持 WSGI 的 Web 服务器。

    - 启动桌面应用
        ```bash
        python app-desktop.py
        ```



## 注意事项
- 该项目本来为自用用途，**未做足够的安全性考查**，**不建议直接用于生产环境**。本人也**不为该项目负任何责任**。
- 请根据实际情况修改 `app.config['SECRET_KEY']` 的值以保证安全性。
- 如果需要更改数据库路径，请修改 `DATABASE` 变量的值。

## 贡献
如果有任何问题或建议，请提交 Issues 或 PR。

## 许可证
源代码：Apache License 2.0。详见 [LICENSE]()。

图标：[来自 GNOME Project](https://gitlab.gnome.org/GNOME/adwaita-icon-theme/-/blob/master/Adwaita/scalable/mimetypes/video-x-generic.svg)，授权许可为 Creative Commons Attribution Share Alike 3.0 Unported。
