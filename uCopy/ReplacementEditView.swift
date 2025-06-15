import SwiftUI

struct ReplacementEditView: View {
    @ObservedObject var item: ReplacementRule
    @State private var fromText: String = ""
    @State private var toText: String = ""
    @Environment(\.managedObjectContext) var context

    var body: some View {
        VStack {
            Form {
                TextField("Text to replace", text: Binding(
                    get: { item.fromText ?? "" },
                    set: { newValue in
                        item.fromText = newValue
                        saveContext()
                    }
                ), prompt: Text("Text to replace"))
                TextField("Replacement text", text: Binding(
                    get: { item.toText ?? "" },
                    set: { newValue in
                        item.toText = newValue
                        saveContext()
                    }
                ), prompt: Text("Replacement text"))
            }
            Spacer()
        }
        .padding(.all)
        .onAppear {
            // 初始化本地状态（如果需要的话）
            fromText = item.fromText ?? ""
            toText = item.toText ?? ""
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
} 