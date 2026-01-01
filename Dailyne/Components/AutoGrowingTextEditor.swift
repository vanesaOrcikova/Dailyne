//
//  AutoGrowingTextEditor.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 29/12/2025.
//

import SwiftUI

struct AutoGrowingTextEditor: View {

    @Binding var text: String
    let placeholder: String

    // nastaviteľné
    let minLines: Int = 2          // ✅ default 2 riadky
    let maxLines: Int = 5         // aby nerástlo donekonečna

    // interné
    @State private var height: CGFloat = 0

    // približná výška jedného riadku pre .body (funguje fajn v praxi)
    private let lineHeight: CGFloat = 20

    var body: some View {
        ZStack(alignment: .topLeading) {

            // placeholder vnútri
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }

            TextEditor(text: $text)
                .frame(height: currentHeight)
                .padding(10)
                .background(measurer)
        }
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    // Výška podľa riadkov (rast po riadkoch, nie po písmenách)
    private var currentHeight: CGFloat {
        let minH = CGFloat(minLines) * lineHeight + 24 // padding "od oka"
        let maxH = CGFloat(maxLines) * lineHeight + 24

        // zaokrúhli na celé riadky
        let lines = max(1, Int(ceil(height / lineHeight)))
        let snapped = CGFloat(lines) * lineHeight + 24

        return min(max(snapped, minH), maxH)
    }

    // meranie výšky textu (skryté)
    private var measurer: some View {
        Text(text.isEmpty ? " " : text)
            .font(.body)
            .lineSpacing(0)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundColor(.clear)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { height = geo.size.height }
                        .onChange(of: text) { _ in
                            height = geo.size.height
                        }
                }
            )
    }
}

