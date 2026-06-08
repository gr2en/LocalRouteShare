import SwiftUI

struct AddRouteProposalView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private let embedsInNavigationStack: Bool

    @State private var startPoint = ""
    @State private var endPoint = ""
    @State private var reason = ""
    @State private var expectedBenefits: Set<String> = ["Save commuting time"]

    private let benefitOptions = [
        "Save commuting time",
        "Better access on rainy days",
        "Safer night commute",
        "Improved accessibility",
        "Reduce walking distance"
    ]

    private var isValid: Bool {
        startPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && endPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    init(embedsInNavigationStack: Bool = true) {
        self.embedsInNavigationStack = embedsInNavigationStack
    }

    @ViewBuilder
    var body: some View {
        if embedsInNavigationStack {
            NavigationStack {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 14) {
                    RouteFormTextField(title: "From", placeholder: "ex. Muak Dorm", text: $startPoint)
                    RouteFormTextField(title: "To", placeholder: "ex. Sinchon Stn.", text: $endPoint)
                }

                proposedRouteCard

                RouteFormTextEditor(
                    title: "Why is this route needed?",
                    placeholder: "ex. Walking to Sinchon Station takes too long. A shuttle route would make commuting easier.",
                    text: $reason
                )

                benefitsSection

                Button {
                    submit()
                } label: {
                    Text("Submit Route Request")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(isValid ? Color.primaryPurple : Color.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isValid == false)
            }
            .padding(20)
            .padding(.bottom, 18)
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Suggest a New Route")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(Color.textSecondary)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    submit()
                }
                .fontWeight(.bold)
                .disabled(isValid == false)
            }
        }
    }

    private var proposedRouteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Proposed Route")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            VStack(alignment: .leading, spacing: 14) {
                RouteStep(label: "Origin", tint: Color.primaryPurple)

                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.borderGray)
                        .frame(width: 1, height: 26)
                        .padding(.leading, 7)

                    Text("+ Add stopover")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }

                RouteStep(label: "Destination", tint: Color.primaryPurple)

                HStack {
                    Spacer()

                    Button("View Route") {}
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 10)
                        .frame(height: 22)
                        .background(Color.backgroundGray)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Expected Benefits")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(benefitOptions, id: \.self) { benefit in
                    Button {
                        if expectedBenefits.contains(benefit) {
                            expectedBenefits.remove(benefit)
                        } else {
                            expectedBenefits.insert(benefit)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: expectedBenefits.contains(benefit) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(expectedBenefits.contains(benefit) ? Color.primaryPurple : Color.textSecondary)

                            Text(benefit)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.textPrimary)

                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }

    private func submit() {
        viewModel.addRouteProposal(
            startPoint: startPoint,
            endPoint: endPoint,
            reason: reason,
            expectedBenefits: expectedBenefits.sorted()
        )
        dismiss()
    }
}

private struct RouteStep: View {
    var label: String
    var tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(tint)
                .frame(width: 14, height: 14)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)

            Spacer()
        }
    }
}

private struct RouteFormTextField: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            TextField(placeholder, text: $text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.borderGray, lineWidth: 1)
                )
        }
    }
}

private struct RouteFormTextEditor: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.subheadline)
                    .padding(10)
                    .frame(minHeight: 132)
                    .scrollContentBackground(.hidden)

                if text.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
}
