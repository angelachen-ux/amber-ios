//
//  AmberAIView.swift
//  AmberApp
//
//  Center tab — network visualization with a clean AI interface.
//

import SwiftUI

// MARK: - Node Model

struct NetworkNode: Identifiable {
    let id = UUID()
    let name: String
    let radius: CGFloat
    let baseAngle: CGFloat
    let distance: CGFloat
    let color: Color
    var connections: [Int]
}

// MARK: - Explore Card Model

private struct ExploreCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - AmberAIView

struct AmberAIView: View {
    @State var queryText = ""
    @State var isQuerying = false
    @FocusState var isInputFocused: Bool

    // Animation
    @State private var breathePhase: CGFloat = 0
    @State private var appeared: Bool = false

    // Sample network nodes
    private let nodes: [NetworkNode] = [
        NetworkNode(name: "Angela",   radius: 10, baseAngle: 0.4,   distance: 90,  color: .healthSocial,       connections: [1]),
        NetworkNode(name: "Kaitlyn",  radius: 9,  baseAngle: 0.85,  distance: 95,  color: .healthIntellectual, connections: [0]),
        NetworkNode(name: "Victor",   radius: 8,  baseAngle: 1.35,  distance: 115, color: .amberGold,          connections: [3]),
        NetworkNode(name: "Michelle", radius: 7,  baseAngle: 1.85,  distance: 110, color: .healthEmotional,    connections: [2]),
        NetworkNode(name: "Mom",      radius: 11, baseAngle: 2.5,   distance: 85,  color: .healthSpiritual,    connections: []),
        NetworkNode(name: "Dev",      radius: 7,  baseAngle: 3.3,   distance: 135, color: .healthPhysical,     connections: []),
        NetworkNode(name: "Rohan",    radius: 8,  baseAngle: 4.2,   distance: 110, color: .amberWarm,          connections: [7]),
        NetworkNode(name: "Priya",    radius: 6,  baseAngle: 5.2,   distance: 130, color: .healthFinancial,    connections: [6]),
    ]

    // Suggestion chips
    private let suggestions = [
        "Who should I reconnect with?",
        "Show me my USC network",
        "Family tree",
        "Find friends nearby",
        "What should I remember about Angela?",
    ]

    // Explore cards (kept for compatibility)
    private let exploreCards: [ExploreCard] = [
        ExploreCard(icon: "tree",           title: "Family Tree",        description: "Map your family connections",  color: .healthSpiritual),
        ExploreCard(icon: "location",       title: "Find Friends",       description: "See who's nearby",             color: .healthSocial),
        ExploreCard(icon: "chart.bar.fill", title: "Network Strength",   description: "Your relationship health",     color: .amberGold),
        ExploreCard(icon: "person.2",       title: "Mutual Connections", description: "People you both know",         color: .amberWarm),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Network visualization
                        networkVisualization
                            .frame(height: UIScreen.main.bounds.height * 0.45)

                        // Suggestion chips
                        suggestionChips
                            .padding(.top, 12)

                        Spacer(minLength: 160)
                    }
                }

                // Input bar pinned to bottom
                VStack {
                    Spacer()
                    NetworkInputBar(inputText: $queryText, isInputFocused: $isInputFocused)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Amber")
                        .font(.amberHeadline)
                        .foregroundStyle(Color.amberText)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appeared = true
                }
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    breathePhase += 1
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Network Visualization

    private var networkVisualization: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Hub-spoke connection lines
                Canvas { context, size in
                    let cx = size.width / 2
                    let cy = size.height / 2
                    let centerPt = CGPoint(x: cx, y: cy)
                    let positions = computePositions(center: centerPt)

                    for pos in positions {
                        var path = Path()
                        path.move(to: centerPt)
                        path.addLine(to: pos)
                        context.stroke(
                            path,
                            with: .color(Color.glassStroke),
                            lineWidth: 0.5
                        )
                    }
                }
                .allowsHitTesting(false)

                // Satellite nodes
                ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                    let pos = positionFor(index: index, center: center)

                    VStack(spacing: 4) {
                        Circle()
                            .fill(node.color)
                            .frame(width: 16, height: 16)

                        Text(node.name)
                            .font(.amberCaption)
                            .foregroundStyle(Color.amberSecondaryText)
                    }
                    .position(pos)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.75)
                            .delay(0.15 + Double(index) * 0.06),
                        value: appeared
                    )
                }

                // Central "You" node
                ZStack {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 44, height: 44)

                    Text("You")
                        .font(.amberHeadline)
                }
                .position(center)
                .scaleEffect(appeared ? 1 : 0.1)
                .opacity(appeared ? 1 : 0)
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.75),
                    value: appeared
                )
            }
        }
    }

    // MARK: - Suggestion Chips

    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        queryText = suggestion
                    } label: {
                        Text(suggestion)
                            .font(.amberBody)
                            .foregroundStyle(Color.amberText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.regularMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Position Helpers

    private func positionFor(index: Int, center: CGPoint) -> CGPoint {
        let node = nodes[index]
        let drift = sin(breathePhase * .pi * 2 + node.baseAngle * 2) * 4
        let dist = node.distance + drift
        let wobble = sin(breathePhase * .pi * 2 * 0.7 + CGFloat(index)) * 0.03
        let angle = node.baseAngle + wobble
        return CGPoint(
            x: center.x + cos(angle) * dist,
            y: center.y + sin(angle) * dist
        )
    }

    private func computePositions(center: CGPoint) -> [CGPoint] {
        (0..<nodes.count).map { positionFor(index: $0, center: center) }
    }
}

// MARK: - Preview

#Preview {
    AmberAIView()
        .preferredColorScheme(.dark)
}
