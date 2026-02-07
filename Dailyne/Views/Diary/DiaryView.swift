//
//  DiaryView.swift
//  Dailyne
//
//  Created by Vanesa Orcikova on 07/02/2026.
//

import SwiftUI
import UIKit
import Combine

// MARK: - Model (uložené dáta: dateKey -> filename)
struct DiaryStorage: Codable {
    var photos: [String: String] = [:] // "yyyy-MM-dd" -> "filename.jpg"
}

// MARK: - Store
@MainActor
final class DiaryStore: ObservableObject {
    @Published var storage: DiaryStorage = DiaryStorage()

    private let storageKey = "DiaryStorageKey"

    init() {
        load()
    }

    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    func image(for date: Date) -> UIImage? {
        let key = dateKey(for: date)
        guard let filename = storage.photos[key] else { return nil }
        return loadImageFromDocuments(filename: filename)
    }

    func setImage(_ image: UIImage, for date: Date) {
        let key = dateKey(for: date)

        let filename = "diary-\(key).jpg"
        saveImageToDocuments(image: image, filename: filename)

        storage.photos[key] = filename
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(storage)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("DiaryStore save error:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            storage = try JSONDecoder().decode(DiaryStorage.self, from: data)
        } catch {
            print("DiaryStore load error:", error)
        }
    }

    // MARK: - Files (Documents)
    private func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func saveImageToDocuments(image: UIImage, filename: String) {
        let url = documentsURL().appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.88) else { return }
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            print("saveImageToDocuments error:", error)
        }
    }

    private func loadImageFromDocuments(filename: String) -> UIImage? {
        let url = documentsURL().appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Diary View
struct DiaryView: View {
    @StateObject private var store = DiaryStore()

    @State private var monthOffset: Int = 0
    @State private var selectedDate: Date? = nil

    @State private var showSourcePicker: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary

    // Girly aesthetic background
    private let bg = Color(red: 0.98, green: 0.94, blue: 0.95)
    private let card = Color.white.opacity(0.55)
    private let textDark = Color.black.opacity(0.75)

    var body: some View {
        let monthDate = monthDateFromOffset(monthOffset)

        ZStack {
            bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    // Title
                    Text("Diary")
                        .font(.system(size: 33, weight: .bold))
                        .foregroundColor(.black)

                    // Month header
                    HStack {
                        Text(monthTitle(for: monthDate))
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(textDark.opacity(0.55))

                        Spacer()

                        Button {
                            monthOffset -= 1
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(textDark.opacity(0.55))
                                .padding(10)
                                .background(card)
                                .clipShape(Circle())
                        }

                        Button {
                            monthOffset += 1
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(textDark.opacity(0.55))
                                .padding(10)
                                .background(card)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 4)

                    // Calendar grid
                    DiaryMonthGrid(
                        monthDate: monthDate,
                        store: store,
                        isFutureDay: { date in
                            isFutureDay(date)
                        },
                        onTapDay: { date in
                            if isFutureDay(date) {
                                return
                            }
                            selectedDate = date
                            showSourcePicker = true
                        }
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .confirmationDialog("Add photo", isPresented: $showSourcePicker, titleVisibility: .visible) {

            Button("Photo Library") {
                pickerSource = .photoLibrary
                showImagePicker = true
            }

            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: pickerSource) { image in
                guard let date = selectedDate else { return }
                store.setImage(image, for: date)
            }
        }
    }

    // ✅ TOTO ti chýbalo – preto "Cannot find isFutureDay in scope"
    private func isFutureDay(_ date: Date) -> Bool {
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)
        let today = cal.startOfDay(for: Date())
        return d > today
    }

    // MARK: - Helpers for month
    private func monthDateFromOffset(_ offset: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(byAdding: .month, value: offset, to: startOfMonth(now)) ?? now
    }

    private func startOfMonth(_ date: Date) -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }
}

// MARK: - Month Grid View
struct DiaryMonthGrid: View {
    let monthDate: Date
    @ObservedObject var store: DiaryStore
    let isFutureDay: (Date) -> Bool
    let onTapDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

    var body: some View {
        let days = daysInMonth(monthDate)

        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(days, id: \.self) { date in
                let locked = isFutureDay(date)

                DayTile(
                    date: date,
                    image: store.image(for: date),
                    isLocked: locked,
                    onTap: { onTapDay(date) }
                )
            }
        }
    }

    private func daysInMonth(_ date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }

        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date

        var result: [Date] = []
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: start) {
                result.append(d)
            }
        }
        return result
    }
}

// MARK: - Day Tile
struct DayTile: View {
    let date: Date
    let image: UIImage?
    let isLocked: Bool
    let onTap: () -> Void

    private let textSoft = Color.black.opacity(0.38)

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    // viac kontrastu pre prázdne boxy
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.72))
                        .frame(height: 112)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.14), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.09), radius: 14, x: 0, y: 9)

                    if let ui = image {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 112)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.07))
                            .frame(height: 112)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.22))
                            )
                    }

                    if isLocked {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.60))
                            .frame(height: 112)
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color.black.opacity(0.28))
                            )
                    }
                }

                Text(dayNumber(date))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textSoft)
            }
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
        .opacity(isLocked ? 0.55 : 1)
    }

    private func dayNumber(_ date: Date) -> String {
        let calendar = Calendar.current
        let d = calendar.component(.day, from: date)
        return "\(d)"
    }
}

// MARK: - UIKit Image Picker (Camera + Library)
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()

        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = sourceType
        }

        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage) -> Void

        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let edited = info[.editedImage] as? UIImage
            let original = info[.originalImage] as? UIImage

            if let img = edited ?? original {
                onImagePicked(img)
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
