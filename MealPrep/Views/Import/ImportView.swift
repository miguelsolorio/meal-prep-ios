import SwiftUI

struct ImportView: View {
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paste a NYT Cooking recipe URL below.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField(text: $urlText, prompt: nil) { EmptyView() }
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isTextFieldFocused)
                        .submitLabel(.go)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onSubmit { importIfNeeded() }
                }

                if let error = store.importError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: importIfNeeded) {
                    if store.isImporting {
                        HStack {
                            ProgressView().tint(.white)
                            Text("Importing…")
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Import Recipe")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(store.isImporting || urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        store.importError = nil
                        dismiss()
                    }
                }
            }
            .onAppear { isTextFieldFocused = true }
        }
    }

    private func importIfNeeded() {
        guard !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !store.isImporting else { return }
        isTextFieldFocused = false
        Task {
            await store.importRecipe(from: urlText)
            if store.importError == nil {
                dismiss()
            }
        }
    }
}
