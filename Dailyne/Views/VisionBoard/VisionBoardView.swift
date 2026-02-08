//
//  VisionBoardView.swift
//  SoftLifePlanner
//
//  Created by Vanesa Orcikova on 28/12/2025.
//

import SwiftUI
import PhotosUI

struct VisionBoardView: View {

    @StateObject private var store = VisionBoardStore()

    @State private var showAddCategory: Bool = false
    @State private var newCategoryText: String = ""

    @State private var pickerItem: PhotosPickerItem? = nil

    @State private var pendingMoveItem: VBItem? = nil
    @State private var pendingMoveFromCategoryId: UUID? = nil
    @State private var showMoveSheet: Bool = false

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.94, blue: 0.95)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    categoryChips
                    grid
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showAddCategory) {
            addCategorySheet
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showMoveSheet) {
            moveToCategorySheet
                .presentationDetents([.medium])
        }
        .onChange(of: pickerItem) { item in
            guard let item else { return }
            guard let catId = store.selectedCategoryId else { return }

            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        store.addPhoto(to: catId, imageData: data)
                    }
                }
            }
        }
    }

    // MARK: - Pinterest balance columns (nie podľa indexu)

    private func balancedColumns() -> (left: [VBItem], right: [VBItem]) {
        guard let cat = store.selectedCategory else { return ([], []) }

        var left: [VBItem] = []
        var right: [VBItem] = []
        var leftH: CGFloat = 0
        var rightH: CGFloat = 0

        for item in cat.items {
            let itemH: CGFloat = (item.layout == .portrait) ? 170 : 120

            if leftH <= rightH {
                left.append(item)
                leftH += itemH
            } else {
                right.append(item)
                rightH += itemH
            }
        }

        return (left, right)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Vision Board")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.85))

            Spacer()

            //  malé pridanie fotky (nekazí grid)
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            // pridanie kategórie
            Button {
                newCategoryText = ""
                showAddCategory = true
            } label: {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.75))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.categories) { cat in
                    let selected = (store.selectedCategoryId == cat.id)

                    Button {
                        store.selectedCategoryId = cat.id
                    } label: {
                        Text(cat.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(selected ? 0.85 : 0.55))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(selected ? 0.85 : 0.60))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Rename") {
                            newCategoryText = cat.title
                            showAddCategory = true
                        }
                        Button(role: .destructive) {
                            store.deleteCategory(id: cat.id)
                        } label: {
                            Text("Delete category")
                        }
                    }
                }

                Button {
                    newCategoryText = ""
                    showAddCategory = true
                } label: {
                    Text("Add +")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.55))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Grid (balanced)

    private var grid: some View {
        MasonryGrid(columns: 2, spacing: 8) {
            if let category = store.selectedCategory {
                ForEach(category.items) { item in
                    VisionFlipCard(store: store, categoryId: store.selectedCategoryId, item: item)
                        .contextMenu {
                            Button("Move to category…") {
                                pendingMoveItem = item
                                pendingMoveFromCategoryId = store.selectedCategoryId
                                showMoveSheet = true
                            }

                            Button(role: .destructive) {
                                guard let catId = store.selectedCategoryId else { return }
                                store.removeItem(categoryId: catId, itemId: item.id)
                            } label: {
                                Text("Remove photo")
                            }
                        }
                }
            }
        }
    }

    // MARK: - Sheets

    private var addCategorySheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Category")
                    .font(.system(size: 18, weight: .semibold))

                TextField("e.g. Travel, Glow up, Career", text: $newCategoryText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    store.addCategory(title: newCategoryText)
                    showAddCategory = false
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Add category")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { showAddCategory = false }
                }
            }
        }
    }

    private var moveToCategorySheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Move to…")
                    .font(.system(size: 18, weight: .semibold))

                ForEach(store.categories) { cat in
                    Button {
                        guard let item = pendingMoveItem,
                              let fromId = pendingMoveFromCategoryId else { return }
                        store.moveItem(itemId: item.id, from: fromId, to: cat.id)
                        showMoveSheet = false
                    } label: {
                        HStack {
                            Text(cat.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.8))
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)

                    Divider().opacity(0.12)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Move")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { showMoveSheet = false }
                }
            }
        }
    }
}

