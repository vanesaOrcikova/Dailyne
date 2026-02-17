💡 Dailyne – iOS Application

Dailyne is a native iOS application that I designed and developed as a personal side project in my free time. The main goal was to build a practical app that I would realistically use on a daily basis, while also practicing the implementation of multiple modern iOS development features within one modular project.

The application combines productivity, fitness, and well-being into one system, where all modules are built around a calendar-based logic (data is linked to specific dates). The UI is designed to be minimalistic, clean, and user-friendly, with a focus on simple daily usability.

📸 Photo Diary (PhotosUI + Local Storage)

I implemented a calendar-based photo journaling module where users can attach photo entries to specific days.

    • image selection is handled using PhotosUI (PhotosPicker)
    • photos are stored locally using FileManager inside the app’s storage, ensuring offline access and fast loading
    • this module can be extended in the future with cloud storage (e.g., Firebase Storage) for cross-device synchronization and backup

💪 Workout Planning

The Workout module allows users to create custom workout plans and add exercises with structured parameters such as sets, reps, and weight. The module is based on a structured data model and supports adding, editing, and displaying workouts through detailed screens.

    • support for creating custom workout plans
    • adding exercises with parameters (sets / reps / weight)
    • detailed workout screens for viewing and editing training sessions

✅ Task Management (Categories + Editing)

I implemented the Task module as a categorized task system (e.g. by subject). The data is stored as structured models (Codable) and stored via UserDefaults using JSONEncoder and JSONDecoder.

Adding and editing tasks is handled via a separate edit view, where the user sets parameters using SwiftUI Form components (TextField, Picker, DatePicker). Each task contains properties such as deadline, priority and task type, which allows you to create a more transparent system than a classic checklist. 

🖼️ Vision Board (Categories)

I created the Vision Board module as a visual grid-based system where users can store motivational content and long-term goals grouped into categories. The content is displayed using SwiftUI’s LazyVGrid, which allows flexible and efficient grid rendering even when the number of items grows.

I also implemented a status system (someday / in progress / achieved), which can be changed through a picker or context menu and is stored inside the data model. This feature provides a structured way to track long-term goals and progress.

    • visual grid layout implemented with LazyVGrid for scalable and clean UI presentation
    • category-based organization of vision items
    • status system: someday / in progress / achieved
    • status editing through context menu / picker, stored persistently in the model

💾 Local Storage

Structured data (tasks, habits, mood, workouts) is stored locally using UserDefaults, while media content (photos) is stored separately using FileManager.

    • Codable + UserDefaults used for storing structured data using JSON encoding
    • FileManager used for storing and loading photos inside the app directory

 
![IMG_7308 2 (1)](https://github.com/user-attachments/assets/8d375f11-4e22-43f4-9685-2b13ab758bff)

![IMG_7309](https://github.com/user-attachments/assets/37ca784e-d670-4559-8156-8d5aa6f1046d)
![IMG_7310](https://github.com/user-attachments/assets/0fdae059-199c-4ecb-8114-f06d210e81d8)
![IMG_7311](https://github.com/user-attachments/assets/38567a3d-7657-44b7-b05c-384434d19df7)

![IMG_7312](https://github.com/user-attachments/assets/fc0ff356-035b-41f0-b183-bbe0500d0546)

![IMG_7313](https://github.com/user-attachments/assets/fc337bb0-d607-48bb-b970-c8e4c89da148)
![IMG_7314](https://github.com/user-attachments/assets/e9a46752-5e62-45aa-8d71-24688ec7afd8)
![IMG_7317](https://github.com/user-attachments/assets/eeed56a8-5f80-491d-a45e-ef4617833407)

![IMG_7318](https://github.com/user-attachments/assets/6933c3b3-4e71-4bcb-a200-912d62230496)
![IMG_7320](https://github.com/user-attachments/assets/cf7f31ac-503f-49c1-8464-07f69c732720)




