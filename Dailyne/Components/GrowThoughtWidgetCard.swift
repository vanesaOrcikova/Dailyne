//
//  GrowThoughtWidgetCard.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import SwiftUI

struct GrowThoughtWidgetCard: View {
    @ObservedObject var store: GrowThoughtStore
    let onOpen: () -> Void

    @State private var sunPulse: Bool = false

    var body: some View {
        SoftCard {
            Button { onOpen() } label: {
                HStack(spacing: 14) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.55))

                        // 🌞 pulzujúce slnko (len keď dnes chýba sun)
                        if store.state.todayNeed == .sun {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.35))
                                .offset(x: 14, y: -14)
                                .scaleEffect(sunPulse ? 1.08 : 0.95)
                                .opacity(sunPulse ? 0.9 : 0.55)
                        }

                        Text(plantEmoji())
                            .font(.system(size: plantSize()))
                    }
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Grow a Thought")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.85))
                            Spacer()
                            needChip
                        }

                        Text("You’re growing: \(store.state.intention)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.60))
                            .lineLimit(1)

                        Text(store.completionText())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            store.ensureToday()
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                sunPulse = true
            }
        }
    }

    private var needChip: some View {
        let (title, icon) = needLabel(store.state.todayNeed)

        return HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 12, weight: .semibold))
            Text(title).font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(Color.black.opacity(0.55))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private func needLabel(_ need: PlantNeed) -> (String, String) {
        switch need {
        case .water: return ("Water", "drop.fill")
        case .sun: return ("Sun", "sun.max.fill")
        case .weeds: return ("Weeds", "leaf.fill")
        case .none: return ("Done", "sparkles")
        }
    }

    private func plantEmoji() -> String {
        let flower = store.state.flower?.emoji ?? "🌱"
        switch store.state.stage {
        case .seed: return "🌰"
        case .sprout: return "🌱"
        case .small: return "🪴"
        case .leafy: return "🌿"
        case .bloom: return flower
        }
    }

    private func plantSize() -> CGFloat {
        switch store.state.stage {
        case .seed: return 22
        case .sprout: return 26
        case .small: return 30
        case .leafy: return 32
        case .bloom: return 34
        }
    }
}
