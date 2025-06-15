import SwiftUI
import CoreData

struct ReplacementSettingsView: View {
    @FetchRequest(fetchRequest: CoreDataHelper.replacementRuleFetchRequest()) var rules: FetchedResults<ReplacementRule>
    @Environment(\.managedObjectContext) var context
    @State private var selection: ReplacementRule?
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selection) {
                    ForEach(rules, id: \.self) { rule in
                        NavigationLink((rule.fromText ?? "") + " → " + (rule.toText ?? "")) {
                            ReplacementEditView(item: rule)
                        }
                    }
                    .onMove(perform: move)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                HStack {
                    Button {
                        add(fromText: "要替换的文字", toText: "替换后的文字")
                        selection = .none
                        refreshID = UUID()
                    } label: {
                        Image(systemName: "plus.rectangle.fill")
                    }
                    Button {
                        if let item = selection {
                            delete(item: item)
                        }
                        selection = .none
                        refreshID = UUID()
                    } label: {
                        Image(systemName: "minus.rectangle.fill")
                    }
                    .disabled(selection == nil)
                }
            }
            Text("选择一条替换规则编辑")
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        var revisedItems: [ReplacementRule] = rules.map{ $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination)
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }
        try? context.save()
    }
    
    func delete(item: ReplacementRule) {
        context.delete(item)
        try? context.save()
    }
    
    @discardableResult
    func add(fromText: String, toText: String) -> ReplacementRule {
        let item = ReplacementRule(context: context)
        item.fromText = fromText
        item.toText = toText
        item.order = Int16(rules.count)
        try? context.save()
        return item
    }
} 