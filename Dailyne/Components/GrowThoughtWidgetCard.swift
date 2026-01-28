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

    var body: some View {
        SoftCard {
            Button {
                onOpen()
            } label: {
                HStack(spacing: 14) {
                    plantView
                        .frame(width: 56, height: 56)

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
        }
    }

    private var plantView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.55))

            Text(emojiForStage(store.state.stage))
                .font(.system(size: 28))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var needChip: some View {
        let (title, icon) = needLabel(store.state.todayNeed)

        return HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
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

    private func emojiForStage(_ stage: PlantStage) -> String {
        switch stage {
        case .seed: return "🌰"
        case .sprout: return "🌱"
        case .small: return "🪴"
        case .leafy: return "🌿"
        case .bloom: return "🌸"
        }
    }

    private func needLabel(_ need: PlantNeed) -> (String, String) {
        switch need {
        case .water: return ("Water", "drop.fill")
        case .sun: return ("Sun", "sun.max.fill")
        case .weeds: return ("Weeds", "leaf.fill")
        case .none: return ("Done", "sparkles")
        }
    }
}
