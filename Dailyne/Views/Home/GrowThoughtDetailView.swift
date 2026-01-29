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

    @State private var showPickFlower: Bool = false
    @State private var intentionText: String = ""

    @State private var traitText: String = ""
    @State private var traitPop: Bool = false

    @State private var sunOffset: CGSize = .zero
    @State private var cloudOffset: CGSize = .zero

    @State private var isRaining: Bool = false

    @State private var weedsLeft: Int = 3
    @State private var weed1: Bool = true
    @State private var weed2: Bool = true
    @State private var weed3: Bool = true

    @State private var plantGlow: Bool = false

    var body: some View {
        ZStack {
            // ✅ full background (no white panel)
            LinearGradient(
                colors: [
                    Color(red: 0.86, green: 0.93, blue: 0.99), // sky
                    Color(red: 0.86, green: 0.95, blue: 0.86)  // grass
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                topBar
                    .padding(.top, 18)

                playground // ✅ no card, no inner rectangle

                if !traitText.isEmpty {
                    traitBanner
                        .padding(.horizontal, 16)
                }

                Spacer()
            }
        }
        .onAppear {
            store.ensureToday()
            showPickFlower = store.needsOnboarding
            intentionText = store.state.intention

            if store.state.weedsAppearToday == false || store.state.didWeeds {
                weedsLeft = 0
                weed1 = false; weed2 = false; weed3 = false
            } else {
                weedsLeft = 3
                weed1 = true; weed2 = true; weed3 = true
            }
        }
        .sheet(isPresented: $showPickFlower) {
            FlowerPickerSheet(
                selected: store.state.flower,
                intention: $intentionText,
                onPick: { flower in
                    store.pickFlower(flower, intention: intentionText)
                    showPickFlower = false
                }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Grow a Thought")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.85))

                Text("You’re growing: \(store.state.intention)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.55))
            }
            

            Spacer()

            Button("Close") { dismiss() }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.60))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Playground (no white panel)

    private var playground: some View {
        ZStack {
            // ✅ optional: very subtle “glass” highlight only, not a box
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.18))
                .frame(height: 460)
                .padding(.horizontal, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                        .padding(.horizontal, 14)
                )

            // ✅ plant drop target glow (invisible)
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.clear)
                .frame(width: 280, height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.black.opacity(plantGlow ? 0.12 : 0.0), lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.2), value: plantGlow)
                .offset(y: 60) // target area lower

            // plant + “soil” (NO pot frame)
            VStack(spacing: 0) {
                Spacer().frame(height: 205)

                ZStack(alignment: .bottom) {

                    // ✅ rastlinka
                    Text(stageEmoji())
                        .font(.system(size: 66))
                        .offset(y: 6) // jemne dole

                    // ✅ kvetináč (hnedý, vyšší)
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(red: 0.63, green: 0.43, blue: 0.28).opacity(0.95))
                            .frame(width: 150, height: 68)

                        // horný okraj kvetináča
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.55, green: 0.36, blue: 0.22).opacity(0.95))
                            .frame(width: 160, height: 18)
                            .offset(y: -26)

                        // jemný highlight
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 120, height: 46)
                            .offset(x: -8, y: 6)
                    }
                    .offset(y: 44) // ✅ kvetináč vyššie (aby rastlina vyzerala zasadená)
                }
                .offset(y: 50)

                Spacer()

                Text(store.completionText())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.50))
                    .padding(.bottom, 16)
            }
            .frame(height: 460)
            .padding(.horizontal, 14)

            // ✅ always visible cloud (left) & sun (right)
            draggableCloud
            draggableSun

            // rain overlay (long)
            if isRaining {
                RainOverlay()
                    .transition(.opacity)
                    .offset(y: 120) // rain falls lower
            }

            // weeds appear only sometimes
            if store.state.weedsAppearToday && !store.state.didWeeds {
                weedsOverlay
            }
        }
    }

    // MARK: - Draggable sun

    private var draggableSun: some View {
        let isDone = store.state.didSun

        return Text("☀️")
            .font(.system(size: 56))
            .opacity(isDone ? 0.35 : 1.0)
            .offset(x: 140 + sunOffset.width, y: -110 + sunOffset.height)
            .allowsHitTesting(!isDone)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sunOffset = value.translation
                        plantGlow = isNearPlant(value.translation, origin: CGPoint(x: 140, y: -110))
                    }
                    .onEnded { _ in
                        let success = isNearPlant(sunOffset, origin: CGPoint(x: 140, y: -110))
                        plantGlow = false

                        if success {
                            store.sun()
                            popTrait(store.state.sunTrait)
                            withAnimation(.easeInOut(duration: 0.2)) { sunOffset = .zero }
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { sunOffset = .zero }
                        }
                    }
            )
    }

    // MARK: - Draggable cloud

    private var draggableCloud: some View {
        let isDone = store.state.didWater

        return Text("☁️")
            .font(.system(size: 54))
            .opacity(isDone ? 0.35 : 1.0)
            .offset(x: -140 + cloudOffset.width, y: -110 + cloudOffset.height)
            .allowsHitTesting(!isDone)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        cloudOffset = value.translation
                        plantGlow = isNearPlant(value.translation, origin: CGPoint(x: -140, y: -40))
                    }
                    .onEnded { _ in
                        let success = isNearPlant(cloudOffset, origin: CGPoint(x: -140, y: -40))
                        plantGlow = false

                        if success {
                            withAnimation(.easeInOut(duration: 0.15)) { isRaining = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeInOut(duration: 0.25)) { isRaining = false }
                            }

                            store.water(note: "")
                            popTrait(store.state.waterTrait)

                            withAnimation(.easeInOut(duration: 0.2)) { cloudOffset = .zero }
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { cloudOffset = .zero }
                        }
                    }
            )
    }

    // MARK: - Weeds

    private var weedsOverlay: some View {
        ZStack {
            if weed1 { weedView(x: -70, y: 210) { removeWeed(1) } }
            if weed2 { weedView(x: 0,   y: 230) { removeWeed(2) } }
            if weed3 { weedView(x: 70,  y: 212) { removeWeed(3) } }
        }
    }

    private func weedView(x: CGFloat, y: CGFloat, onTap: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                onTap()
            }
        } label: {
            Text("🍃")
                .font(.system(size: 22))
                .padding(8)
                .background(Color.white.opacity(0.45))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .offset(x: x, y: y)
    }

    private func removeWeed(_ index: Int) {
        if index == 1 { weed1 = false }
        if index == 2 { weed2 = false }
        if index == 3 { weed3 = false }
        weedsLeft -= 1

        if weedsLeft <= 0 {
            store.weeds(note: "")
            popTrait(store.state.weedsTrait)
        }
    }

    // MARK: - Trait banner

    private var traitBanner: some View {
        Text(traitText)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.70))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.50))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(traitPop ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: traitPop)
    }

    private func popTrait(_ text: String) {
        traitText = text
        traitPop = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { traitPop = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { traitPop = false }
    }

    // MARK: - Drop target

    private func isNearPlant(_ translation: CGSize, origin: CGPoint) -> Bool {
        let x = origin.x + translation.width
        let y = origin.y + translation.height

        // ✅ plant is lower now
        let target = CGPoint(x: 0, y: 210)

        let dx = x - target.x
        let dy = y - target.y
        let dist = sqrt(dx*dx + dy*dy)

        return dist < 140
    }

    private func stageEmoji() -> String {
        switch store.state.stage {
        case .seed: return "🌰"
        case .sprout: return "🌱"
        case .small: return "🪴"
        case .leafy: return "🌿"
        case .bloom: return store.state.flower?.emoji ?? "🌸"
        }
    }
}

// MARK: - Rain overlay (long + smooth)

private struct RainOverlay: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            ForEach(0..<26, id: \.self) { i in
                Capsule()
                    .fill(Color.black.opacity(0.10))
                    .frame(width: 2, height: 18)
                    .offset(x: CGFloat((i % 7) * 32) - 96, y: animate ? 220 : -70)
                    .opacity(animate ? 0.0 : 0.9)
                    .animation(.easeIn(duration: 1.8).delay(Double(i) * 0.03), value: animate)
            }
        }
        .onAppear {
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                animate = true
            }
        }
    }
}

// MARK: - Flower picker sheet

private struct FlowerPickerSheet: View {
    let selected: FlowerType?
    @Binding var intention: String
    let onPick: (FlowerType) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.95).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                Text("Pick your flower 🌸")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.85))

                Text("What do you want to grow in yourself?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.55))

                TextField("Peace / Confidence / Discipline…", text: $intention)
                    .textFieldStyle(.roundedBorder)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(FlowerType.allCases) { f in
                        Button { onPick(f) } label: {
                            VStack(spacing: 6) {
                                Text(f.emoji).font(.system(size: 26))
                                Text(f.title)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}
