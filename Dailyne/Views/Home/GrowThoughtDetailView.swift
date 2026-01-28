//
//  GrowThoughtDetailView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import SwiftUI

struct GrowThoughtDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: GrowThoughtStore

    @State private var intentionText: String = ""
    @State private var waterText: String = ""
    @State private var weedsText: String = ""

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.95)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {

                    HStack {
                        Text("Grow a Thought")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.black.opacity(0.85))
                        Spacer()
                        Button("Close") { dismiss() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.55))
                    }

                    SoftCard {
                        HStack(spacing: 14) {
                            plantBig
                            VStack(alignment: .leading, spacing: 6) {
                                Text("You’re growing")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.45))

                                Text(store.state.intention)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.85))

                                Text("Stage: \(stageLabel(store.state.stage))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.50))
                            }
                            Spacer()
                        }
                    }

                    // Intention (edit)
                    SoftCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Change intention (optional)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.55))

                            TextField("Peace / Confidence / Discipline...", text: $intentionText)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                            Button {
                                store.setIntention(intentionText)
                                intentionText = ""
                            } label: {
                                Text("Save intention")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.75))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.65))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Actions
                    SoftCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today’s care")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.55))

                            waterBlock
                            sunBlock
                            weedsBlock
                        }
                    }

                    Spacer(minLength: 22)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .onAppear {
            store.ensureToday()
            intentionText = ""
            waterText = store.state.waterNote
            weedsText = store.state.weedsNote
        }
    }

    private var plantBig: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.55))

            Text(stageEmoji(store.state.stage))
                .font(.system(size: 44))
        }
        .frame(width: 82, height: 82)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var waterBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Color.black.opacity(0.45))
                Text("Water")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                Spacer()
                if store.state.didWater {
                    Text("Done")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.45))
                }
            }

            if !store.state.didWater {
                TextField("What supported you today? (1 line)", text: $waterText)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    store.water(note: waterText)
                } label: {
                    Text("Water plant")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var sunBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Color.black.opacity(0.45))
                Text("Sunlight")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                Spacer()
                if store.state.didSun {
                    Text("Done")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.45))
                }
            }

            if !store.state.didSun {
                Text("Take one slow breath. That’s enough.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.55))

                Button {
                    store.sun()
                } label: {
                    Text("Give sunlight")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var weedsBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.black.opacity(0.45))
                Text("Remove weeds")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                Spacer()
                if store.state.didWeeds {
                    Text("Done")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.45))
                }
            }

            if !store.state.didWeeds {
                TextField("What drained you? (optional)", text: $weedsText)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    store.weeds(note: weedsText)
                } label: {
                    Text("Remove weeds")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func stageEmoji(_ stage: PlantStage) -> String {
        switch stage {
        case .seed: return "🌰"
        case .sprout: return "🌱"
        case .small: return "🪴"
        case .leafy: return "🌿"
        case .bloom: return "🌸"
        }
    }

    private func stageLabel(_ stage: PlantStage) -> String {
        switch stage {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .small: return "Growing"
        case .leafy: return "Leafy"
        case .bloom: return "Bloom"
        }
    }
}
