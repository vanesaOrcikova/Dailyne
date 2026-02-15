💡 Idea

Dailyne is a native iOS application that I personally designed and developed in my free time as a self-driven learning project. The main goal was to create an app that I would genuinely enjoy using, while also practicing and implementing a wide range of modern iOS development features and concepts.
The project is focused on productivity, fitness, and well-being, combining multiple modules into one application with an emphasis on simplicity, clean UI design, and practical everyday usability.

🏗️ Architecture & Structure

The application is developed using SwiftUI and follows the MVVM (Model–View–ViewModel) architecture. The codebase is structured in a modular, feature-based way to support maintainability and future scalability.
State management is handled reactively using:

    •	Combine
    •	ObservableObject
    •	SwiftUI property wrappers (@State, @Binding, @Published)
This approach enables predictable data flow and automatic UI updates.

💾 Data Model & Persistence

The data layer is built around a time-based model, where all records are linked to specific calendar dates.

    •	structured data (mood entries, tasks, habits, fitness metadata) is stored using UserDefaults
    •	media assets (photos, workout images, vision board content) are stored locally using FileManager
    
📱 Features / Modules

The application integrates multiple functional modules, including:

    •	Mood Tracking – mood check-ins with weekly aggregation and overview
    •	Task Management – task organization with subject-based structure
    •	Photo Diary – calendar-based journaling with daily photo entries
    •	Habit Tracking – daily habit monitoring and tracking
    •	Fitness Goals – goal tracking with weekly summaries
    •	Workout Planning – custom workout creation with exercise metadata (sets, reps, weight)
    •	Vision Board – motivational content storage and long-term goal visualization
The photo journaling module uses PhotosUI and includes UIKit–SwiftUI interoperability where needed.

⚙️ Technologies Used

    •	Swift
    •	SwiftUI
    •	MVVM Architecture
    •	Combine
    •	ObservableObject
    •	UserDefaults
    •	FileManager
    •	PhotosUI
    •	UIKit–SwiftUI Interoperability
    •	TabView Navigation
    •	SwiftUI State Management (@State, @Binding, @Published)

    
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




