//
//  GeneralSettingsView.swift
//  uCopy
//
//  Created by 周辉 on 2022/11/16.
//

import SwiftUI
import AVFoundation
import LaunchAtLogin
import KeyboardShortcuts
import Combine

struct GeneralSettingsView: View {
    @AppStorage("uCopy.sound")
    private var selectedSound = "blow"
    @AppStorage("uCopy.maxSavedLength")
    private var maxSavedLength = "20"
    @State private var showingPopover = false
    
    private let availableSounds = ["none", "basso", "blow", "bottle", "frog", "funk", "glass", "hero", "morse", "ping", "pop", "purr", "sosumi", "submarine", "tink"]
    
    var body: some View {
        Form {
            Section {
                LaunchAtLogin.Toggle(NSLocalizedString("Launch at login", comment: ""))
            }
            .padding(.bottom)
            
            Section {
                Picker(NSLocalizedString("Sound", comment: ""), selection: $selectedSound) {
                    ForEach(availableSounds, id: \.self) { sound in
                        Text(sound.capitalized)
                    }
                }
            }
            .padding(.bottom)
            
            Section {
                HStack {
                    TextField(NSLocalizedString("Max saved:", comment: ""), text: $maxSavedLength)
                        .onReceive(Just(maxSavedLength)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.maxSavedLength = filtered
                            }
                        }
                    Button {
                        showingPopover = true
                    } label: {
                        Image(systemName: "questionmark")
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showingPopover) {
                        Text(NSLocalizedString("Excess items will be deleted automatically", comment: ""))
                            .font(.headline)
                            .padding()
                    }
                }
            }
            .padding(.bottom)
            
            Section {
                KeyboardShortcuts.Recorder(NSLocalizedString("History Shortcuts:", comment: ""), name: .historyShortcuts)
                KeyboardShortcuts.Recorder(NSLocalizedString("Snippet Shortcuts:", comment: ""), name: .snippetShortcuts)
            }
            .padding(.bottom)
        }
        .padding(20)
        .frame(width: 350, height: 100)
        .onChange(of: selectedSound) { newSound in
            if newSound != "none" {
                let soundName = newSound.capitalized
                if let soundObj = NSSound(named: soundName) {
                    soundObj.play()
                } else {
                    if let soundObjLower = NSSound(named: newSound.lowercased()) {
                        soundObjLower.play()
                    } else if let soundObjUpper = NSSound(named: newSound.uppercased()) {
                        soundObjUpper.play()
                    } else if let soundObjOriginal = NSSound(named: newSound) {
                        soundObjOriginal.play()
                    }
                }
            }
        }
    }
}
