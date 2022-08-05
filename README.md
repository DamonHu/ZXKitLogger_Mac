# ZXKitLogger_Mac

![](https://img.shields.io/badge/platform-MacOS-brightgreen) ![](https://img.shields.io/badge/interface-swiftUI-brightgreen) ![](https://img.shields.io/badge/license-MIT-brightgreen) 

![](./preview/Jietu20220731-212644.png)

用于方便的查看iOS手机端的调试日志库 [ZXKitLogger](https://github.com/DamonHu/ZXKitLogger)生成的原始log日志。

[ZXKitLogger](https://github.com/DamonHu/ZXKitLogger) 使用SQLite存储日志信息，如果使用通用的SQLite查看工具，只是一条一条的表格，并且有的还收费。所以开发该工具方便查看配合`ZXKitLogger`更直观的查看数据。

## 客户端下载

[Releases](https://github.com/DamonHu/ZXKitLogger_Mac/releases)，下载`Release`中的`dmg`文件，拖拽进应用程序即可

## 本地日志

将`ZXKitLogger`生成的`db`文件直接拖进左侧菜单栏，即可自动解析并根据日志类型显示颜色

## 远程日志

远程日志指的是客户端已经接入了`ZXKitLogger`的局域网实时日志功能。[ZXKitLogger局域网实时日志](https://github.com/DamonHu/ZXKitLogger#%E5%85%AD%E5%B1%80%E5%9F%9F%E7%BD%91%E5%AE%9E%E6%97%B6%E6%97%A5%E5%BF%97)，可以通过该工具查看同一局域网下设备的日志。

## 客户端配置

如果手机客户端修改了`socketPort`、`socketDomain`、`socketType`、或者解密的`privacyLogPassword`、`privacyLogIv`的值，那么请在MAC客户端的设置中修改成对应的值，两端保持一致，否则会导致连接或者解密错误

## 开发进度

该项目刚刚开始开发，慢慢完善

- [x] ZXKitLogger原始db文件查看
-  [x] 历史记录
- [x] 搜索功能
- [x] 局域网查看实时日志
-  [x] 直接解析加密数据
- [ ] And more

## License

该项目基于MIT协议，您可以自由修改使用