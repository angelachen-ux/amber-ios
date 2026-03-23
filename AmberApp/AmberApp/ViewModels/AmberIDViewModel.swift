//
//  AmberIDViewModel.swift
//  Amber
//
//  Created on 2026-01-17.
//

import SwiftUI
import Combine

@MainActor
class AmberIDViewModel: ObservableObject {
    @Published var user: AmberUser = .placeholder
    @Published var stories: [AmberStory] = []
    @Published var dailyDigests: [DailyDigest] = []

    // Profile fields from API
    @Published var username: String = ""
    @Published var currentCity: String = ""
    @Published var almaMater: String = ""
    @Published var privacyTier: String = ""
    @Published var birthdayTime: String = ""
    @Published var birthLocation: String = ""
    @Published var isProfileLoading: Bool = true

    // Apple integrations
    @Published var appleContactsConnected = false
    @Published var appleHealthConnected = false
    @Published var locationServicesConnected = false
    @Published var activityTrackingConnected = false

    // Google integrations
    @Published var googleCalendarConnected = false
    @Published var gmailConnected = false

    // Meta integrations
    @Published var instagramConnected = false
    @Published var facebookConnected = false

    // Other social platforms
    @Published var tiktokConnected = false
    @Published var linkedInConnected = false
    @Published var xConnected = false
    @Published var substackConnected = false

    // AI assistants
    @Published var claudeConnected = false
    @Published var chatGPTConnected = false

    // Live tracking data
    @Published var moveProgress: Double = 0.75       // 75% of move goal
    @Published var exerciseProgress: Double = 0.60   // 60% of exercise goal
    @Published var standProgress: Double = 0.85      // 85% of stand goal
    @Published var sleepHours: Double = 7.2          // 7.2 hours of sleep
    @Published var screenTimeHours: Double = 3.5     // 3.5 hours screen time

