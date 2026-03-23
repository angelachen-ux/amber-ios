//
//  AmberIDView.swift
//  Amber
//
//  Created on 2026-01-17.
//

import SwiftUI

struct AmberIDView: View {
    @StateObject private var viewModel = AmberIDViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var journalText = ""
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Identity Card with Live Tracking
                    VStack(spacing: 16) {
                        // Avatar with ring
                        ZStack {
                            Circle()
                                .stroke(Color.amberBlue, lineWidth: 3)
                                .frame(width: 106, height: 106)

                            ContactAvatar(
                                name: viewModel.user.name,
                                imageURL: viewModel.user.avatarURL,
                                size: 100
                            )
                        }

                        Text(viewModel.user.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("@\(viewModel.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Live Tracking Insights
                        VStack(spacing: 12) {
                            Text("Today's Activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Move Line
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Move")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(Int(viewModel.moveProgress * 100))%")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 4)

                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.red.gradient)
                                                .frame(width: geometry.size.width * CGFloat(viewModel.moveProgress), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }

                            // Exercise Line
                            HStack(spacing: 12) {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Exercise")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(Int(viewModel.exerciseProgress * 100))%")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 4)

                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.green.gradient)
                                                .frame(width: geometry.size.width * CGFloat(viewModel.exerciseProgress), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }

