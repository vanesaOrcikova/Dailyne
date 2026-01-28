//
//  VisionBoardStore.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 28/01/2026.
//

import Foundation
import UIKit
import Combine

final class VisionBoardStore: ObservableObject {

    @Published var categories: [VBCategory] = [] {
        didSet { saveToDisk() }
    }

    @Published var selectedCategoryId: UUID?

    init() {
        loadFromDisk()

        if categories.isEmpty {
            categories = [
                VBCategory(title: "Body"),
                VBCategory(title: "School"),
                VBCategory(title: "Self-Care"),
                VBCategory(title: "Life")
            ]
        }

        selectedCategoryId = categories.first?.id
    }

    // MARK: - Paths

    private var appDir: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var storeURL: URL {
        appDir.appendingPathComponent("vision_board.json")
    }

    private var photosDir: URL {
        let p = appDir.appendingPathComponent("VisionPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: p, withIntermediateDirectories: true)
        return p
    }

    // MARK: - Save / Load

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            print("❌ Vision save failed:", error)
        }
    }

    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return }
        do {
            let data = try Data(contentsOf: storeURL)
            categories = try JSONDecoder().decode([VBCategory].self, from: data)
        } catch {
            print("❌ Vision load failed:", error)
        }
    }

    // MARK: - Helpers

    var selectedCategory: VBCategory? {
        guard let id = selectedCategoryId else { return nil }
        return categories.first(where: { $0.id == id })
    }

    private func updateCategory(_ categoryId: UUID, _ update: (inout VBCategory) -> Void) {
        guard let i = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        update(&categories[i])
    }

    private func updateItem(categoryId: UUID, itemId: UUID, _ update: (inout VBItem) -> Void) {
        guard let cIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard let iIndex = categories[cIndex].items.firstIndex(where: { $0.id == itemId }) else { return }
        update(&categories[cIndex].items[iIndex])
    }

    // MARK: - Categories

    func addCategory(title: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        let new = VBCategory(title: t)
        categories.append(new)
        selectedCategoryId = new.id
    }

    func deleteCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        if selectedCategoryId == id {
            selectedCategoryId = categories.first?.id
        }
    }

    // MARK: - Items + Photos

    func addPhoto(to categoryId: UUID, imageData: Data) {
        let filename = "vb_\(UUID().uuidString).jpg"
        let url = photosDir.appendingPathComponent(filename)

        do {
            try imageData.write(to: url, options: [.atomic])

            var item = VBItem(photoFilename: filename)

            if let img = UIImage(data: imageData) {
                let isPortrait = img.size.height >= img.size.width
                item.layout = isPortrait ? .portrait : .landscape
            }

            updateCategory(categoryId) { cat in
                cat.items.insert(item, at: 0)
            }
        } catch {
            print("❌ Vision photo save failed:", error)
        }
    }

    func loadImage(for item: VBItem) -> UIImage? {
        let url = photosDir.appendingPathComponent(item.photoFilename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func removeItem(categoryId: UUID, itemId: UUID) {
        guard let cIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        guard let iIndex = categories[cIndex].items.firstIndex(where: { $0.id == itemId }) else { return }

        let filename = categories[cIndex].items[iIndex].photoFilename
        categories[cIndex].items.remove(at: iIndex)

        let url = photosDir.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    func saveDetail(categoryId: UUID, itemId: UUID, notes: String, status: VBStatus) {
        updateItem(categoryId: categoryId, itemId: itemId) { item in
            item.notes = notes
            item.status = status
        }
    }

    func moveItem(itemId: UUID, from fromCategoryId: UUID, to toCategoryId: UUID) {
        guard fromCategoryId != toCategoryId else { return }

        guard let fromIndex = categories.firstIndex(where: { $0.id == fromCategoryId }) else { return }
        guard let itemIndex = categories[fromIndex].items.firstIndex(where: { $0.id == itemId }) else { return }

        let item = categories[fromIndex].items.remove(at: itemIndex)

        updateCategory(toCategoryId) { cat in
            cat.items.insert(item, at: 0)
        }
    }
}

