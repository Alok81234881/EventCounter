//
//  FAQView.swift
//  EventCounter
//
//  Created by Alok SIngh on 03/01/26.
//

import SwiftUI

// MARK: - Model
struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

// MARK: - Main View
struct FAQView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var expandedID: UUID?

    private let faqs: [FAQItem] = [
        FAQItem(
            question: "How do I create a new event?",
            answer: "Tap the + button on the home screen and fill in the event details such as title, date, and category."
        ),
        FAQItem(
            question: "Can I share my countdown?",
            answer: "Yes. Open the event and tap the Share button to share your countdown with others."
        ),
        FAQItem(
            question: "How do I change the theme?",
            answer: "You can change the theme from the Settings screen under Appearance."
        ),
        FAQItem(
            question: "Is the app free to use?",
            answer: "Yes, the app is free to use with optional premium features available."
        ),
        FAQItem(
            question: "How do I delete an event?",
            answer: "Open the event, scroll down, and tap Delete Event. Confirm the action to delete it permanently."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // FAQ List
                VStack(spacing: 16) {
                    ForEach(faqs) { faq in
                        FAQRow(
                            faq: faq,
                            isExpanded: expandedID == faq.id
                        ) {
                            withAnimation(.easeInOut) {
                                expandedID = expandedID == faq.id ? nil : faq.id
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Support Card
                supportCard
                    .padding(.horizontal)
                    .padding(.top, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("FAQs")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }

    // MARK: - Support Card
    private var supportCard: some View {
        VStack(spacing: 16) {

            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: "headphones")
                    .font(.system(size: 26))
                    .foregroundColor(Color.purple)
            }

            Text("Still need help?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.primary)

            Text("Can't find what you're looking for? Our support team is here to assist you.")
                .font(.system(size: 15))
                .foregroundColor(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                contactSupport()
            } label: {
                Text("Contact Support")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 40)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.adaptiveTertiaryBackground)
        .cornerRadius(24)
    }

    // MARK: - Actions
    private func contactSupport() {
        print("Contact support tapped")
    }
}

// MARK: - FAQ Row
struct FAQRow: View {

    let faq: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(faq.question)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(isExpanded ? Color.purple : Color.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }

            if isExpanded {
                Text(faq.answer)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FAQView()
    }
}
