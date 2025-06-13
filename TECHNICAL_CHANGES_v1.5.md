# uCopy v1.5 技术变更说明

本文档面向开发者，详细记录了uCopy v1.5版本中的技术变更，包括代码修改、架构调整和问题修复。

## 主要代码变更

### 1. 剪贴板重复检测实现

在`uCopyApp.swift`中添加了以下逻辑来检测和处理重复内容：

```swift
// 检查是否存在相同内容的记录
let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
let compareString = data.string

// 根据内容类型使用不同的比较策略
let typeString = data.type.rawValue

if typeString == "string" {
    // 对于文本类型，比较标题内容
    fetchRequest.predicate = NSPredicate(format: "title == %@ AND type == %@", compareString, typeString)
} else if typeString == "image" {
    // 对于图片类型，仅比较类型，因为图片数据可能稍有差异
    fetchRequest.predicate = NSPredicate(format: "type == %@ AND source == %@", typeString, data.source ?? "")
} else if typeString == "fileUrl" {
    // 对于文件URL，比较标题和类型
    fetchRequest.predicate = NSPredicate(format: "title == %@ AND type == %@", compareString, typeString)
}

// 如果找到相同内容的记录，删除它并创建新记录
if let existingRecord = existingRecords.first {
    context.delete(existingRecord)
}
```

### 2. 欢迎页面优化

通过在`uCopyApp.swift`中添加以下代码实现了首次启动检测：

```swift
// 首次启动标记
@AppStorage("uCopy.isFirstLaunch")
private var isFirstLaunch = true

// 在body中检测是否是首次启动
if isFirstLaunch {
    WindowGroup(id: "welcomeWindow") {
        WelcomeView()
            .fixedSize()
            .onAppear {
                // 显示欢迎页面后将标记设为false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFirstLaunch = false
                }
            }
    }
    .windowResizability(.contentSize)
}
```

### 3. 声音提示增强

重写了声音播放逻辑，增加多种格式尝试：

```swift
// 改进声音播放逻辑
if sound != "none" {
    let soundName = sound.capitalized
    if let soundObj = NSSound(named: soundName) {
        soundObj.play()
        // 调试信息
        print("正在播放声音: \(soundName)")
    } else {
        // 声音未找到时尝试其他大小写格式
        print("找不到声音: \(soundName)，尝试其他格式")
        // 尝试完全小写
        if let soundObjLower = NSSound(named: sound.lowercased()) {
            soundObjLower.play()
        } 
        // 尝试完全大写
        else if let soundObjUpper = NSSound(named: sound.uppercased()) {
            soundObjUpper.play()
        } 
        // 尝试原始格式
        else if let soundObjOriginal = NSSound(named: sound) {
            soundObjOriginal.play()
        } else {
            print("无法播放声音: \(sound)，所有格式尝试均失败")
        }
    }
}
```

## 架构调整

### 1. AppDelegate实现

添加了AppDelegate来更好地管理应用生命周期：

```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 禁用标签页功能
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    // 当应用程序即将终止时保存数据
    func applicationWillTerminate(_ notification: Notification) {
        // 可以在这里执行额外的清理工作
    }
}
```

### 2. 类型系统优化

将`SoundNames`枚举类型改为字符串类型，解决类型冲突问题：

```swift
// 原代码
@AppStorage("uCopy.sound")
private var sound: SoundNames = .blow

// 修改后
@AppStorage("uCopy.sound")
private var sound = "blow" // 使用字符串替代枚举
```

## 错误修复

1. **修复了编译错误**
   - "SoundNames is ambiguous" - 通过使用字符串替代枚举解决
   - "Failed to produce diagnostic for expression" - 修改了类型系统和变量定义

2. **内存管理改进**
   - `var shouldReplace = true` 改为 `let shouldReplace = true`
   - 优化了变量作用域和生命周期

## 项目配置更新

1. **版本号更新**
   - 在`project.pbxproj`中将MARKETING_VERSION从1.4更新到1.5
   ```
   MARKETING_VERSION = 1.5;
   ```

2. **项目设置更新**
   - 更新到Xcode推荐的项目设置
   - 优化构建配置和编译器设置

## 注意事项

1. 如果未来需要修改`sound`相关逻辑，请记住它现在是字符串类型，不再是枚举

2. `isFirstLaunch`逻辑已移除，如果需要恢复欢迎页面，需要重新添加这部分代码

3. 目前声音播放有多种格式尝试，这可能会导致控制台输出较多日志信息 