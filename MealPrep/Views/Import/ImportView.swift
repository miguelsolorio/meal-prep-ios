import SwiftUI

struct ImportView: View {
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    // Icon + heading
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.accentColor)

                        VStack(spacing: 4) {
                            Text("Add Recipe")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Paste a NYT Cooking recipe URL")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 16)

                    // URL field
                    HStack(spacing: 10) {
                        Image(systemName: "link")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        TextField("https://cooking.nytimes.com/…", text: $urlText)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isTextFieldFocused)
                            .submitLabel(.go)
                            .onSubmit { importIfNeeded() }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    if let error = store.importError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(error)
                                .font(.footnote)
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    }

                    Button(action: importIfNeeded) {
                        Group {
                            if store.isImporting {
                                HStack(spacing: 8) {
                                    ProgressView().tint(.white)
                                    Text("Importing…")
                                }
                            } else {
                                Text("Import Recipe")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(store.isImporting || urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
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
