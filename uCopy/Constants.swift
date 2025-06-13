//
//  Constants.swift
//  uCopy
//
//  Created by 周辉 on 2022/12/1.
//

import Foundation
import KeyboardShortcuts

let DEFAULT_MENU_BAR_PAGE_SIZE = 20
let DEFAULT_MENU_PAGE_SIZE = 40

// 键盘快捷键
extension KeyboardShortcuts.Name {
    static let historyShortcuts = Self("historyShortcuts",
                                       default: .init(.c, modifiers: [.command, .option]))
    static let snippetShortcuts = Self("snippetShortcuts",
                                       default: .init(.x, modifiers: [.command, .option]))
}
