import Foundation

// MARK: - User Model
struct User: Codable {
    let id: UUID
    var fullName: String
    var email: String
    var phoneNo: String
    var password: String
    var notificationsEnabled: Bool
}

// MARK: - User Data Model
class UserDataModel {
    static let shared = UserDataModel()
    
    private let archiveURL: URL
    private var users: [User] = []
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveURL = documentsDirectory.appendingPathComponent("users").appendingPathExtension("plist")
        loadUsers()
    }
    
    // MARK: - Add New User
    func addUser(_ user: User) {
        if !users.contains(where: { $0.id == user.id }) {
            users.append(user)
            saveUsers()
        }
    }
    
    // MARK: - Get All Users
    func getAllUsers() -> [User] {
        return users
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(for id: UUID, fullName: String, Email: String, phoneNo: String) -> Bool {
        if let index = users.firstIndex(where: { $0.id == id }) {
            users[index].fullName = fullName
            users[index].email = Email
            users[index].phoneNo = phoneNo
            saveUsers()
            return true
        }
        return false
    }
    // MARK: - Toggle Notification
    func toggleNotification(for id: UUID, enabled: Bool) -> Bool {
        if let index = users.firstIndex(where: { $0.id == id }) {
            users[index].notificationsEnabled = enabled
            saveUsers()
            return true
        }
        return false
    }
    
    // MARK: - Save & Load
    private func saveUsers() {
        if let data = try? PropertyListEncoder().encode(users) {
            try? data.write(to: archiveURL)
        }
    }
    
    private func loadUsers() {
        guard let data = try? Data(contentsOf: archiveURL) else { return }
        users = (try? PropertyListDecoder().decode([User].self, from: data)) ?? []
    }
}

