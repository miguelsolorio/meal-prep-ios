import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var cookieText = ""
    @State private var showingSaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $cookieText)
                        .frame(minHeight: 100, maxHeight: 200)
                        .font(.system(.footnote, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    Button {
                        store.recipeCookie = cookieText
                        showingSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingSaved = false
                        }
                    } label: {
                        HStack {
                            Text(showingSaved ? "Saved!" : "Save Cookie")
                            if showingSaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                } header: {
                    Text("Browser Cookie")
                } footer: {
                    Text("Paste your browser cookie to access recipes on paywalled sites.")
                }

                Section("How to Get Your Cookie") {
                    howToRow(number: "1", text: "Open the recipe website in Safari on your Mac.")
                    howToRow(number: "2", text: "Open Safari's Develop menu → Show Web Inspector (or press ⌥⌘I).")
                    howToRow(number: "3", text: "Go to the Network tab and reload the page.")
                    howToRow(number: "4", text: "Click any request, find the Request Headers, copy the full Cookie value.")
                    howToRow(number: "5", text: "Paste the entire cookie string here and tap Save.")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                cookieText = store.recipeCookie
            }
        }
    }

    private func howToRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color.accentColor)
                .clipShape(Circle())
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
