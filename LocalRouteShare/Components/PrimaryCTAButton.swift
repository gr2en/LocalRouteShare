import SwiftUI

struct PrimaryCTAButton: View {
    var title: String
    var systemImage: String
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [Color.primaryPurple, Color.buttonBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(isDisabled ? 0.45 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