    private let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private let dateOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        loadMockData()
        loadDailyDigests()
        startLiveTracking()
        loadProfile()
    }

    // MARK: - Profile Loading

    func loadProfile() {
        isProfileLoading = true

        Task {
            do {
                let profile = try await APIClient.shared.getProfile()
                applyProfileResponse(profile)
                isProfileLoading = false
            } catch {
                // Fall back to local UserDefaults data
                loadProfileFromLocal()
                isProfileLoading = false
            }
        }
    }

    private func applyProfileResponse(_ profile: ProfileResponse) {
        if let name = profile.displayName, !name.isEmpty {
            user.name = name
        }
        if let uname = profile.username {
            username = uname
        }
        if let birthdayStr = profile.birthday {
            if let date = iso8601Formatter.date(from: birthdayStr) {
                user.birthday = date
            } else if let date = dateOnlyFormatter.date(from: birthdayStr) {
                user.birthday = date
            }
        }
        if let city = profile.currentCity {
            currentCity = city
        }
        if let school = profile.almaMater {
            almaMater = school
        }
        if let privacy = profile.privacyTier {
            privacyTier = privacy
        }
        if let bTime = profile.birthdayTime {
            birthdayTime = bTime
        }
        if let bLocation = profile.birthLocation {
            birthLocation = bLocation
        }
        if let avatarUrl = profile.avatarUrl {
            user.avatarURL = avatarUrl
        }

        // Map horoscope from personality profiles
        if let personalityProfiles = profile.personalityProfiles {
            for pp in personalityProfiles where pp.profileType == "horoscope" {
                if let result = pp.result,
                   let sign = ZodiacSign.allCases.first(where: { $0.rawValue.lowercased() == result.sign.lowercased() }) {
                    user.zodiacSun = sign
                }
            }
        }
    }

    private func loadProfileFromLocal() {
        guard let data = UserDefaults.standard.data(forKey: "userProfileData"),
              let localProfile = try? JSONDecoder().decode(UserProfileData.self, from: data) else {
            return
        }

        if !localProfile.displayName.isEmpty {
            user.name = localProfile.displayName
        }
        if let birthday = localProfile.birthday {
            user.birthday = birthday
        }
        if !localProfile.currentCity.isEmpty {
            currentCity = localProfile.currentCity
        }
        if !localProfile.almaMater.isEmpty {
            almaMater = localProfile.almaMater
        }
        if !localProfile.privacyTier.isEmpty {
            privacyTier = localProfile.privacyTier
        }
        if let horoscope = localProfile.horoscopeSign {
            if let sign = ZodiacSign.allCases.first(where: { $0.rawValue.lowercased() == horoscope.name.lowercased() }) {
                user.zodiacSun = sign
            }
        }
    }

    // MARK: - Live Tracking

    private func startLiveTracking() {
        // In production, this would connect to HealthKit and Screen Time APIs
        // For now, we'll simulate realistic data
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateLiveData()
            }
        }
    }

    private func updateLiveData() {
        // Simulate gradual progress throughout the day
        moveProgress = min(moveProgress + 0.05, 1.0)
        exerciseProgress = min(exerciseProgress + 0.03, 1.0)
        standProgress = min(standProgress + 0.02, 1.0)
        sleepHours = Double.random(in: 6.5...8.5)
        screenTimeHours = min(screenTimeHours + 0.1, 8.0)
    }

    private func loadMockData() {
        stories = [
            AmberStory(
                emoji: "🧠",
                title: "Top 10%",
                subtitle: "Emotional intelligence",
                color: .healthEmotional
            ),
            AmberStory(
                emoji: "📈",
                title: "+23%",
                subtitle: "Network growth",
                color: .healthFinancial
            ),
            AmberStory(
                emoji: "🦉",
                title: "Wise Owl",
                subtitle: "Your spirit animal",
                color: .healthSpiritual
            )
        ]
    }

    private func loadDailyDigests() {
        dailyDigests = [
            DailyDigest(
                title: "Spiritual Health",
                subtitle: "Inner peace and purpose",
                icon: "sparkles",
                color: .healthSpiritual,
                score: 75,
                trend: 8,
                insight: "Your meditation practice is showing positive results. Consider deepening your mindfulness routine.",
                detailedInsight: "Your spiritual health has improved by 8% this week. Regular meditation and reflection practices are contributing to a stronger sense of inner peace. Your connections with close friends during deep conversations have also enriched your spiritual wellbeing. Consider exploring new spiritual practices or communities that align with your values."
            ),
            DailyDigest(
                title: "Emotional Health",
                subtitle: "Mood and feelings",
                icon: "heart.fill",
                color: .healthEmotional,
                score: 82,
                trend: 5,
                insight: "Strong emotional connections with Sarah and Michael are boosting your mood significantly.",
                detailedInsight: "Your emotional health is thriving. Recent interactions with close friends have provided strong emotional support. You're processing emotions effectively and maintaining healthy boundaries. Your journaling habit has helped you identify and work through challenging feelings. Keep nurturing these meaningful relationships and continue with your emotional wellness practices."
            ),
            DailyDigest(
                title: "Physical Health",
                subtitle: "Activity and fitness",
                icon: "figure.run",
                color: .healthPhysical,
                score: 68,
                trend: -3,
                insight: "Exercise frequency has decreased this week. Try scheduling morning workouts to build consistency.",
                detailedInsight: "Your physical health needs attention. While your sleep quality is good, exercise frequency has dropped by 3% this week. Your move goal completion is at 75%, but you're missing opportunities for more intense workouts. Consider joining a fitness class or finding a workout buddy to boost motivation. Small changes like taking the stairs or walking meetings can make a difference."
            ),
            DailyDigest(
                title: "Financial Health",
                subtitle: "Career and prosperity",
                icon: "dollarsign.circle.fill",
                color: .healthFinancial,
                score: 72,
                trend: 12,
                insight: "Professional networking has opened new opportunities. Your LinkedIn engagement is at an all-time high.",
                detailedInsight: "Your financial health is improving significantly. Recent networking efforts through LinkedIn have created new professional opportunities. The informational interview with Michael's colleague could lead to career advancement. Your professional network has grown by 15% this month, and you're being more strategic about relationship cultivation. Consider following up on pending opportunities and continue building authentic professional connections."
            ),
            DailyDigest(
                title: "Intellectual Health",
                subtitle: "Learning and growth",
                icon: "brain.head.profile",
                color: .healthIntellectual,
                score: 90,
                trend: 6,
                insight: "Your curiosity is thriving. Deep conversations and reading habits are keeping your mind sharp.",
                detailedInsight: "Excellent intellectual health! You're consistently engaging in stimulating conversations and challenging your perspectives. Your book club participation and podcast listening habits are expanding your knowledge base. Recent discussions about philosophy and technology have sparked new interests. The variety in your intellectual pursuits is creating a well-rounded cognitive foundation. Keep diversifying your learning sources."
            ),
            DailyDigest(
                title: "Social Health",
                subtitle: "Connections and community",
                icon: "person.3.fill",
                color: .healthSocial,
                score: 85,
                trend: 10,
                insight: "Your social circle is thriving. Consistent communication with your core group is paying off.",
                detailedInsight: "Outstanding social health! You've maintained a 30-day streak of meaningful interactions with your top 5 connections. Your response rate to messages has improved, and friends have noticed your increased presence. The balance between deep one-on-one conversations and group activities is optimal. However, consider reaching out to James soon - it's been 3 weeks since your last interaction. Overall, your social network is strong and supportive."
            )
        ]
    }
}
