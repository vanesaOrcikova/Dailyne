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





