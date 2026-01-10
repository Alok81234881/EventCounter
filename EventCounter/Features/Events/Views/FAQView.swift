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
            question: "How do I enable Live Activities?",
            answer: "Go to the event details screen, tap 'Settings', and toggle 'Live Activity'. This will pin the event countdown to your Lock Screen and Dynamic Island."
        ),
        FAQItem(
            question: "Can I have multiple widgets?",
            answer: "Yes, you can add as many widgets as you like to your Home Screen. Long press a widget and tap 'Edit Widget' to choose which event it displays."
        ),
        FAQItem(
            question: "How do I add a Lock Screen widget?",
            answer: "Long press on your Lock Screen, tap Customize, select your Lock Screen, tap the widget area, and select Pulse from the list."
        ),
        FAQItem(
            question: "Can I share my countdown?",
            answer: "Yes. Open the event and tap the Share button to share your countdown with others."
        ),
        FAQItem(
            question: "Is the app free to use?",
            answer: "Yes, the app is free to use with optional premium features available."
        ),
        FAQItem(
            question: "Why do I need to sign in?",
            answer: "We use 'Sign in with Apple' to secure your data and sync your events across all your devices via iCloud. No personal data is stored on our servers."
        ),
        FAQItem(
            question: "Does my data sync across devices?",
            answer: "Yes! As long as you are signed in with the same Apple ID on all devices, your events will automatically sync via iCloud."
        ),
        FAQItem(
            question: "How do I delete my account?",
            answer: "Go to Settings > Delete Account. This will permanently remove all your data from iCloud and your local device. This action cannot be undone."
        )
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
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
            .padding(.top, 10)
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
            
            Text("support@redonelabs.com")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.purple)
                .padding(.top, -4)

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
        if let url = URL(string: "mailto:support@redonelabs.com") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
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