                            // Stand Line
                            HStack(spacing: 12) {
                                Image(systemName: "figure.stand")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Stand")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(Int(viewModel.standProgress * 100))%")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 4)

                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.blue.gradient)
                                                .frame(width: geometry.size.width * CGFloat(viewModel.standProgress), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }

                            // Sleep Line
                            HStack(spacing: 12) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.indigo)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Sleep")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(viewModel.sleepHours, specifier: "%.1f")h")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 4)

                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.indigo.gradient)
                                                .frame(width: geometry.size.width * CGFloat(min(viewModel.sleepHours / 8.0, 1.0)), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }

                            // Screen Time Line
                            HStack(spacing: 12) {
                                Image(systemName: "iphone")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Screen Time")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("\(viewModel.screenTimeHours, specifier: "%.1f")h")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(height: 4)

                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(viewModel.screenTimeHours > 4 ? Color.orange.gradient : Color.green.gradient)
                                                .frame(width: geometry.size.width * CGFloat(min(viewModel.screenTimeHours / 8.0, 1.0)), height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // Personal Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Details")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            if let birthday = viewModel.user.birthday {
                                PersonalityRow(
                                    label: "Birthday",
                                    value: birthday.formatted(date: .abbreviated, time: .omitted)
                                )
                                Divider().padding(.leading, 16)
                            }

                            if let sun = viewModel.user.zodiacSun {
                                PersonalityRow(label: "Sun Sign", value: "\(sun.symbol) \(sun.rawValue)")
                                Divider().padding(.leading, 16)
                            }

                            if let moon = viewModel.user.zodiacMoon {
                                PersonalityRow(label: "Moon Sign", value: "\(moon.symbol) \(moon.rawValue)")
                                Divider().padding(.leading, 16)
                            }

                            if let rising = viewModel.user.zodiacRising {
                                PersonalityRow(label: "Rising Sign", value: "\(rising.symbol) \(rising.rawValue)")
                                Divider().padding(.leading, 16)
                            }

                            if let mbti = viewModel.user.myersBriggs {
                                PersonalityRow(label: "Myers-Briggs", value: mbti.rawValue)
                                Divider().padding(.leading, 16)
                            }

                            if let enneagram = viewModel.user.enneagram {
                                PersonalityRow(label: "Enneagram", value: enneagram.rawValue)
                                Divider().padding(.leading, 16)
                            }

                            if let phase = viewModel.user.currentCyclePhase {
                                PersonalityRow(label: "Cycle Phase", value: "\(phase.emoji) \(phase.rawValue)")
                                Divider().padding(.leading, 16)
                            }

                            if let startDate = viewModel.user.cycleStartDate {
                                PersonalityRow(
                                    label: "Cycle Day",
                                    value: "Day \(Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0 + 1)"
                                )
                            }
                        }
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }

                    // Daily Digest - Vertical Story Modals
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Daily Digest")
                                .font(.headline)
                            Spacer()
                            Button {
                                // Show all stories
                            } label: {
                                Text("More")
                                    .font(.subheadline)
                                    .foregroundColor(.amberBlue)
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(.amberBlue)
                            }
                        }
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.dailyDigests) { digest in
                                    StoryCard(digest: digest)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Personality Tests Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enhance Your Profile")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            // Daily Test - Full Width Card
                            DailyTestCard()
                                .padding(.horizontal)

                            // Other Tests Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                PersonalityTestCard(
                                    title: "Big Five",
                                    icon: "chart.bar.fill",
                                    color: .blue,
                                    isCompleted: false
                                )

                                PersonalityTestCard(
                                    title: "Myers-Briggs",
                                    icon: "person.fill",
                                    color: .purple,
                                    isCompleted: viewModel.user.myersBriggs != nil
                                )

                                PersonalityTestCard(
                                    title: "Enneagram",
                                    icon: "circle.grid.3x3.fill",
                                    color: .green,
                                    isCompleted: viewModel.user.enneagram != nil
                                )

                                PersonalityTestCard(
                                    title: "Love Language",
                                    icon: "heart.fill",
                                    color: .pink,
                                    isCompleted: false
                                )

                                PersonalityTestCard(
                                    title: "Attachment Style",
                                    icon: "link.circle.fill",
                                    color: .orange,
                                    isCompleted: false
                                )

                                PersonalityTestCard(
                                    title: "Zodiac Signs",
                                    icon: "sparkles",
                                    color: .indigo,
                                    isCompleted: viewModel.user.zodiacSun != nil && viewModel.user.zodiacMoon != nil && viewModel.user.zodiacRising != nil
                                )
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Data Sources Section (moved to bottom)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Connected Apps & Permissions")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            // Apple Integrations
                            DataSourceRow(
                                icon: "apple.logo",
                                title: "Apple Contacts",
                                subtitle: "Access to your contacts",
                                isConnected: $viewModel.appleContactsConnected,
                                color: .gray
                            )

                            DataSourceRow(
                                icon: "heart.fill",
                                title: "Apple Health",
                                subtitle: "Activity, sleep, and health data",
                                isConnected: $viewModel.appleHealthConnected,
                                color: .pink
                            )

                            DataSourceRow(
                                icon: "location.fill",
                                title: "Location Services",
                                subtitle: "Background location tracking",
                                isConnected: $viewModel.locationServicesConnected,
                                color: .blue
                            )

                            DataSourceRow(
                                icon: "app.connected.to.app.below.fill",
                                title: "Activity from Other Apps",
                                subtitle: "Cross-app activity tracking",
                                isConnected: $viewModel.activityTrackingConnected,
                                color: .purple
                            )

                            // Google Integrations
                            DataSourceRow(
                                icon: "calendar",
                                title: "Google Calendar",
                                subtitle: "Events and scheduling",
                                isConnected: $viewModel.googleCalendarConnected,
                                color: .red
                            )

                            DataSourceRow(
                                icon: "envelope.fill",
                                title: "Gmail",
                                subtitle: "Email communications",
                                isConnected: $viewModel.gmailConnected,
                                color: .red
                            )

                            // Meta Integrations
                            DataSourceRow(
                                icon: "camera.fill",
                                title: "Instagram",
                                subtitle: "Posts, stories, and messages",
                                isConnected: $viewModel.instagramConnected,
                                color: .pink
                            )

                            DataSourceRow(
                                icon: "person.3.fill",
                                title: "Facebook",
                                subtitle: "Social graph and activity",
                                isConnected: $viewModel.facebookConnected,
                                color: .blue
                            )

                            // Other Social
                            DataSourceRow(
                                icon: "music.note",
                                title: "TikTok",
                                subtitle: "Videos and interactions",
                                isConnected: $viewModel.tiktokConnected,
                                color: .black
                            )

                            DataSourceRow(
                                icon: "briefcase.fill",
                                title: "LinkedIn",
                                subtitle: "Professional network",
                                isConnected: $viewModel.linkedInConnected,
                                color: .blue
                            )

                            DataSourceRow(
                                icon: "bird.fill",
                                title: "X (Twitter)",
                                subtitle: "Tweets and social activity",
                                isConnected: $viewModel.xConnected,
                                color: .black
                            )

                            DataSourceRow(
                                icon: "newspaper.fill",
                                title: "Substack",
                                subtitle: "Reading and subscriptions",
                                isConnected: $viewModel.substackConnected,
                                color: .orange
                            )

                            // AI Assistants
                            DataSourceRow(
                                icon: "sparkles",
                                title: "Claude",
                                subtitle: "AI conversations",
                                isConnected: $viewModel.claudeConnected,
                                color: .orange
                            )

                            DataSourceRow(
                                icon: "bubble.left.and.bubble.right.fill",
                                title: "ChatGPT",
                                subtitle: "AI interactions",
                                isConnected: $viewModel.chatGPTConnected,
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Sign Out
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                        authViewModel.logout()
                    }) {
                        Text("Sign Out")
                            .font(.body)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .padding(.bottom, 140) // Space for tab bar
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.amberBlue)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(userName: viewModel.user.name)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
            }
            .overlay {
                if viewModel.isProfileLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .tint(.amberBlue)
                            .scaleEffect(1.2)
                    }
                }
            }
        }
    }
}
