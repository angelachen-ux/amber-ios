//
//  DailySnapshotView.swift
//  AmberApp
//
//  Created on 2026-03-26.
//

import SwiftUI

// MARK: - Data Models

private struct HealthMetric: Identifiable {
    let id = UUID()
    let icon: String
    let value: String
    let label: String
    let color: Color
}

private struct PersonCard: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let context: String
    let action: String
    let avatarColor: Color
}

private struct ScheduleEvent: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    let subtitle: String?
    let dotColor: Color
}

private struct RecentLocation: Identifiable {
    let id = UUID()
    let name: String
}

// MARK: - Daily Snapshot View

struct DailySnapshotView: View {

    // MARK: - Sample Data

    private let healthMetrics: [HealthMetric] = [
        HealthMetric(icon: "moon.fill",     value: "7.2h",  label: "Sleep",    color: Color(hex: "6C5CE7")),
        HealthMetric(icon: "figure.walk",   value: "6,840", label: "Steps",    color: .healthPhysical),
        HealthMetric(icon: "heart.fill",    value: "62",    label: "Heart",    color: .healthEmotional),
        HealthMetric(icon: "iphone",        value: "2.4h",  label: "Screen",   color: .amberWarm),
        HealthMetric(icon: "flame.fill",    value: "1,850", label: "Calories", color: .amberWarm),
        HealthMetric(icon: "brain",         value: "12m",   label: "Mindful",  color: .healthSpiritual),
    ]

    private let people: [PersonCard] = [
        PersonCard(name: "Angela",  initials: "AC", context: "Design review at 3pm",            action: "Message", avatarColor: .amberGold),
        PersonCard(name: "Mom",     initials: "CT", context: "Haven't called in 8 days",        action: "Call",    avatarColor: .healthEmotional),
        PersonCard(name: "Victor",  initials: "VS", context: "Product sync at 5pm",             action: "Message", avatarColor: .healthSocial),
        PersonCard(name: "Kaitlyn", initials: "KM", context: "Check in -- last msg 5 days ago", action: "Message", avatarColor: .healthSpiritual),
        PersonCard(name: "Rohan",   initials: "RP", context: "Birthday tomorrow!",              action: "Message", avatarColor: .amberHoney),
    ]

    private let schedule: [ScheduleEvent] = [
        ScheduleEvent(time: "9:00 AM",  title: "Morning workout",             subtitle: nil,                  dotColor: .healthPhysical),
        ScheduleEvent(time: "11:00 AM", title: "MAYA standup",                 subtitle: nil,                  dotColor: .amberWarm),
        ScheduleEvent(time: "1:00 PM",  title: "Lunch with Dev",              subtitle: "Sweetgreen on Clark", dotColor: .healthSocial),
        ScheduleEvent(time: "3:00 PM",  title: "Design review with Angela",   subtitle: "Figma walkthrough",  dotColor: .amberGold),
        ScheduleEvent(time: "5:00 PM",  title: "Product sync with Victor",    subtitle: nil,                  dotColor: .amberPrimary),
    ]

    private let recentLocations: [RecentLocation] = [
        RecentLocation(name: "USC Campus"),
        RecentLocation(name: "Sweetgreen"),
        RecentLocation(name: "Home"),
    ]

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning, Sagar"
        case 12..<17: return "Good afternoon, Sagar"
        default:      return "Good evening, Sagar"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Health metrics
                healthSection

                // Relationships
                relationshipsSection

                // Location
                locationSection

                // Timeline
                timelineSection
            }
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.amberLargeTitle)
                .foregroundStyle(Color.amberText)

            Text(dateString)
                .font(.amberSubheadline)
                .foregroundStyle(Color.amberSecondaryText)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Health Section

    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Health")
                .amberSectionHeader()
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                ForEach(healthMetrics) { metric in
                    metricCard(metric)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func metricCard(_ metric: HealthMetric) -> some View {
        VStack(spacing: 8) {
            Image(systemName: metric.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(metric.color)

            Text(metric.value)
                .font(.amberTitle3)
                .bold()
                .foregroundStyle(Color.amberText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(metric.label)
                .font(.amberCaption)
                .foregroundStyle(Color.amberSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Relationships Section

    private var relationshipsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Relationships")
                .amberSectionHeader()
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(people) { person in
                        personCardView(person)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func personCardView(_ person: PersonCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Avatar
            InitialsAvatar(name: "\(person.initials.prefix(1)) \(person.initials.suffix(1))", size: 36)

            // Name
            Text(person.name)
                .font(.amberCaption)
                .foregroundStyle(Color.amberText)
                .lineLimit(1)

            // Context
            Text(person.context)
                .font(.amberCaption2)
                .foregroundStyle(Color.amberSecondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // Action button
            Button(action: {}) {
                Text(person.action)
                    .font(.amberCaption)
                    .foregroundStyle(Color.amberBlue)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 120)
        .padding(12)
        .liquidGlassCard(cornerRadius: 12)
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Location")
                .amberSectionHeader()
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 12) {
                // Current location
                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.amberWarm)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Los Angeles, CA")
                            .font(.amberBody)
                            .foregroundStyle(Color.amberText)

                        Text("Since 9:42 AM")
                            .font(.amberCaption)
                            .foregroundStyle(Color.amberSecondaryText)
                    }

                    Spacer()
                }

                // Recent locations chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recentLocations) { location in
                            HStack(spacing: 4) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 10, weight: .medium))
                                Text(location.name)
                                    .font(.amberCaption)
                            }
                            .foregroundStyle(Color.amberSecondaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.regularMaterial, in: Capsule())
                        }
                    }
                }
            }
            .padding(16)
            .liquidGlassCard()
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Timeline Section

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Timeline")
                .amberSectionHeader()
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(schedule.enumerated()), id: \.element.id) { index, event in
                    timelineRow(event: event, isLast: index == schedule.count - 1)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func timelineRow(event: ScheduleEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            Text(event.time)
                .font(.amberCaption)
                .foregroundStyle(Color.amberSecondaryText)
                .frame(width: 64, alignment: .trailing)

            // Dot + vertical line
            VStack(spacing: 0) {
                Circle()
                    .fill(event.dotColor)
                    .frame(width: 8, height: 8)

                // Continuous vertical line — never ends, suggesting infinite timeline
                Rectangle()
                    .fill(Color.amberSecondaryText.opacity(0.3))
                    .frame(width: 1)
            }

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.amberBody)
                    .foregroundStyle(Color.amberText)

                if let subtitle = event.subtitle {
                    Text(subtitle)
                        .font(.amberCaption)
                        .foregroundStyle(Color.amberSecondaryText)
                }
            }

            Spacer()
        }
        .padding(.bottom, isLast ? 0 : 16)
    }
}

// MARK: - Preview

#Preview {
    DailySnapshotView()
}
