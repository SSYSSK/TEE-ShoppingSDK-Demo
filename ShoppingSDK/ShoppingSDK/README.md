# ShoppingSDK 集成文档
1、把项目ShoppingSDKBundle.bundle和ShoppingSDK.framework 拖拽到您项目的目录下

2、在您项目的Target-->Build Settings -->Other Linker Flags 设置值为 -ObjC

3、在您项目info.plist中设置允许相机和相册的访问配置：
Privacy - Camera Usage Description
Privacy - Photo Library Usage Description

4 、因为贵公司提供的是http 的接口，所以您项目还需要设置一个允许http请求的配置
App Transport Security Settings
