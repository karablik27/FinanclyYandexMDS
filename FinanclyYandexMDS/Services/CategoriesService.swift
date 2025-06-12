import Foundation

final class CategoriesService {

    // MARK: - Mock Data
    private let mockCategories: [Category] = [
        Category(id: 1, name: "Кино", emoji: "🎬", isIncome: false),
        Category(id: 2, name: "Зарплата", emoji: "💵", isIncome: true),
        Category(id: 3, name: "Рестораны", emoji: "🍽️", isIncome: false)
    ]

    // MARK: - Public Methods
    // Пока без обработки ошибок тк работаем с фейк данными.
    func all() async -> [Category] {
        return mockCategories
    }

    func byDirection(_ direction: Direction) async -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
}