//
// MARK: - Flip card (small, in-grid)
//

private struct VisionFlipCard: View {
    @ObservedObject var store: VisionBoardStore
    let categoryId: UUID?
    let item: VBItem

    @State private var isFlipped: Bool = false
    @State private var notes: String = ""
    @State private var status: VBStatus = .inProgress

    private let r: CGFloat = 16

    private var h: CGFloat {
        item.layout == .portrait ? 160 : 115
    }

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .animation(.easeInOut(duration: 0.45), value: isFlipped)
        .onTapGesture {
            if !isFlipped {
                notes = item.notes
                status = item.status
            }
            withAnimation(.easeInOut(duration: 0.45)) {
                isFlipped.toggle()
            }
        }
    }

    private var front: some View {
        ZStack(alignment: .topTrailing) {

            if let img = store.loadImage(for: item) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(img.size.width / img.size.height, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: r))
            }

            // status badge
            Text(status == .achieved ? "✓" : (status == .inProgress ? "…" : "☆"))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.45))
                .frame(width: 24, height: 24)
                .background(Color.white.opacity(0.65))
                .clipShape(Circle())
                .padding(8)
        }
        .overlay(
            RoundedRectangle(cornerRadius: r)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 8) {

            Menu {
                ForEach(VBStatus.allCases, id: \.rawValue) { s in
                    Button(s.title) { status = s }
                }
            } label: {
                Text(status.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            TextEditor(text: $notes)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.75))
                .scrollContentBackground(.hidden)
                .frame(minHeight: 60, maxHeight: 90)
                .padding(8)
                .background(Color.white.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Save") {
                guard let catId = categoryId else { return }
                store.saveDetail(categoryId: catId, itemId: item.id, notes: notes, status: status)
                withAnimation(.easeInOut(duration: 0.4)) {
                    isFlipped = false
                }
            }
            .font(.system(size: 12, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(10)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: r))
    }
}

// MARK: - Pinterest / Masonry layout (iOS 16+)

private struct MasonryLayout: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 8

    struct Cache {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> Cache {
        Cache()
    }

    func updateCache(_ cache: inout Cache, subviews: Subviews) {
        // nič
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let width = proposal.width ?? 0
        guard width > 0, columns > 0 else { return .zero }

        let colWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var colHeights = Array(repeating: CGFloat(0), count: columns)

        var frames: [CGRect] = []
        frames.reserveCapacity(subviews.count)

        for subview in subviews {
            // zmeraj výšku subview pri fixnej šírke stĺpca
            let s = subview.sizeThatFits(ProposedViewSize(width: colWidth, height: nil))

            // daj do najnižšieho stĺpca
            let colIndex = colHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0

            let x = CGFloat(colIndex) * (colWidth + spacing)
            let y = colHeights[colIndex]

            frames.append(CGRect(x: x, y: y, width: colWidth, height: s.height))

            colHeights[colIndex] = y + s.height + spacing
        }

        let height = (colHeights.max() ?? 0) - spacing
        cache.frames = frames
        cache.size = CGSize(width: width, height: max(0, height))
        return cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        for (i, subview) in subviews.enumerated() {
            guard i < cache.frames.count else { continue }
            let f = cache.frames[i].offsetBy(dx: bounds.minX, dy: bounds.minY)
            subview.place(at: f.origin, proposal: ProposedViewSize(width: f.width, height: f.height))
        }
    }
}

private struct MasonryGrid<Content: View>: View {
    var columns: Int = 2
    var spacing: CGFloat = 8
    @ViewBuilder var content: () -> Content

    var body: some View {
        MasonryLayout(columns: columns, spacing: spacing) {
            content()
        }
    }
}
