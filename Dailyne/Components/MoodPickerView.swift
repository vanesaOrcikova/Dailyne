//
//  MoodPickerView.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

enum MoodType {
    case veryHappy
    case happy
    case neutral
    case sad
}

struct MoodPickerView: View {

    @Binding var selectedIndex: Int

    private let moods: [MoodType] = [.veryHappy, .happy, .neutral, .sad]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(moods.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                } label: {
                    MoodFaceView(
                        type: moods[index],
                        isSelected: selectedIndex == index
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct MoodFaceView: View {

    let type: MoodType
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(faceColor)
                .frame(width: 58, height: 58)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(isSelected ? 0.35 : 0.25), lineWidth: 1.5)
                )
                .shadow(color: isSelected ? Color.black.opacity(0.08) : .clear,
                        radius: 4, y: 2)

            VStack(spacing: 8) {

                // oči – rovnaké, jemne výraznejšie
                HStack(spacing: 14) {
                    Circle().frame(width: 4, height: 4)
                    Circle().frame(width: 4, height: 4)
                }
                .foregroundColor(.black)
                .opacity(0.85)
                .offset(y: 3)

                // ústa
                mouth
                    .stroke(
                        Color.black.opacity(isSelected ? 0.9 : 0.8),
                        style: StrokeStyle(lineWidth: 1.9, lineCap: .round)
                    )
                    .frame(width: 26, height: 14)
            }
        }
        .scaleEffect(isSelected ? 1.08 : 1.0)
    }

    // výraznejšie farby
    private var faceColor: Color {
        if isSelected {
            return Color(red: 0.98, green: 0.80, blue: 0.80)
        } else {
            return Color(red: 0.96, green: 0.86, blue: 0.86)
        }
    }

    // väčší rozdiel medzi 1. a 2.
    private var mouth: Path {
        var path = Path()

        switch type {
        case .veryHappy:
            // NAJVÄČŠÍ úsmev
            path.move(to: CGPoint(x: 2, y: 6))
            path.addQuadCurve(
                to: CGPoint(x: 24, y: 6),
                control: CGPoint(x: 13, y: 18)
            )

        case .happy:
            // menší, ale stále jasne veselý
            path.move(to: CGPoint(x: 3, y: 7))
            path.addQuadCurve(
                to: CGPoint(x: 23, y: 7),
                control: CGPoint(x: 13, y: 12)
            )

        case .neutral:
            path.move(to: CGPoint(x: 4, y: 7))
            path.addLine(to: CGPoint(x: 22, y: 7))

        case .sad:
            path.move(to: CGPoint(x: 4, y: 9))
            path.addQuadCurve(
                to: CGPoint(x: 22, y: 9),
                control: CGPoint(x: 13, y: 2)
            )
        }

        return path
    }
}

#Preview {
    MoodPickerView(selectedIndex: .constant(0))
        .padding()
        .background(Color(red: 0.98, green: 0.94, blue: 0.95))
}
