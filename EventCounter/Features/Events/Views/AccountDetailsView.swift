//
//  Untitled.swift
//  EventCounter
//
//  Created by Alok SIngh on 03/01/26.
//

import SwiftUI

struct AccountDetailsView: View {

    // MARK: - State
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountModal = false

    // MARK: - Body
    var body: some View {
        ZStack {

            // Main content
            ScrollView {
                VStack(spacing: 24) {

                    headerSection
                    profileSection
                    personalInfoSection
                    actionButtons
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .blur(radius: showDeleteAccountModal ? 2 : 0)

            // Delete Account Modal
            if showDeleteAccountModal {
                DeleteAccountModal(
                    onDelete: {
                        showDeleteAccountModal = false
                        deleteAccount()
                    },
                    onCancel: {
                        showDeleteAccountModal = false
                    }
                )
            }
        }
        .overlay(alignment: .topLeading) {
        //.overlay(.topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.adaptivePrimaryText)
                    .padding(12)
                    .background(Color.adaptiveSecondaryBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
            }
            .padding(.leading, 16)
            
        }
        .alert("Log Out?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out? You will need to sign in again to access your events.")
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            

            Text("Account Details")
                .font(.system(size: 28, weight: .bold))
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    // MARK: - Profile
    private var profileSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 110, height: 110)

                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(28)
                    .foregroundColor(.gray)
                    .background(Circle().fill(Color(.systemGray6)))
                    .frame(width: 96, height: 96)
            }

            Text("Alex Doe")
                .font(.system(size: 22, weight: .semibold))

            Label("Signed in with Apple", systemImage: "applelogo")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color(.systemGray6)))
        }
        .padding(.top, 8)
    }

    // MARK: - Personal Info
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERSONAL INFORMATION")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 0) {
                infoRow(title: "Full Name", value: "Alex Doe")
                Divider()
                infoRow(title: "Email", value: "alex.doe@example.com")
            }
            .background(Color.adaptiveGroupedBackground)
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding()
    }

    // MARK: - Actions
    private var actionButtons: some View {
        VStack(spacing: 16) {

            // Log Out
            Button {
                showLogoutAlert = true
            } label: {
                Text("Log Out")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(Color.primary)
                    .background(Color.adaptiveGroupedBackground)
                    .cornerRadius(28)
            }

            // Delete Account
            Button {
                showDeleteAccountModal = true
            } label: {
                Text("Delete Account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(28)
            }

            Text("Permanently delete your account and all data. This action cannot be undone.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    // MARK: - Actions Logic
    private func logout() {
        print("Logging out…")
    }

    private func deleteAccount() {
        print("Deleting account…")
    }
}


struct DeleteAccountModal: View {

    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 64, height: 64)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 26))
                }

                Text("Delete Account Permanently?")
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text("This action cannot be undone. All your event data will be permanently removed from your account.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    onDelete()
                } label: {
                    Text("Delete Account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(28)
                }

                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.primary)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .padding(.horizontal, 24)
            .shadow(radius: 20)
        }
    }
}

#Preview {
    AccountDetailsView()
}
