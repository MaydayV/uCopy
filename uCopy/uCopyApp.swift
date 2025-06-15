//
//  uCopyApp.swift
//  uCopy
//
//  Created by 周辉 on 2022/11/2.
//

import SwiftUI
import Combine
import AVFoundation
import KeyboardShortcuts
import AppKit
import CoreData

// 添加AppDelegate处理应用程序生命周期
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 禁用标签页功能
        NSWindow.allowsAutomaticWindowTabbing = false
        
        // 减少系统级警告和日志输出
        UserDefaults.standard.set(false, forKey: "NSApplicationCrashOnExceptions")
        
        // 设置应用程序为后台应用，减少不必要的系统检查
        NSApp.setActivationPolicy(.accessory)
    }
    
    // 当应用程序即将终止时保存数据
    func applicationWillTerminate(_ notification: Notification) {
        // 可以在这里执行额外的清理工作
    }
}

@main
struct uCopyApp: App {
    // 使用AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let monitor = PasteboardMonitor()
    let pub = NotificationCenter.default.publisher(for: .NSPasteboardDidChange)
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("uCopy.sound")
    private var sound = "blow" // 使用字符串替代枚举
    private var maxSavedLength: Int {
        Int(self.maxSaved) ?? 20
    }
    @AppStorage("uCopy.maxSavedLength")
    private var maxSaved = "20"
    
    // 不再使用isFirstLaunch标记
    @State var pasteboardMonitorCancellable: AnyCancellable?
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        // 移除欢迎页面逻辑，仅保留设置和菜单栏图标
        Settings {
            SettingsView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
        
        MenuBarExtra("Menu Bar", systemImage: "clipboard") {
            HistoryView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
            if #available(macOS 14, *) {
                SettingsLink {
                    Text("Perferences...")
                }
                .keyboardShortcut(",")
            } else {
                Button("Perferences...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    for window in NSApplication.shared.windows {
                        if window.title == "General" || window.title == "Snippet" || window.title == "About" {
                            window.level = .floating
                        }
                    }
                }.keyboardShortcut(",")
            }
            Divider()
            Button("Quit") {
                monitor.terminate()
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                AccessibilityService.isAccessibilityEnabled(isPrompt: true)
                KeyboardShortcuts.onKeyDown(for: .historyShortcuts) {
                    MenuManager.popupHistoryMenu()
                }
                KeyboardShortcuts.onKeyDown(for: .snippetShortcuts) {
                    MenuManager.popupSnippetMenu()
                }
                MenuManager.moc = dataController.container.viewContext
                monitor.managedObjectContext = dataController.container.viewContext
                self.pasteboardMonitorCancellable = pub.sink { n in
                    guard let data = n.userInfo?["data"] as? PasteboardData else {
                        return
                    }
                    
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
                    
                    let context = dataController.container.viewContext
                    
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
                    
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let existingRecords = try context.fetch(fetchRequest)
                        
                        if let existingRecord = existingRecords.first {
                            // 对于图片类型，进行额外的数据验证
                            let shouldReplace = true
                            
                            if typeString == "image" && existingRecord.data != nil && data.data != nil {
                                // 如果是图片，可以通过比较数据大小或其他特征进行额外验证
                                // 这里仅进行简单验证，实际应用中可能需要更复杂的图片比较算法
                                if existingRecord.data?.count == data.data?.count {
                                    // 如果数据大小相同，可能是同一张图片，但时间戳不同
                                    // 在这种情况下仍然更新记录以保持在顶部
                                }
                            }
                            
                            if shouldReplace {
                                // 如果找到相同内容的记录，删除它并创建新记录（保持在顶部）
                                context.delete(existingRecord)
                            }
                        }
                        
                        // 创建新记录或替换旧记录
                        let item = History(context: context)
                        item.id = UUID()
                        item.title = data.string
                        item.source = data.source
                        item.createDate = data.createDate
                        item.type = data.type.rawValue
                        item.data = data.data
                        
                        // 检查并删除超出限制的记录
                        let historyResults = try context.fetch(CoreDataHelper.historyFetchRequestWithLimit(size: 0))
                        for (index, item) in historyResults.enumerated() {
                            if index >= maxSavedLength {
                                context.delete(item)
                            }
                        }
                        try context.save()
                    } catch {
                        let nserror = error as NSError
                        print("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
        }
    }
}
