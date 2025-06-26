# uCopy v1.6 技术变更说明

本文档面向开发者，详细记录了uCopy v1.6版本中的技术变更，包括代码修改、架构调整和问题修复。

## 主要代码变更

### 1. 文本替换功能实现

添加了完整的文本替换功能实现，主要文件包括：

- `ReplacementSettingsView.swift` - 替换规则管理界面
- `ReplacementEditView.swift` - 替换规则编辑界面

核心逻辑实现：

```swift
// 在ReplacementSettingsView.swift中添加了替换规则的显示和管理
struct ReplacementSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Replacement.createDate, ascending: false)],
        animation: .default)
    private var rules: FetchedResults<Replacement>
    @State private var selectedRule: Replacement?
    @State private var showingAddReplacement = false
    
    // 实现替换规则的UI和逻辑
    ...
}

// 在ReplacementEditView.swift中实现了替换规则的编辑功能
struct ReplacementEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var originalText: String = ""
    @State private var replacementText: String = ""
    
    // 处理规则添加和保存逻辑
    ...
}
```

### 2. 多语言支持修复

修复了通用页面中多语言显示问题，主要改动：

```swift
// 在GeneralSettingsView.swift中
// 原代码：直接使用硬编码字符串
LaunchAtLogin.Toggle("Launch at login")
KeyboardShortcuts.Recorder("History Shortcuts:", name: .historyShortcuts)
KeyboardShortcuts.Recorder("Snippet Shortcuts:", name: .snippetShortcuts)

// 修改后：使用本地化字符串
LaunchAtLogin.Toggle(NSLocalizedString("Launch at login", comment: ""))
KeyboardShortcuts.Recorder(NSLocalizedString("History Shortcuts:", comment: ""), name: .historyShortcuts)
KeyboardShortcuts.Recorder(NSLocalizedString("Snippet Shortcuts:", comment: ""), name: .snippetShortcuts)
```

同时更新了中文本地化文件：

```
// 在zh-Hans.lproj/Localizable.strings中
"Launch at login" = "登录时启动";
"History Shortcuts:" = "历史记录快捷键:";
"Snippet Shortcuts:" = "片段快捷键:";
```

### 3. 设置窗口优化

#### 默认标签页修复

修改了`SettingView.swift`以确保默认显示通用页面：

```swift
struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, about, snippet, replacement
    }
    // 添加状态变量，默认选择通用标签页
    @State private var selectedTab: Tabs = .general
    
    var body: some View {
        // 使用绑定变量控制选中的标签页
        TabView(selection: $selectedTab) {
            // 标签页内容
            ...
        }
    }
}
```

#### 窗口层级修复

在`uCopyApp.swift`中修改窗口显示逻辑：

```swift
Button("Perferences...") {
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    for window in NSApplication.shared.windows {
        // 增加对"Replacement"窗口的支持，并强制窗口显示在前面
        if window.title == "General" || window.title == "Snippet" || 
           window.title == "About" || window.title == "Replacement" {
            window.level = .floating
            window.orderFrontRegardless()
        }
    }
}.keyboardShortcut(",")
```

#### 设置页面项目顺序调整

重新排序了`GeneralSettingsView.swift`中的设置项：

```swift
// 调整后的顺序：登录启动、提示音、保存条数、快捷键
Form {
    Section {
        LaunchAtLogin.Toggle(NSLocalizedString("Launch at login", comment: ""))
    }
    .padding(.bottom)
    
    Section {
        Picker(NSLocalizedString("Sound", comment: ""), selection: $selectedSound) {
            // 提示音选择
        }
    }
    .padding(.bottom)
    
    Section {
        HStack {
            TextField(NSLocalizedString("Max saved:", comment: ""), text: $maxSavedLength)
            // 最大保存数量
        }
    }
    .padding(.bottom)
    
    Section {
        KeyboardShortcuts.Recorder(NSLocalizedString("History Shortcuts:", comment: ""), name: .historyShortcuts)
        KeyboardShortcuts.Recorder(NSLocalizedString("Snippet Shortcuts:", comment: ""), name: .snippetShortcuts)
    }
    .padding(.bottom)
}
```

## 项目配置更新

1. **版本号更新**
   - 在`project.pbxproj`中将MARKETING_VERSION从1.5更新到1.6
   ```
   MARKETING_VERSION = 1.6;
   ```

2. **本地化资源更新**
   - 更新了`Localizable.strings`文件中的翻译内容
   - 完善了本地化覆盖范围

## 注意事项

1. 现在所有用户界面字符串都应使用`NSLocalizedString`进行包装，以确保正确支持多语言

2. 设置窗口现在会强制显示在前台，确保用户操作不会被其他窗口遮挡

3. 设置页面的顺序已按照逻辑流程重新组织，未来添加新设置项时应遵循此顺序 