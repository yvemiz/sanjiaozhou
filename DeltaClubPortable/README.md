# Delta 电竞护航本地部署包

这是一个 Windows 本地预览包。将整个文件夹复制到另一台 Windows 电脑后，双击 `START.bat`；浏览器会打开后台和 H5。无需安装 Docker、Node、Maven 或 MySQL。

首次启动会在 `data` 文件夹初始化独立数据库并导入 `setup/delta_game.sql`，首次启动时间较长。后续数据保存在 `data` 中。不要删除 `data`，否则会重置本地预览数据。

后台地址：`http://localhost:3000/login`

用户/打手 H5 地址：`http://localhost:5174/`

本地后台账号：`preview`

本地后台密码：`DeltaPreview2026!`

双击 `STOP.bat` 可关闭本部署包启动的服务。日志保存在 `logs` 文件夹。

同一局域网内供其他电脑访问时，可运行 `START.bat -Lan`，然后使用启动窗口显示的本机局域网 IP。Windows 防火墙可能需要允许专用网络访问。不要在公网开放未配置 HTTPS 和正式账号的预览包。

此包用于本地演示，不包含微信小程序审核发布、微信登录、微信支付或公网服务器配置。
