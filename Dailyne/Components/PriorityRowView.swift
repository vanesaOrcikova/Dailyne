//
//  PriorityRowView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI

struct PriorityRowView: View {

    @Binding var item: PriorityItem

    var body: some View {
        HStack(spacing: 10) {

            Button {
                item.isDone.toggle()
            } label: {
                Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.85))
                .strikethrough(item.isDone)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PriorityRowView(item: .constant(PriorityItem(title: "Go for a walk")))
        .padding()
        .background(Color.white.opacity(0.7))
}

