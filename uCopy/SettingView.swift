//
//  SettingView.swift
//  uCopy
//
//  Created by 周辉 on 2022/11/12.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, about, snippet, replacement
    }
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            SnippetSettingsView()
                .tabItem {
                    Label("Snippet", systemImage: "bubbles.and.sparkles")
                }
                .tag(Tabs.snippet)
            ReplacementSettingsView()
                .tabItem {
                    Label("Replacement", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(Tabs.replacement)
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "timelapse")
                }
                .tag(Tabs.about)
        }
        .padding(20)
        .frame(width: 800, height: 500)
    }
}
