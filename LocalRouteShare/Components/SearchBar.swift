import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var backgroundColor: Color = Color.backgroundGray
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textSecondary)

            TextField(placeholder, text: $text)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
                .textInputAutocapitalization(.never)
                .onSubmit(onSubmit)

            if text.isEmpty == false {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary.opacity(0.65))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray.opacity(0.75), lineWidth: 1)
        )
    }
}
